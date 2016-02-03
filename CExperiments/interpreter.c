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

Lit and(Elem *a) { if(a->lx.type==SUC&&a->next->lx.type==SUC) {
  Lit e; e.type = SUC; 
  e.x.i = a->lx.x.i&&a->lx.x.i;
  DESTROY(a); /* not yet defined */ return e; }
  else { DESTROY(a); printf("type mismatch\n"); return liti(0); } }

Fn prims[] = { { ",", &and } }; int fsz = 1;
Elem **funs;

char *tok(FILE *s,int c) {
  int sz = 0; int lsz = 10; char *str = malloc(lsz*sizeof(char));
  while(!isspace(c)&&c!='('&&c!=')') { 
    if(sz==lsz) { str = realloc(str,(lsz+=10)*sizeof(char)); }
    str[sz++] = c; c = fgetc(s); } ungetc(c,stdin); str[sz] = '\0'; return str; }

Lit lexd(FILE *s, int eofchar) { int c;
  while(isspace(c = fgetc(s)));
  if(isdigit(c)) { Lit q; fscanf(s,"%li",&q.x.i); q.type = INT; return q; }
  if(c=='(') { Lit e; e.x.i = -1; e.type = PAREN; }
  if(c==')') { Lit e; e.x.i = 1; e.type = PAREN; }
  if(c==eofchar) { Lit e; e.x.i = EOF; e.type = END; }
  else { lits(tok(s,c)); } }
Lit lex(FILE *s) { return lexd(s,EOF); }

Elem *parse(FILE *s) { Elem *head = malloc(sizeof(Elem));
  Elem *curr = malloc(sizeof(Elem)); Lit l = lex(s);
  head->lx = l; head->next = malloc(sizeof(Elem)); curr = head; curr = curr->next;
  while((l = lex(s)).type != END) {
    if(l.type == PAREN) { if(l.x.i==-1) { l.x.e = parse(s); l.type = LST; }
                          else { return head; } }
    else { curr->lx = l; }
    curr->next = malloc(sizeof(Elem)); curr = curr->next; }
  free(curr->next); return head; }

Lit fail(void) { Lit r; r.x.i = 0; r.type = FAIL; return r; }
int isfail(Lit x) { return x.type == FAIL; }

Lit see_prim(Elem *, Elem *);
Lit see_prim(Elem *n, Elem *s) { if(n->lx.type == SYM) { char *q = n->lx.x.s; int i;
  for(i=0;i<fsz;i++) {
    if(!strcmp(q,prims[i].name)) { 
      Elem *q = malloc(sizeof(Elem)); q = s;
      while(q) { q->lx = exec(q->lx); q = q->next; }
      return call(fun(prims[i].ptr),s); } }
  if(i==fsz) { fail(); } } else { fail(); } }

Lit exec(Lit x) { if(x.type!=LST) { return x; } else { return word(x.x.e); } }

Lit word(Elem *s) { Lit q = see_prim(s,s->next);
  if(!isfail(q)) { return q; }
  
  
