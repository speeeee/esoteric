#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#define INT 0
#define FLT 1
#define CHR 2
#define STR 3
#define LST 4
#define LAM 5
#define FUN 6
#define SUC 7
#define SYM 8

typedef void  *A;
typedef long   Int;
typedef double Flt;
typedef char   Chr;

typedef struct Elem Elem;
typedef struct Lit Lit;
typedef Lit (*FPtr)(Elem *);

struct Lit { union { Int i; Flt f; Chr c; Chr *s; Elem *e; } x;
             unsigned int type; };
//struct Lit { Int i; Flt f; Chr c; Elem *e; unsigned int type; };
struct Elem { Lit lx; struct Elem *next; };
typedef struct { int t; union { char *la; FPtr f; }; } Fun;

/*Lit lit(A x, int type) { Lit l;
  switch(type) { case INT: l.x.i = *(long *) x; break;
                 case FLT: l.x.f = *(double *) x; break;
                 case CHR: l.x.c = *(char *) x; break;
                 case LST: l.x.e = *(Elem **) x; break; } l.type = type; return l; }*/
/*Lit lit(int type, int n, ...) { 
  va_list vl; va_start(vl,n); Lit l; l.type = type;
  switch(type) { case INT: l.x.i = va_arg(vl,long); break;
                 case FLT: l.x.f = va_arg(vl,double); break;
                 case CHR: l.x.c = va_arg(vl,int); break;
                 case LST: l.x.e = va_arg(vl,Elem *); break;
                 default: printf("nem"); } printf("%i", l.type); return l; }*/
Lit liti(long i) { Lit l; l.x.i = i; l.type = INT; return l; }
Lit lits(char *x) { Lit l; l.x.s = x; l.type = STR; return l; }

Lit readInt(void) { int i; scanf("%d",&i); return liti(i); }
Elem *list(int n, ...) { 
  va_list vl; va_start(vl,n); Elem *x = malloc(sizeof(Elem));
  Elem *curr = malloc(sizeof(Elem));
  for(int i=0;i<n;i++) { Lit val = va_arg(vl,Lit);
    if(i==0) { x->lx = val; curr = x; }
    else { Elem *n = malloc(sizeof(Elem)); n->lx = val; curr->next = n; curr = n; } }
  va_end(vl); return x; }
Elem *nlist(Lit x) { Elem *e; e->lx = x; return e; }
// Elem *cons(Elem *a, Elem *l)
Lit printAtom(Elem *a) {
  switch(a->lx.type) { case INT: printf("%li",a->lx.x.i); break;
                       case FLT: printf("%g",a->lx.x.f); break;
                       case CHR: printf("%c",a->lx.x.c); break;
                       default: printf("error\n"); }
  return liti(0); }

Fun fun(FPtr x) { Fun r; r.t = FUN; r.f = x; return r; }
Fun lam(char *x) { Fun r; r.t = LAM; r.la = malloc(sizeof x); strcpy(r.la,x);
                   return r; }
Lit call(Fun x, Elem *a) {
  if(x.t==FUN) { return x.f(a); } }

// == lambda storage   ===================================================//
//    lambda expressions are stored as strings that refer to function pointers.
//    it also has a small grammar to specify composition and similar actions on
//    functions.  "fun1,fun2" is an example of a composition.

// == standard library ===================================================//

int main(int argc, char **argv) {
  call(fun(&printAtom),list(1,liti(3)));
  //Elem *root = malloc(sizeof(Elem)); root->lx.i = 3; root->lx.type = 0;
  /*printAtom(root); printf("%li",root->lx.i);*/ return 0; }
