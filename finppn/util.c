// utility functions

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdarg.h>

typedef int (*predicate)(int);

char *join(char *in, char *f, char *s) {
  char *n = malloc((strlen(in)+strlen(f)+strlen(s)+1)*sizeof(char));
  for(int i=0;i<strlen(f);i++) { n[i] = f[i]; }
  for(int i=0;i<strlen(in);i++) { n[i+strlen(in)] = in[i]; }
  for(int i=0;i<strlen(s);i++) { n[i+strlen(in)+strlen(f)] = s[i]; }
  n[strlen(s)+strlen(in)+strlen(f)] = '\0'; return n; }

char *tok(predicate pred, int c) {
  /*if(n) { free(n); }*/ int q = 1; int sz = 10;
  char *n = malloc(10*sizeof(char)); n[0] = c; 
  while(pred(c)) {
    if(q+1>sz) { n = realloc(n,(sz+=10)*sizeof(char)); } 
    n[(q++)-1] = c; c = getchar(); } n[q] = '\0'; ungetc(c,stdin); return n; }

int num(int c) { puts("num"); return isdigit(c)||c == '.'; }
int str(int c) { puts("str"); return c != '"'; } 
int sym(int c) { puts("sym"); return isgraph(c)&&!isdigit(c)&&c!='.'; }
