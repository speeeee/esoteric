// byte-code interpreter (see assembler.c for an assembler and opcodes)
// interpreter uses a stack made out of a linked-list

#include <stdio.h>
#include <stdlib.h>

#define P 4
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
#define MAIN 25

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
typedef struct Stk { void *x; struct Stk *prev; } Stk;
typedef struct { union { char c; int i; long l; double f;
                         char *ca; int *ia; long *la; double *fa; }; } Lit;
typedef struct { char op; Lit q; } Expr;
Expr *exprs; int esz = 0; int mn = -1;

void push_lbl(int plc) { lbls = realloc(lbls,(lsz+1)*sizeof(int));
  lbls[lsz++] = plc; }
void push_expr(char op, Lit q) { exprs = realloc(exprs,(esz+1)*sizeof(Expr));
  exprs[esz++] = (Expr) { op, q }; }
/*void push(void *x) { if(stk->x) { Stk *q = malloc(sizeof(Stk));
  q->prev = malloc(sizeof(Stk)); q->prev = stk; stk = q; stk->x = x; }
  else { stk->x = x; } }
int top_int(void) { int x = *(int *)stk->x; return x; }
void pop(void) { if(stk->prev) { free(stk->x); stk = stk->prev; }
  else { printf("error: null stack.\n"); } }

void DESTROY(void) { if(!stk->prev) { free(stk); }
  else { printf("%i",*(int *)stk->x); } }*/

int opcodes[] = { /*push*/INT,FLT,CHR,LNG,/*malloc*/0,/*realloc*/0,/*free*/0,
                  /*mov*/INT,0,/*call*/INT,0,/*out*/INT,/*in*/0,/*label*/INT,
                  /*ref*/INT,0,/*jns*/INT,0,/*jmp*/INT,0,/*terminate*/0,/*pop*/0,
                  /*out_s*/0,/*in_s*/0,/*main*/0 };


/*void read_prgm(FILE *f) { char op; int mn = 0;
  while((op = fgetc(f)) != TERM) { printf("%i",op); if(mn) { switch(op) {
    case PW: { int *x = malloc(sizeof(int)); fread(x,I,1,f); push(x); break; }
    case PF: { double *x = malloc(sizeof(double)); fread(x,F,1,f); push(x); break; }
    case PC: { char *x = malloc(sizeof(char)); fread(x,B,1,f); push(x); break; }
    case PL: { long *x = malloc(sizeof(long)); fread(x,L,1,f); push(x); break; }
    case MALLOC: { int x = top_int(); pop(); push(malloc(x)); break; } } }
    else if(op==MAIN) { mn = 1; }
    else if(op==LABEL) { int adr; fread(&adr,4,1,f);
      push_lbl(adr); } } DESTROY(); }*/

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
  FILE *f; f = fopen("sample.usm","rb"); read_prgm(f); free(exprs); return 0; }

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

