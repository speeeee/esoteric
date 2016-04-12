// parser for possible language...
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#define SYM 0
#define INT 1
#define FLT 2
#define END 3

typedef struct Lit Lit;
struct Lit { union { int64_t i; double f; char *s; } x;
             unsigned int type; };
typedef struct Elem { Lit x; struct Elem *up; struct Elem *dw;
                      struct Elem *prev; } Elem;

Lit liti(int64_t i) { Lit l; l.x.i = i; l.type = INT; return l; }
Lit litsy(char *x) { Lit l; l.x.s = x; l.type = SYM; return l; }

void write_c(char c, FILE *f) { fwrite(&c,1,1,f); }
void n_out(Lit x, int n, FILE *o) { void *q; switch(x.type) {
  case INT: q = &x.x.i; break; case FLT: q = &x.x.f; default: exit(0); }
  fwrite(q,n,1,o); }  

char *tok(FILE *s,int c) {
  int sz = 0; int lsz = 10; char *str = malloc(lsz*sizeof(char));
  while(!isspace(c)&&c!='('&&c!=')'&&c!=EOF) { 
    if(sz==lsz) { str = realloc(str,(lsz+=10)*sizeof(char)); }
    str[sz++] = c; c = fgetc(s); }
    if(c!=EOF) { fseek(s,-1,SEEK_CUR); } str[sz] = '\0'; return str; }
Lit tokl(FILE *s,int c) { 
  int sz = 0; int lsz = 10; char *str = malloc(lsz*sizeof(char));
  while(isdigit(c)&&c!='w'&&c!='d'&&c!='f'&&c!='b') {
    if(sz==lsz) { str = realloc(str,(lsz+=10)*sizeof(char)); }
    str[sz++] = c; c = fgetc(s); } str[sz] = '\0'; Lit e;
    switch(c) { case 'w': e.x.i = atoi(str); e.type = INT; break;
                case 'f': e.x.f = atof(str); e.type = FLT; break;
                default: fseek(s,-1,SEEK_CUR); e.x.i = atoi(str); e.type = INT; }
    return e; }
Lit lexd(FILE *s, int eofchar) { int c;
  while(/*isspace(c = fgetc(s)));*/(c = fgetc(s))==' '||c=='\t'/*||c=='\n'*/);
  if(isdigit(c)) { //Lit q; fscanf(s,"%li",&q.x.i); q.type = INT; return q; }
                   return tokl(s,c); }
  if(c==eofchar||c==EOF) { Lit e; e.x.i = EOF; e.type = END; return e; }
  else { char *x = tok(s,c); return litsy(x); } }
// ** make better search here ** //
Lit lex(FILE *s) { return lexd(s,EOF); }

Elem *stk;

void nstkptr(Elem *s) { if(s) { Elem *q = malloc(sizeof(Elem));
  q->prev = malloc(sizeof(Elem)); q->prev = s; s = q; }
  else { s = malloc(sizeof(Elem)); } }
void nstkptrg(void) { if(stk) { Elem *q = malloc(sizeof(Elem));
  q->prev = malloc(sizeof(Elem)); q->prev = stk; stk = q; }
  else { stk = malloc(sizeof(Elem)); } }

void pushg(Lit l) { nstkptrg(); stk->x = l; }
void pushi(Elem *s, int64_t i) { nstkptr(s); stk->x.type = INT; stk->x.x.i = i; }
void pushf(Elem *s, double f) { nstkptr(s); stk->x.type = FLT; stk->x.x.f = f; }
void pop(Elem *s) { Elem *e; e = s; s = s->prev; free(e); }

// first pass through file which linearly places the program retrieved into
// stk.
void read(FILE *i, int eo) { Lit l; while((l=lexd(i,eo)).type!=END) {
  pushg(l); } }

// second pass through program which appropriately branches and aliases functions
// while also defining new functions by use of the define function.

// third pass through program which actually evaluated the contents as expected.
// the first and second pass allow for a faster third pass hopefully.

int main(int argc, char **argv) { /*FILE *f;
  char *in; in = malloc((strlen(argv[2])+3)*sizeof(char)); strcpy(in,argv[2]);
  strcat(in,".fl"); f = fopen(in,"r"); read(f,EOF); fclose(f); return 0;*/
  printf("> "); read(stdin,'\n'); return 0; }