#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#define NIL 12
#define SYM 0
#define INT 1
#define FLT 2
#define END 3
#define FUN 4
#define EXP 5
#define FXP 6
// functions are stored as pointers to their name, where [ptr]->next is the
// body of the function.
#define NFN 7
// in the reading phase, function names are changed to their respective
// addresses, to save time.  e.g. (call +) will put the actual function in place.
#define CAL 8
#define LAM 9
#define VAR 10
#define PRI 11

#define I 0 // 64-bit integer
#define F 1 // 64-bit floating point
#define S 2 // symbol: 64-bit integer (n) + n bytes
#define E 3 // open-expression
#define D 4 // close-expression
#define C 5 // call function
#define N 6 // create function (follow with symbol)
#define L 7 // initialize lambda-expr creation (follow with integer signifying
            // number of arguments, and expression as body.
#define V 8 // variables that refer to a possible outside lambda expression.
            // lambda-exprs go up twice (lambda signifier, arg-amt, body).
            // acts as normal expression; close using D.

// example using pseudo-bytecode: EC0I2I3D = (+ 2 3) where 0 is the id for '+'.

typedef struct Elem Elem;
typedef struct { char *name; Elem *body; } Fun;
typedef struct Lit Lit;
struct Lit { union { int64_t i; double f; char *s; Fun c; } x;
             unsigned int type; };
struct Elem { Lit x; struct Elem *next; struct Elem *prev; };

Fun *funs; int fsz = 0;

Elem *top; Elem *stk;

void nlstptr(Elem *s) { if(s->x.type!=NIL) {
  Elem *q = malloc(sizeof(Elem)); q->next = malloc(sizeof(Elem));
  q->next = s->next; s->next = q; s = s->next; }
  else { Elem *q = malloc(sizeof(Elem)); q->next = s; s = q; } }
void nlstptrg(void) { if(stk) { Elem *q = malloc(sizeof(Elem));
  stk->next = malloc(sizeof(Elem)); stk->next = q; stk = stk->next; } 
  else { top = stk = malloc(sizeof(Elem)); } }
void appeg(Lit l, Elem *s) { nlstptr(s); stk->x = l; }

Lit liti(int64_t i) { Lit l; l.x.i = i; l.type = INT; return l; }
Lit litsy(char *x) { Lit l; l.x.s = x; l.type = SYM; return l; }

Fun findf(char *x) { int i; for(i=0;i<fsz&&strcmp(x,funs[i].name);i++);
  return funs[i]; }

Lit tok(FILE *in) { Lit l; int c = fgetc(in); printf("%i\n",c); switch(c) {
  case I: fread(&l.x.i,sizeof(int64_t),1,in); l.type = INT; break;
  case F: fread(&l.x.f,sizeof(double),1,in); l.type = FLT; break;
  case S: { int e; fread(&e,sizeof(int64_t),1,in); fread(&l.x.s,1,e,in);
            l.type = SYM; break; }
  //case E: l.x.i = 0; l.type = EXP; break; case D: l.x.i = 0; l.type = FXP; break;
  case C: l.x.i = 0; l.type = CAL; break; case N: l.x.i = 0; l.type = NFN; break;
  //case V: fread(&l.x.i,sizeof(int64_t),1,in); l.type = VAR; break;
  //case L: l.x.i = 0; l.type = LAM; break;
  case EOF: l.x.i = 0; l.type = END; } return l; }

/*void ureader(FILE *in, Elem *s, int d) { for(int i=0;i<d;i++) { printf("."); }
  Lit l; while((l=tok(in)).type!=END&&l.type!=FXP) {
    if(l.type == EXP) { nlstptr(s); l = tok(in); if(l.type == CAL) {
        l = tok(in); if(l.type == SYM) { if(!strcmp(l.x.s,"+")) { 
            Lit q; q.x.s = "+"; q.type = PRI; s->x = q; } 
          else { printf("oops"); } } }
      s->up = malloc(sizeof(Elem)); s->up->x.type = NIL; ureader(in,s->up,d+1); }
    else if(l.type == CAL) { l = tok(in); if(l.type == SYM) {
      if(!strcmp(l.x.s,"+")) { Lit q; q.x.s = "+"; q.type = PRI; appeg(q,s); }
      else { Lit q; q.x.c = findf(l.x.s); q.type = FUN; appeg(q,s); } } }
    else if(l.type == NFN) { l = tok(in); if(l.type == SYM) {
      if(fsz==0) { funs = malloc(sizeof(Fun)); fsz++; }
      else { funs = realloc(funs,(++fsz)*sizeof(Fun)); }
      funs[fsz-1] = (Fun) { l.x.s, s }; appeg(l,s); } }
    else if(l.type == LAM) { nlstptr(s); l = tok(in); s->x = l;
      s->x.type = LAM; s->up = malloc(sizeof(Elem)); ureader(in,s->up,d+1); }
    else { appeg(l,s); } } }*/

// completely flat and RPN to remedy this: I1I2I2C0
void ureader2(FILE *in, Elem *s) {
  Lit l; while((l=tok(in)).type!=END) {
    appeg(l,s); } }

void uparse(Elem *);

/*Lit app_prim(Elem *args, char *x) { uparse(args);
  if(!strcmp(x,"+")) { Lit l; l.type = INT;
    l.x.i = args->x.x.i+args->next->x.x.i; return l; } 
  Lit l; l.type = INT; l.x.i = 0; return l; }
void uparse(Elem *s) { while(s->next) { switch(s->x.type) {
  case PRI: s->x = app_prim(s->up,s->x.x.s); break; } s = s->next; } }*/

/*void prn_lit(Lit l) { switch(l.type) { case INT: printf("%lli",l.x.i); break;
  case FLT: printf("%g",l.x.f); break; case SYM: printf("%s",l.x.s); break;
  default: printf("?"); } }
void prn_lst(Elem *s, int d) { for(int i=0;i<d;i++) { printf("."); }
  while(s->x.type!=NIL) { if(s->up->x.type!=NIL) { prn_lst(s->up,d+1); }
    prn_lit(s->x); printf(" "); s = s->next; } }*/

int main(int argc, char **argv) { FILE *f; f = fopen("test3.ul","rb");
  stk = top = malloc(sizeof(Elem)); top->x.type = NIL;
  ureader2(f,top); fclose(f); return 0; }
