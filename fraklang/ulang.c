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
  else { Elem *q = malloc(sizeof(Elem)); //q->next = malloc(sizeof(Elem));
         q->next = s; s = q; } }
/*void nlstptrg(void) { if(stk->x.type!=NIL) { Elem *q = malloc(sizeof(Elem));
  q->next = stk->next; stk->next = q; stk = q; } 
  else { Elem *q = malloc(sizeof(Elem)); q->next = stk; top = q; } }*/
void nlstptrg(void) { if(stk->x.type!=NIL) { Elem *q = malloc(sizeof(Elem));
  stk->next = q; stk = stk->next; stk->next = NULL; } }
void appeg(Lit l) { nlstptrg(); stk->x = l; }

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

// completely flat and RPN to remedy this: I1I2I2C0
void ureader2(FILE *in, Elem *s) {
  Lit l; while((l=tok(in)).type!=END) {
    appeg(l); } }

void uparse(Elem *);

void prn_lit(Lit l) { switch(l.type) { case INT: printf("%lli",l.x.i); break;
  case FLT: printf("%g",l.x.f); break; case SYM: printf("%s",l.x.s); break;
  default: printf("?"); } }
void prn_lst(Elem *s) { 
  while(s) { prn_lit(s->x); printf(" "); s = s->next; } }

int main(int argc, char **argv) { FILE *f; f = fopen("test.ul","rb");
  stk = top = malloc(sizeof(Elem)); top->x.type = NIL; top->next = NULL;
  ureader2(f,top); fclose(f); prn_lst(top); return 0; }
