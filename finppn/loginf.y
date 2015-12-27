/* C-based loginf base compiler */

%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "util.h"
  int yylex(void);
  void yyerror(void);
  char *appDya(char *sym, char *l, char *r) { 
    
  char *appMon(char *sym, char *r) {
%}

%define api.value.type {char *}

// base types
%token INT
%token FLT
%token STR
%token SYM

%%

input:
  %empty
| input expr ;

expr:
  INT { $$ = itoa($1); }
| STR { $$ = $1; }
| INT expr { $$ = join(","itoa($1),$2); }
| STR expr { $$ = join(",",$1,$2); }
| expr SYM expr { $$ = appDya($2,$1,$3); }
| Sym expr { $$ = appMon($1,$2); }
| '(' expr ')' { $$ = $2; }
| expr '[' expr ']' expr { $$ = appSym($2,$1,$3); } ;

%%

int yylex(void) {
  int c; while((c = getchar()) == ' ' || c == '\t' || c == '\n') continue;
  if(num(c)) { tok(&num,yylval,c); }
  if(c=='"') { tok(&str,yylval,c); }
  if(c==EOF) { return 0; }
  else { sym(c); } return c; }
