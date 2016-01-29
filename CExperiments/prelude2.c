#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#define INT 0
#define FLT 1
#define CHR 2
#define LST 3
#define LAM 4
#define FUN 5
#define SUC 6

typedef void  *A;
typedef long   Int;
typedef double Flt;
typedef char   Chr;

typedef struct Elem Elem;
typedef struct Lit Lit;
typedef Lit (*FPtr)(Elem *);

struct Lit { union { Int i; Flt f; Chr c; Elem *e; } x; unsigned int type; };
struct Elem { Lit lx; struct Elem *next; };
typedef struct { int t; union { char *la; FPtr f; }; } Fun;

/*Lit lit(A x, int type) { Lit l;
  switch(type) { case INT: l.x.i = *(long *) x; break;
                 case FLT: l.x.f = *(double *) x; break;
                 case CHR: l.x.c = *(char *) x; break;
                 case LST: l.x.e = *(Elem **) x; break; } l.type = type; return l; }*/
Lit lit(int type, int n, ...) { 
  va_list vl; va_start(vl,n); Lit l; l.type = type;
  switch(type) { case INT: l.x.i = va_arg(vl,long); break;
                 case FLT: l.x.f = va_arg(vl,double); break;
                 case CHR: l.x.c = va_arg(vl,int); break;
                 case LST: l.x.e = va_arg(vl,Elem *); break;
                 default: exit(0); } return l; }

Lit readInt(void) { int i; scanf("%d",&i); return lit(i,INT); }
Elem *list(int n, ...) { 
  va_list vl; va_start(vl,n); Elem *x; Elem *curr;
  for(int i=0;i<n;i++) { Lit val = va_arg(vl,Lit);
    if(i==0) { printf("%li is val\n",val.x.i); x->lx = val; curr = x; }
    else { Elem *n; n->lx = val; curr->next = n; curr = n; } }
  va_end(vl); return x; }
Lit printAtom(Elem *a) { printf("%i\n",a->lx.type);
  switch(a->lx.type) { case INT: printf("%ld",a->lx.x.i); break;
                       case FLT: printf("%g",a->lx.x.f); break;
                       case CHR: printf("%c",a->lx.x.c); break;
                       default: printf("error\n"); }
  return lit(0,INT); }

Lit call(FPtr x, Elem *a) {
  return x(a); }

int main(int argc, char **argv) {
  call(&printAtom,list(1,lit(INT,1,3))); return 0; }