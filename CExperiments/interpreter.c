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

#define PAREN 10
#define END   11
#define FAIL  12

typedef struct { char *name; FPtr ptr; } Fn;
typedef struct { int typ; union { Elem *a; Lit b; }; } LLit;

Lit exec(Lit);
Lit word(Elem *);
Lit prnList(Elem *);

void DESTROY(Elem *a) { if(a->next) { DESTROY(a->next); }
  /*if(a->lx.x.e) { DESTROY(a->lx.x.e); }*/
  if(a->lx.type==LST) { DESTROY(a->lx.x.e); } free(a); }

// -- general standard library ------------------------------------- //

Lit and(Elem *a) { if(a->lx.type==SUC&&a->next->lx.type==SUC) {
  Lit e; e.type = SUC; 
  e.x.i = a->lx.x.i&&a->lx.x.i;
  DESTROY(a); /* not yet defined */ return e; }
  else { DESTROY(a); printf("type mismatch\n"); return liti(0); } }
Lit add(Elem *a) { if(a->lx.type==INT&&a->next->lx.type==INT) {
  Lit e = liti(a->lx.x.i+a->next->lx.x.i); DESTROY(a); return e; }
  else { DESTROY(a); printf("type mismatch\n"); return liti(0); } }
Lit ref(Elem *a) { if(a->lx.type==INT&&a->next->lx.type==LLT) { 
  Elem *e = malloc(sizeof(Elem)); e = a->next->lx.x.e;
  for(int i=0;i<a->lx.x.i;i++) { if(e->next) { e = e->next; } else {
    printf("error: index out of bounds.\n"); exit(0); } } Lit r = e->lx;
  DESTROY(a); return r; } else { printf("error:&REF: type mismatch.\n"); exit(0); } }
Lit cr_list(Elem *a) { Lit e; e.type = LLT; e.x.e = malloc(sizeof(Elem));
  e.x.e = a; return e; }

Fn prims[] = { { "and", &and }, { "+", &add }, { "&prn", &printAtom },
               { "$", &cr_list }, { "&REF", &ref } }; 
int fsz = 5;
Elem **funs; int dsz = 0;

// ----------------------------------------------------------------- //

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
  if(l.type == PAREN) { if(l.x.i==-1) { head->lx.x.e = parse(s,eo);
                          head->lx.type = LST; } else { return head; } }
  else { head->lx = l; }
  /*head->lx = l;*/
  head->next = malloc(sizeof(Elem)); curr = head; curr = curr->next;
  while((l = lexd(s,eo)).type != END) {
    if(l.type == PAREN) { if(l.x.i==-1) {
                            curr->lx.x.e = parse(s,eo); curr->lx.type = LST; }
                          else { return head; } }
    else { curr->lx = l; } //prnList(head); //printAtom(curr);
    curr->next = malloc(sizeof(Elem)); curr = curr->next; }
  free(curr); return head; }

Lit fail(void) { Lit r; r.x.i = 0; r.type = FAIL; return r; }
int isfail(Lit x) { return x.type == FAIL; }

// TODO: make $: list and $': list-noeval.

Lit lambda(Elem *a) { Lit q; q.type = LAM; q.x.e = malloc(sizeof(Elem)); 
  q.x.e = a; return q; }

Elem *replace_all(Elem *e, Elem *l) { Elem *q = malloc(sizeof(Elem)); q = e;
  while(q->next) { if(q->lx.type==SYM&&!strcmp(q->lx.x.s,"x.")) { 
      free(q->lx.x.s); q->lx.type = LLT; q->lx.x.e = malloc(sizeof(Elem));
      q->lx.x.e = l; }
    //else if(q->lx.type==LST) { q->lx.x.e = replace_all(q->lx.x.e,l); }
    q = q->next; } return e; }

Lit see_prim(Elem *, Elem *);
Lit see_prim(Elem *n, Elem *s) { if(n->lx.type == SYM) { char *q = n->lx.x.s; int i;
  if(!strcmp(q,":q")) { exit(0); }
  if(!strcmp(q,"\\")) { return lambda(s); } // '\'s arguments are not eval'd.
  for(i=0;i<fsz;i++) {
    if(!strcmp(q,prims[i].name)) { 
      Elem *q = malloc(sizeof(Elem)); q = s;
      while(q->next) { q->lx = exec(q->lx); q = q->next; }
      return call(fun(prims[i].ptr),s); } }
  if(i==fsz) { return fail(); } } else { return fail(); } }

Lit app_la(Elem *n, Elem *s) { if(n->lx.type == LAM) {
  Elem *q = malloc(sizeof(Elem)); q = s;
  while(q->next) { q->lx = exec(q->lx); q = q->next; }
  return word(replace_all(n->lx.x.e,s)); }
  else { printf("is neither function nor lambda.\n"); exit(0); } }

Lit exec(Lit x) { if(x.type!=LST) { return x; } else { return word(x.x.e); } }

Lit word(Elem *s) { s->lx = exec(s->lx);
  Lit q = see_prim(s,s->next);
  if(!isfail(q)) { return q; } else {
    return app_la(s,s->next); } }

Lit prgm(FILE *s, int eofchar) { return word(parse(s,eofchar)); }

int main(int argc, char **argv) { while(1) { printf("\n> "); prgm(stdin,'\n'); }
  return 0; }
