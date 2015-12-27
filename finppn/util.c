// utility functions

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

char *join(char *in, char *f, char *s) {
  char *n = malloc((strlen(in)+strlen(f)+strlen(s)+1)*sizeof(char));
  for(int i=0;i<strlen(f);i++) { n[i] = f[i]; }
  for(int i=0;i<strlen(in);i++) { n[i+strlen(in)] = in[i]; }
  for(int i=0;i<strlen(s);i++) { n[i+strlen(in)+strlen(f)] = s[i]; }
  n[strlen(s)+strlen(in)+strlen(f)] = '\0'; return n; }

char *tok(int (*pred)(int), char *n, int c) {
  if(n) { free(n); } int q = 1; int sz = 10;
  n = malloc(10*sizeof(char)); n[0] = c; 
  while(pred(c)) {
    if(q+1>sz) { n = realloc(n,(sz+=10)*sizeof(char)); } 
    n[(q++)-1] = c; } n[q] = '\0'; }

int num(int c) { isdigit(c)||c == '.'; }
int str(int c) { c != '"'; } int sym(int c) { c!=' '&&c!='\t'&&c!='\n'&&c!=EOF; }
