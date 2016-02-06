// == interpreter ========================================================//
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "prelude2.h"

/*#define VAL(t,v) ((t)==INT?(v).x.i:(t)==FLT?(v).x.f: \
                  (t)==CHR?(v).x.c:(t)==STR?(v).x.s: \
                  (t)==LST?(v).x.e:0)*/
#define VAL(t,v) ((t)==INT?(v).x.i:(t)==FLT?(v).x.f:(t)==CHR?(v).x.c:(t)==STR?(v).x.e:0)

#define PAREN 8
#define END   9
#define FAIL  10

typedef struct { char *name; FPtr ptr; } Fn;
typedef struct { int typ; union { Elem *a; Lit b; }; } LLit;

Lit exec(Lit);
Lit word(Elem *);

void DESTROY(Elem *a) { if(a->next) { DESTROY(a->next); }
  /*if(a->lx.x.e) { DESTROY(a->lx.x.e); }*/
  if(a->lx.type==LST) { DESTROY(a->lx.x.e); } free(a); }

Lit and(Elem *a) { if(a->lx.type==SUC&&a->next->lx.type==SUC) {
  Lit e; e.type = SUC; 
  e.x.i = a->lx.x.i&&a->lx.x.i;
  DESTROY(a); /* not yet defined */ return e; }
  else { DESTROY(a); printf("type mismatch\n"); return liti(0); } }
Lit add(Elem *a) { if(a->lx.type==INT&&a->next->lx.type==INT) {
  Lit e = liti(a->lx.x.i+a->next->lx.x.i); DESTROY(a); return e; }
  else { DESTROY(a); printf("type mismatch\n"); return liti(0); } }

Fn prims[] = { { "and", &and }, { "+", &add }, { "&prn", &printAtom } }; 
int fsz = 3;
Elem **funs; int dsz = 0;

Lit prnList(Elem *a) { Elem *curr = malloc(sizeof(Elem)); curr = a;
  printf("("); while(curr->next) { if(curr->lx.type == LST) {
    prnList(curr->lx.x.e); } else { 
    printAtom(curr); printf(" "); curr = curr->next; } } printf(")\n"); return liti(0); }

char *tok(FILE *s,int c) {
  int sz = 0; int lsz = 10; char *str = malloc(lsz*sizeof(char));
  while(!isspace(c)&&c!='('&&c!=')') { 
    if(sz==lsz) { str = realloc(str,(lsz+=10)*sizeof(char)); }
    str[sz++] = c; c = fgetc(s); } ungetc(c,stdin); str[sz] = '\0'; return str; }
long int tokl(FILE *s,int c) { 
  int sz = 0; int lsz = 10; char *str = malloc(lsz*sizeof(char));
  while(isdigit(c)) {
    if(sz==lsz) { str = realloc(str,(lsz+=10)*sizeof(char)); }
    str[sz++] = c; c = fgetc(s); } ungetc(c,stdin); str[sz] = '\0';
    long int e = atol(str); return e; }
Lit lexd(FILE *s, int eofchar) { int c;
  while(/*isspace(c = fgetc(s))*/(c = fgetc(s))==' '||c=='\t');
  if(isdigit(c)) { //Lit q; fscanf(s,"%li",&q.x.i); q.type = INT; return q; }
                   return liti(tokl(s,c)); }
  if(c=='(') { Lit e; e.x.i = -1; e.type = PAREN; return e; }
  if(c==')') { Lit e; e.x.i = 1; e.type = PAREN; return e; }
  if(c==eofchar||c==EOF) { Lit e; e.x.i = EOF; e.type = END; return e; }
  else { return litsy(tok(s,c)); } }
Lit lex(FILE *s) { return lexd(s,EOF); }

Elem *parse(FILE *s,int eo) { Elem *head = malloc(sizeof(Elem));
  Elem *curr = malloc(sizeof(Elem)); Lit l = lexd(s,eo);
  head->lx = l; head->next = malloc(sizeof(Elem)); curr = head; curr = curr->next;
  while((l = lexd(s,eo)).type != END) {
    if(l.type == PAREN) { if(l.x.i==-1) {
                            curr->lx.x.e = parse(s,eo); curr->lx.type = LST; }
                          else { return head; } }
    else { curr->lx = l; } //prnList(head); //printAtom(curr);
    curr->next = malloc(sizeof(Elem)); curr = curr->next; }
  free(curr); return head; }

Lit fail(void) { Lit r; r.x.i = 0; r.type = FAIL; return r; }
int isfail(Lit x) { return x.type == FAIL; }

Lit see_prim(Elem *, Elem *);
Lit see_prim(Elem *n, Elem *s) { if(n->lx.type == SYM) { char *q = n->lx.x.s; int i;
  if(!strcmp(q,":q")) { exit(0); } 
  for(i=0;i<fsz;i++) {
    if(!strcmp(q,prims[i].name)) { 
      Elem *q = malloc(sizeof(Elem)); q = s;
      while(q->next) { q->lx = exec(q->lx); q = q->next; }
      return call(fun(prims[i].ptr),s); } }
  if(i==fsz) { fail(); } } else { fail(); } }

Lit exec(Lit x) { if(x.type!=LST) { return x; } else { return word(x.x.e); } }

Lit word(Elem *s) { Lit q = see_prim(s,s->next);
  if(!isfail(q)) { return q; } else { printf("FAILURE\n"); exit(0); return q; } }

Lit prgm(FILE *s, int eofchar) { return word(parse(s,eofchar)); }

int main(int argc, char **argv) { while(1) { printf("\n> "); prgm(stdin,'\n'); }
  return 0; }
