#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#define NIL -1
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

void nlstptr(Elem *s) { if(s->x.type!=NIL) {
  s->next = malloc(sizeof(Elem)); s = s->next; } }
void nlstptrg(void) { if(stk) { Elem *q = malloc(sizeof(Elem));
  stk->next = malloc(sizeof(Elem)); stk->next = q; stk = stk->next; } 
  else { top = stk = malloc(sizeof(Elem)); } }
void appeg(Lit l, Elem *s) { nlstptr(s); stk->x = l; }

Lit liti(int64_t i) { Lit l; l.x.i = i; l.type = INT; return l; }
Lit litsy(char *x) { Lit l; l.x.s = x; l.type = SYM; return l; }

Lit tok(FILE *in) { Lit l; int c = fgetc(in); printf("%i\n",c); switch(c) {
  case I: fread(&l.x.i,sizeof(int64_t),1,in); l.type = INT; break;
  case F: fread(&l.x.f,sizeof(double),1,in); l.type = FLT; break;
  case S: { int e; fread(&e,sizeof(int64_t),1,in); fread(&l.x.s,1,e,in);
            l.type = SYM; break; }
  case E: l.x.i = 0; l.type = EXP; break; case D: l.x.i = 0; l.type = FXP; break;
  case EOF: l.x.i = 0; l.type = END; } return l; }

void ureader(FILE *in, Elem *s, int d) { for(int i=0;i<d;i++) { printf("."); }
  Lit l; while((l=tok(in)).type!=END&&l.type!=FXP) {
    if(l.type == EXP) { nlstptr(s); l = tok(in); s->x = l;
      s->up = malloc(sizeof(Elem)); ureader(in,s->up,d+1); }
    else { appeg(l,s); } } }

int main(int argc, char **argv) { FILE *f; f = fopen("test.ul","rb");
  stk = top = malloc(sizeof(Elem)); top->x.type = NIL;
  ureader(f,top,0); fclose(f); return 0; }
