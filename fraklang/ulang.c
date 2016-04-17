#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#define SYM 0
#define INT 1
#define FLT 2
#define END 3
#define FUN 4
#define EXP 5
#define FXP 6

#define I 0
#define F 1
#define S 2
#define E 3
#define D 4
#define C 5

// example using pseudo-bytecode: EC0I2I3D = (+ 2 3) where 0 is the id for '+'.

typedef struct Lit Lit;
struct Lit { union { int64_t i; double f; char *s; } x;
             unsigned int type; };
typedef struct Elem { Lit x; struct Elem *up; struct Elem *dw;
                      struct Elem *prev; struct Elem *next; } Elem;
typedef struct { char *name; int ins; Elem *body; } Fun;

Fun funs[] = { { "+", 2, NULL } }; int fsz = 1;

Elem *top; Elem *stk;

void nlstptrg(void) { if(stk) { Elem *q = malloc(sizeof(Elem));
  stk->next = malloc(sizeof(Elem)); stk->next = q; stk = stk->next; } 
  else { top = stk = malloc(sizeof(Elem)); } }
void appeg(Lit l) { nlstptrg(); stk->x = l; }

Lit liti(int64_t i) { Lit l; l.x.i = i; l.type = INT; return l; }
Lit litsy(char *x) { Lit l; l.x.s = x; l.type = SYM; return l; }

Lit tok(FILE *in) { Lit l; int c = fgetc(in); switch(c) {
  case I: fread(&l.x.i,sizeof(int64_t),1,in); l.type = INT; break;
  case F: fread(&l.x.f,sizeof(double),1,in); l.type = FLT; break;
  case S: { int e; fread(&e,sizeof(int64_t),1,in); fread(&l.x.s,1,e,in);
            l.type = SYM; break; }
  case E: l.x.i = 0; l.type = EXP; case D: l.x.i = 0; l.type = FXP; break;
  case EOF: l.x.i = 0; l.type = END; } return l; }

void ureader(FILE *in, Elem *s) { Lit l; while((l=tok(in)).type!=END&&
                                               l.type!=FXP) {
  if(l.type == EXP) { nlstptrg(); l = tok(in); s->x = l;
    s->up = malloc(sizeof(Elem)); ureader(in,s->up); }
  else { appeg(l); } } }

int main(int argc, char **argv) { FILE *f; f = fopen("test.ul","rb");
  ureader(f,top); fclose(f); return 0; }
