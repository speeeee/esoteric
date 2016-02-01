// == interpreter ========================================================//
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "prelude2.h"

#define PAREN 7

Lit lex(FILE *s) { int c;
  while(isspace(c = fgetc(s))); }
  
