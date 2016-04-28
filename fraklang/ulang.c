#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <math.h>

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
#define DON 12
#define ADR 13

#define I 0 // 64-bit integer
#define F 1 // 64-bit floating point
#define S 2 // symbol: 64-bit integer (n) + n bytes
#define C 5 // call primitive function
#define N 6 // create function (follow with symbol)
#define L 7 // initialize lambda-expr creation (follow with integer signifying
            // number of arguments, and expression as body.
#define V 8 // variables that refer to a possible outside lambda expression.
            // lambda-exprs go up twice (lambda signifier, arg-amt, body).
            // acts as normal expression; close using D.
#define Q 9 // call user-defined function: 64-bibt integer (n) + n args.
#define D 10 // character for ending function bodies.

#define PRIMC 12

// example using pseudo-bytecode: EC0I2I3D = (+ 2 3) where 0 is the id for '+'.

typedef struct Elem Elem;
typedef struct { char *name; int id; Elem *body; } Fun;
typedef struct Lit Lit;
struct Lit { union { int64_t i; double f; char *s; Fun c; } x;
             unsigned int type; };
struct Elem { Lit x; struct Elem *next; struct Elem *prev; };

//Fun *funs; int fsz = 0;
Fun funs[] = { { "+", 0, NULL }, { "-", 1, NULL }, { "*", 2, NULL },
               { "/", 3, NULL }, { "+.", 4, NULL }, { "-.", 5, NULL},
               { "*.", 6, NULL }, { "/.", 7, NULL }, { "pow", 8, NULL },
               { "log", 9, NULL }, { "λ", 10, NULL }, { "->", 11, NULL } }; 
int fsz = PRIMC;
Fun *ufuns; int ufsz = 0;

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

char *getstr(int i, FILE *f) { char *l = malloc((i+1)*sizeof(char));
  for(int z=0;z<i;z++) { l[z] = fgetc(f); } l[i] = '\0'; return l; }

Fun findf(char *x) { int i; for(i=0;i<fsz&&strcmp(x,funs[i].name);i++);
  return funs[i]; }

Lit tok(FILE *in) { Lit l; int c = fgetc(in); printf("%i\n",c); switch(c) {
  case I: fread(&l.x.i,sizeof(int64_t),1,in); l.type = INT; break;
  case F: fread(&l.x.f,sizeof(double),1,in); l.type = FLT; break;
  case S: { int e; fread(&e,sizeof(int64_t),1,in); l.x.s = getstr(e,in);
            l.type = SYM; break; }
  //case E: l.x.i = 0; l.type = EXP; break; case D: l.x.i = 0; l.type = FXP; break;
  case C: l.x.i = 0; l.type = CAL; break; case N: l.x.i = 0; l.type = NFN; break;
  //case V: fread(&l.x.i,sizeof(int64_t),1,in); l.type = VAR; break;
  //case L: l.x.i = 0; l.type = LAM; break;
  case D: l.x.i = 0; l.type = DON; break; 
  case EOF: l.x.i = 0; l.type = END; } return l; }

Elem *fetch(Elem *se, int64_t n) { Elem *s = se;
  for(int i=0;i<n;i++) { s = s->next; } return s; }
void funcpy(Elem *b, Elem *e) {
  e->x = b->x; while(b->next->x.type!=DON) { b = b->next;
    e->next = malloc(sizeof(Elem)); e = e->next; e->x = b->x; } e->next = NULL; }
void replace(Elem *s, Elem *el) { Elem *e = el;
  while(e) { if(e->x.type==ADR) { e->x = fetch(s,e->x.x.i)->x; } } }

void uparse(Elem *, int);

