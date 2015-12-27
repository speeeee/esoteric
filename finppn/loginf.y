/* C-based loginf base compiler */

%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "util.h"
  int yylex(void);
  void yyerror(void);
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
| expr SYM expr { $$ = appSym($2,$1,$3); }
| '(' expr ')' { $$ = $2; }
| expr '[' expr ']' expr { $$ = appSym($2,$1,$3); } ;

%%

int yylex(void) {
  int c; if(num(c)) { tok(&num,yylval,c); }
  if(c=='"') { tok(&str,yylval,c); }
  if(c==EOF) { return 0; }
  while((c = getchar()) == ' ' || c == '\t' || c == '\n') continue;
  if { sym(c); } return c; }
