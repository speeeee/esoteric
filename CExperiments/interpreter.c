// == interpreter ========================================================//
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "prelude2.h"

#define PAREN 8

char *tok(s,c) { int sz = 0; int lsz = 10; char *str = malloc(lsz*sizeof(char));
  while(!isspace(c)&&c!='('&&c!=')') { 
    if(sz==lsz) { str = realloc(str,(lsz+=10)*sizeof(char)); }
    str[sz++] = c; c = fgetc(s); } ungetc(c,stdin); str[sz] = '\0'; return str; }

Lit lex(FILE *s) { int c;
  while(isspace(c = fgetc(s)));
  if(isdigit(c)) { Lit q; fscanf(s,"%li",&q.x.i); q.type = INT; return q; }
  if(c=='(') { Lit e; e.x.i = -1; e.type = PAREN; }
  if(c==')') { Lit e; e.x.i = 1; e.type = PAREN; }
  if(c==EOF) { exit(0); }
  else { lits(tok(s,c)); } }