int prim(Elem *s) { switch(s->x.x.c.id) { 
  case 0: case 1: case 2: case 3: { 
    Lit l; l.type = INT; uparse(s->next,2);
    Elem *e = s->next; switch(s->x.x.c.id) { 
      case 0: l.x.i = e->x.x.i+e->next->x.x.i; break;
      case 1: l.x.i = e->x.x.i-e->next->x.x.i; break;
      case 2: l.x.i = e->x.x.i*e->next->x.x.i; break;
      case 3: l.x.i = e->x.x.i/e->next->x.x.i; }
    //l.x.i = s->next->x.x.i+s->next->next->x.x.i; s->x = l;
    s->x = l; s->next = s->next->next->next; 
    free(e->next); free(e); return 1; }
  case 4: case 5: case 6: case 7: case 8: case 9: {
    Lit l; l.type = FLT; uparse(s->next,2);
    Elem *e = s->next; switch(s->x.x.c.id) {
      case 4: l.x.f = e->x.x.f+e->next->x.x.f; break;
      case 5: l.x.f = e->x.x.f-e->next->x.x.f; break;
      case 6: l.x.f = e->x.x.f*e->next->x.x.f; break;
      case 7: l.x.f = e->x.x.f/e->next->x.x.f; break;
      case 8: l.x.f = pow(e->x.x.f,e->next->x.x.f); break;
      case 9: l.x.f = log(e->next->x.x.f)/log(e->x.x.f); }
    s->x = l; s->next = s->next->next->next;
    free(e->next); free(e); return 1; }
  default: return 0; } }

/*void fun(Elem *s) { Elem *b = s->x.x.c.body->next; Elem *args = s->next;
  int argsz = b->x.x.i; uparse(s->next,argsz); Elem *e = malloc(sizeof(Elem));
  funcpy(b->next,e); replace(s->next,e); uparse(e,-1); s->x = e->x; 
  Elem *q = fetch(s->next,argsz); // memory leak here; to be fixed.
  s->next = q; }*/
void ins_bdy(Elem *se, int bsz, Elem *b) { Elem *s = se;
  //Elem *e = malloc(sizeof(Elem)); Elem *t = e;
  s->x = b->x; for(int i=0;i<bsz-1;i++) { b = b->next; 
    Elem *e = malloc(sizeof(Elem)); e->x = b->x; e->next = s->next;
    s->next = e; s = s->next; } }

// function composition
void fun(Elem *s) { Elem *b = s->x.x.c.body; int bsz = b->next->x.x.i;
  ins_bdy(s,bsz,b->next->next); uparse(s,1); }
void addf(Fun x) { if(ufuns[ufsz].id==-1) { ufuns[ufsz] = x; }
  else { ufuns = realloc(ufuns,(++ufsz+1)*sizeof(Fun)); ufuns[ufsz] = x; } }

// completely flat: C0I1I2
void ureader2(FILE *in, Elem *s) {
  Lit l; while((l=tok(in)).type!=END) {
    if(l.type == CAL) { l = tok(in); if(l.type == SYM) {
      l.type = FUN; l.x.c = findf(l.x.s); appeg(l); } }
    else if(l.type == NFN) { l = tok(in); if(l.type == SYM) {
      appeg(l); Fun x = { l.x.s, ufsz+PRIMC, s }; addf(x); } }
    else { appeg(l); } } }

void uparse(Elem *s, int a) { for(int i=0;(i<a||a==-1)&&s;i++) { //while(s) {
  if(s->x.type == FUN) { if(!prim(s)) { fun(s); } }
  s = s->next; } }

void prn_lit(Lit l) { switch(l.type) { case INT: printf("%lli",l.x.i); break;
  case FLT: printf("%g",l.x.f); break; case SYM: printf("%s",l.x.s); break;
  default: printf("?"); } }
void prn_lst(Elem *s) { 
  while(s) { prn_lit(s->x); printf(" "); s = s->next; } }

int main(int argc, char **argv) { FILE *f; f = fopen("test2.ul","rb");
  ufuns = malloc(sizeof(Fun)); ufuns[0].id = -1;
  stk = top = malloc(sizeof(Elem)); top->x.type = NIL; top->next = NULL;
  ureader2(f,top); fclose(f); stk = top; uparse(stk,-1); prn_lst(top); return 0; }
