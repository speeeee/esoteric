// byte-code interpreter (see assembler.c for an assembler and opcodes)
// interpreter uses a stack made out of a linked-list

#include <stdio.h>
#include <stdlib.h>

#define P 4
#define PW 0
#define PF 1
#define PC 2
#define PL 3
#define MALLOCI 5
#define MALLOCF 6
#define MALLOCC 7
#define MALLOCL 8
#define REALL 9
#define FREE 10
#define MOV 11
#define MOV_S 12
#define CALL 13
#define CALL_S 14
#define OUT 15
#define IN 16
#define LABEL 17
#define REF 18
#define REF_S 19
#define JNS 20
#define JNS_S 21
#define JMP 22
#define JMP_S 23
#define TERM 24
#define POP 25
#define OUT_S 26
#define IN_S 27
#define MAIN 28

typedef int    Word;
typedef long   DWord;
typedef double Flt;
typedef char   Byte;

/*typedef struct Lit Lit;
struct Lit { union { Word i; DWord l; Flt f; Byte c; Byte *s; void *v; } x;
             unsigned int type; };*/
//typedef struct Arr { 

#define INT 0
#define FLT 1
#define CHR 2
#define SYM 3
#define END 4
#define LNG 5

#define B sizeof(char)
#define I sizeof(int)
#define L sizeof(long)
#define F sizeof(double)

int *lbls; int lsz = 0;
//typedef struct Stk { void *x; struct Stk *prev; } Stk;
typedef struct { union { char c; int i; long l; double f;
                         char *ca; int *ia; long *la; double *fa; }; } Lit;
typedef struct { char op; Lit q; } Expr;
typedef struct Stk { Lit x; struct Stk *prev; } Stk;
Expr *exprs; int esz = 0; int mn = -1;
Stk *stk;

void push_lbl(int plc) { lbls = realloc(lbls,(lsz+1)*sizeof(int));
  lbls[lsz++] = plc; }
void push_expr(char op, Lit q) { exprs = realloc(exprs,(esz+1)*sizeof(Expr));
  exprs[esz++] = (Expr) { op, q }; }
// will be better made later.
void nstkptr(void) { if(stk) { Stk *q = malloc(sizeof(Stk));
  q->prev = malloc(sizeof(Stk)); q->prev = stk; stk = q; }
  else { stk = malloc(sizeof(Stk)); } }
void push_int(int i) { nstkptr(); stk->x.i = i; }
void push_flt(double f) { nstkptr(); stk->x.f = f; }
void push_chr(char c) { nstkptr(); stk->x.c = c; }
void push_lng(long l) { nstkptr(); stk->x.l = l; }
//void push_v(void *v) { nstkptr(); stk->x.v = v; }
void *getptr(Lit x) { if(x.ia) { return x.ia; } else if(x.fa) { return x.fa; }
  else if(x.ca) { return x.ca; } else if(x.la) { return x.la; }
  else { printf("not a pointer.\n"); exit(0); } }
void pop(void) { Stk *e; e = stk; stk = stk->prev; free(e); }
void out_s(int i, Lit q) { switch(i) { 
  case INT: printf("%i",q.i); break; case FLT: printf("%lg",q.f);
  case CHR: printf("%c",q.c); break; case LNG: printf("%li",q.l); } }

/*void DESTROY(void) { if(!stk->prev) { free(stk); }
  else { printf("%i",*(int *)stk->x); } }*/
void DESTROY(Stk *x) { if (x->prev) { DESTROY(x->prev); } free(x); }

int opcodes[] = { /*push*/INT,FLT,CHR,LNG,-1,/*malloc*/INT,INT,INT,INT,
                  /*realloc*/-1,/*free*/-1,
                  /*mov*/INT,-1,/*call*/INT,-1,/*out*/INT,/*in*/-1,/*label*/INT,
                  /*ref*/INT,-1,/*jns*/INT,-1,/*jmp*/INT,-1,/*terminate*/-1,
                  /*pop*/-1,/*out_s*/-1,/*in_s*/-1,/*main*/-1 };

// pop for all necessary functions.
void parse(void) { 
  for(int i=0;i<esz;i++) { switch(exprs[i].op) {
    case PW: push_int(exprs[i].q.i); break;
    case PF: push_flt(exprs[i].q.f); break;
    case PC: push_chr(exprs[i].q.c); break;
    case PL: push_lng(exprs[i].q.l); break;
    case MALLOCI: nstkptr(); stk->x.ia = malloc(exprs[i].q.i); break;
    case MALLOCF: nstkptr(); stk->x.fa = malloc(exprs[i].q.i); break;
    case MALLOCC: nstkptr(); stk->x.ca = malloc(exprs[i].q.i); break;
    case MALLOCL: nstkptr(); stk->x.la = malloc(exprs[i].q.i); break;
    case REALL: { void *x = getptr(stk->x); x = realloc(x,exprs[i].q.i); break; }
    case FREE: free(getptr(stk->x)); pop(); break;
    case OUT_S: out_s(stk->x.i,stk->prev->x); pop(); pop(); break;
    case JMP_S: { i=stk->x.i-1; pop(); }
    case JMP: { i=exprs[i].q.i-1; }
    default: printf("what"); exit(0); } } }

void read_prgm(FILE *f) { char op;
  while((op = fgetc(f)) != TERM) { switch(op) {
    case LABEL: { int x; fread(&x,4,1,f); push_lbl(esz); break; }
    case MAIN: { mn = esz; break; }
    default: { Lit l; switch(opcodes[(int)op]) {
      case CHR: { char i; fread(&i,1,1,f); l.c = i; break; }
      case INT: { int i; fread(&i,4,1,f); l.i = i; break; }
      case FLT: { double i; fread(&i,8,1,f); l.f = i; break; }
      case LNG: { long i; fread(&i,8,1,f); l.l = i; break; } } push_expr(op,l); } } } }

int main(int argc, char **argv) { //stk = malloc(sizeof(Stk));
  exprs = malloc(sizeof(Expr));
  FILE *f; f = fopen("sample.usm","rb"); read_prgm(f); parse();
  free(exprs); /*DESTROY(stk);*/ return 0; }

/*#define P 4
#define PW 0
#define PF 1
#define PC 2
#define PL 3
#define MALLOC 5
#define REALL 6
#define FREE 7
#define MOV 8
#define MOV_S 9
#define CALL 10
#define CALL_S 11
#define OUT 12
#define IN 13
#define LABEL 14
#define REF 15
#define REF_S 16
#define JNS 17
#define JNS_S 18
#define JMP 19
#define JMP_S 20
#define TERM 21
#define POP 22
#define OUT_S 23
#define IN_S 24
#define MAIN 25*/

