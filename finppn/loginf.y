/* C-based loginf base compiler */

%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "util.h"
  int yylex(void);
  void yyerror(const char *x) { printf("%s",x); }
  char **m; char **d; int dsz = 0; int msz = 0;
  char *pushMon(char *sym, char *expr) { m = realloc(m,++msz*sizeof(char *)); 
    strcpy(m[msz-1],sym); return "True"; }
  int existsd(char *sym) { int i; while(strcmp(d[i++],sym)&&i<dsz); return i<dsz; }
  int existsm(char *sym) { int i; while(strcmp(m[i++],sym)&&i<msz); return i<msz; }
  char *appDya(char *sym, char *l, char *r) { 
    if(!strcmp(sym,"+")) { 
      return join("(",sym,join(",",l,r)); }
    else { printf("unknown dyad: %s\n", sym); return ""; } }
  char *appMon(char *sym, char *r) {
    if(existsm(sym)) { return join("(",sym,join(")",r,";\n")); }
    else { printf("unknown monad: %s\n", sym); return ""; } }
%}

%define api.value.type {char *}

// base types
%token LIT
%token SYM

%%

input:
  %empty
| input line ;

line: '\n' | expr '\n' { printf("\t%s\n",$1); } ;

expr:
  LIT { $$ = $1; }
| SYM { $$ = $1; }
| LIT expr { $$ = join(",",$1,$2); }
| LIT SYM expr { $$ = appDya($2,$1,$3); }
| '(' expr ')' SYM expr { $$ = appDya($4,$2,$5); }
//| SYM expr { $$ = appMon($1,$2); }
| '(' expr ')' { $$ = $2; }
//| SYM '-' '>' expr { $$ = pushMon($1,$4); }
//| expr '[' expr ']' expr { $$ = appSym($2,$1,$3); } ;
;

%%

int yylex(void) {
  int c; while((c = getchar()) == ' ' || c == '\t') continue;
  if(num(c)) { yylval = tok(num,c); printf("%s",yylval); return LIT; }
  if(c=='"') { yylval = tok(str,c); printf("%s",yylval); return LIT; }
  if(isgraph(c)) { yylval = tok(sym,c); return SYM; } 
  if(c==EOF) { return 0; }
  return c; }

int main(int argc, char **argv) {
  d = malloc(sizeof(char *)); m = malloc(sizeof(char *));
  d = realloc(d,++dsz*sizeof(char *)); d[0] = "+";
  return yyparse(); }
