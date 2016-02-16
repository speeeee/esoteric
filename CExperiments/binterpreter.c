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
#define OUT 11
#define IN 12
#define LABEL 13
#define REF 14
#define JNS 15
#define JMP 16
#define TERM 17
#define POP 18
#define OUT_S 19
#define IN_S 20
#define MAIN 21

typedef int    Word;
typedef long   DWord;
typedef double Flt;
typedef char   Byte;

typedef struct Lit Lit;
struct Lit { union { Word i; DWord l; Flt f; Byte c; Byte *s; void *v; } x;
             unsigned int type; };
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

typedef struct { int op; Lit x; } expr;
expr *no_evals; int esz = 0;
int *lbls; int lsz = 0;
typedef struct Stk { void *x; struct Stk *prev; } Stk;
Stk *stk;

void push_lbl(int plc) { lbls = realloc(lbls,(lsz+1)*sizeof(int));
  lbls[lsz++] = plc; }
/*void push(void *x, int sz) { Lit l; l.type = sz;
  switch(sz) { case INT: l.x.i = (int)x; break; case FLT: l.x.f = (double)x; break;
               case CHR: l.x.c = (char)x; break; case LNG: l.x.l = (long)x; break;
               case VOID: l.x.v = x; break; }
  stk = realloc(stk,(ssz+1)*sizeof(Lit)); stk[ssz++] = l; }*/
/*void push(void *x, int type) { Lit l; l.type = type;
  switch(sz) { case INT: l.x.i = (int)x; break; case FLT: l.x.f = (double)x; break;
               case CHR: l.x.c = (char)x; break; case LNG: l.x.l = (long)x; break;
               case VOID: l.x.v = x; break; }*/
void push(void *x) { if(stk->x) { Stk *q = malloc(sizeof(Stk));
  q->prev = malloc(sizeof(Stk)); q->prev = stk; stk = q; stk->x = x; }
  else { stk->x = x; } }
int top_int(void) { int x = *(int *)stk->x; return x; }
void pop(void) { if(stk->prev) { free(stk->x); stk = stk->prev; }
  else { printf("error: null stack.\n"); } }

void DESTROY(void) { if(!stk->prev) { free(stk); } }

/*typedef struct { char *name; int argsz; } OpC;
OpC opcodes[] = { { "pushw", I }, { "pushf", F }, { "pushc", B },
                  { "pushl", L }, { "malloc", I }, 
                  { "realloc", I }, { "free", 0 }, { "mov", I },
                  { "mov_s", 0 }, { "call", I }, { "out", I },
                  { "in", 0 }, { "label", I },
                  { "ref", I }, { "jns", I }, { "jmp", I },
                  { "terminate", 0 }, { "pop", 0 }, { "out_s", 0 },
                  { "in_s", 0 } };*/

void read_prgm(FILE *f) { char op; int mn = 0;
  while((op = fgetc(f)) != TERM) { printf("%i",op); if(mn) { switch(op) {
    case PW: { int x; fread(&x,I,1,f); push(&x); break; }
    case PF: { double x; fread(&x,F,1,f); push(&x); break; }
    case PC: { char x; fread(&x,B,1,f); push(&x); break; }
    case PL: { long x; fread(&x,L,1,f); push(&x); break; }
    case MALLOC: { int x = top_int(); pop(); push(malloc(x)); break; } } }
    else if(op==MAIN) { mn = 1; }
    else if(op==LABEL) { int adr; fread(&adr,4,1,f);
      push_lbl(adr); } } DESTROY(); }

int main(int argc, char **argv) { stk = malloc(sizeof(Stk));
  FILE *f; f = fopen("sample.usm","rb"); read_prgm(f); return 0; }

/*#define PW 0
#define PF 1
#define PC 2
#define PL 3
#define MALLOC 4
#define REALL 5
#define FREE 6
#define MOV 7
#define MOV_S 8
#define CALL 9
#define OUT 10
#define IN 11
#define LABEL 12
#define REF 13
#define JNS 14
#define JMP 15
#define TERM 16
#define POP 17
#define OUT_S 18
#define IN_S 19
#define MAIN 20*/

