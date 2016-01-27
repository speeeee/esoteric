#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#define INT 0
#define FLT 1
#define CHR 2
#define LST 3
#define FUN 4

typedef void  *A;
typedef long   Int;
typedef double Flt;
typedef char   Chr;

typedef struct { union { Int i; Flt f; Chr c; } x; unsigned int type; } Lit;
typedef struct { Lit lx; struct Elem *next; } Elem;

Lit lit(A x, int type) { Lit l;
  switch(type) { case INT: l.x.i = x; break;
                 case FLT: l.x.f = x; break;
                 case CHR: l.x.c = x; break; } l.t = type; return l; }
Lit readInt(void) { int i; scanf("%d",&i); return lit(i,INT); }
Elem list(int n, ...) { 
  va_list vl; va_start(vl,n); Elem *x; Elem *curr;
  for(int i=0;i<n;i++) { Lit val = va_arg(vl,Lit);
    if(i==0) { x->lx = val; curr = x; }
    else { Elem *n; n->lx = val; curr->next = n; curr = n; } }
  return x; }
