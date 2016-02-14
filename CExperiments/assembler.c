/* bytecode
   op-codes: 00 - push 
             -- - pushw (4 bytes, ints, pointers)
             -- - pushd (8 bytes, doubles, long ints)
             01 - malloc (pushes address to stack) (4 bytes)
             02 - realloc (4 bytes) [4-byte address from stack]
             03 - free   (frees address at top of stack) (4 bytes)
             04 - mov (4 bytes) [address from stack]
             05 - mov_s [stack-only]
             06 - call (4 bytes)
             07 - out (4 bytes)
             08 - in (returns char)
             09 - label
             0A - ref (references stack by displacement) (4 bytes)
             0B - jns (jump if null stack) (LABEL or 4 bytes)
             0C - jmp (LABEL or 4 bytes)
             0D - terminate
             0E - pop
             0F - out_s
             10 - in_s

   constants: TSTK - always points to the top of the stack. Note that referencing
                     this does not pop.

   sample:
   label end
   terminate
   label main        ; labels are unnecessary, but good for gotos. 
   pushw 32
   pushw 33
   pushw 34
   label loop
   jns end
   out_s
   pop
   jmp loop 
  
   or: 0B 00000000 0F 00000000 0B 00000001 01 00000020 01 00000021 01 00000022
       0B 00000002 0D 00000000 09 00000000 10 00000000 0E 00000023
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define INT 0
#define FLT 1
#define CHR 2
#define SYM 3
#define END 4
#define LNG 5

typedef struct { char *name; int argsz; } OpC;
OpC opcodes[] = { { "push", -1 /* varies */ }, { "pushw", -1 }, { "pushf", -1 },
                  { "pushc", -1 }, { "pushl", -1 }, { "malloc", 4 }, 
                  { "realloc", 4 }, { "free", 0 }, { "mov", 4 },
                  { "mov_s", 0 }, { "call", 4 }, { "out", 4 },
                  { "in", 0 }, { "label", -1 /* varies */ },
                  { "ref", 4 }, { "jns", 4 }, { "jmp", 4 },
                  { "terminate", 0 }, { "pop", 0 }, { "out_s", 0 },
                  { "in_s", 0 } };
// current next-label number
int lc = 0;
// defined labels
char **ls; int lsz = 0;

void addLabel(char *x) { ls = realloc(ls,(lsz+1)*sizeof(char *)); 
  ls[lsz] = malloc(sizeof(char)*strlen(x));
  ls[lsz++] = x; }

typedef int    Word;
typedef long   DWord;
typedef double Flt;
typedef char   Byte;

typedef struct Lit Lit;
struct Lit { union { Word i; DWord l; Flt f; Byte c; Byte *s; } x;
             unsigned int type; };

Lit liti(long i) { Lit l; l.x.i = i; l.type = INT; return l; }
Lit litsy(char *x) { Lit l; l.x.s = x; l.type = SYM; return l; }

void write_c(char c, FILE *f) { fwrite(&c,1,1,f); }

char *tok(FILE *s,int c) {
  int sz = 0; int lsz = 10; char *str = malloc(lsz*sizeof(char));
  while(!isspace(c)&&c!='('&&c!=')') { 
    if(sz==lsz) { str = realloc(str,(lsz+=10)*sizeof(char)); }
    str[sz++] = c; c = fgetc(s); } ungetc(c,stdin); str[sz] = '\0'; return str; }
Lit tokl(FILE *s,int c) { 
  int sz = 0; int lsz = 10; char *str = malloc(lsz*sizeof(char));
  while(isdigit(c)&&c!='w'&&c!='d'&&c!='f'&&c!='b') {
    if(sz==lsz) { str = realloc(str,(lsz+=10)*sizeof(char)); }
    str[sz++] = c; c = fgetc(s); } str[sz] = '\0'; Lit e;
    switch(c) { case 'w': e.x.i = atoi(str); e.type = INT; break;
                case 'd': e.x.l = atol(str); e.type = LNG; break;
                case 'f': e.x.f = atof(str); e.type = FLT; break;
                case 'b': e.x.c = (char) atoi(str); e.type = CHR; break;
                default: ungetc(c,stdin); e.x.i = atoi(str); e.type = INT; }
    return e; }
Lit lexd(FILE *s, int eofchar) { int c;
  while(/*isspace(c = fgetc(s))*/(c = fgetc(s))==' '||c=='\t');
  if(isdigit(c)) { //Lit q; fscanf(s,"%li",&q.x.i); q.type = INT; return q; }
                   return tokl(s,c); }
  if(c==eofchar||c==EOF) { Lit e; e.x.i = EOF; e.type = END; return e; }
  else { char *x = tok(s,c);
    for(int i=0;i<lsz;i++) { if(!strcmp(x,ls[i])) { return liti(i); } }
    return litsy(x); } }
Lit lex(FILE *s) { return lexd(s,EOF); }

void parse(FILE *o, FILE *i, int eo) { Lit l;
  while((l = lexd(i,eo)).type != END) {
  if(l.type != SYM) { printf("ERROR: must start with op-code.\n"); }
  else { if(!strcmp(l.x.s,"push")) { Lit l = lexd(i,eo);
           switch(l.type) { case INT: write_c(0,o); 
                              fwrite(&l.x.i,sizeof(int),1,o); break;
                            case FLT: write_c(1,o); 
                              fwrite(&l.x.f,sizeof(double),1,o); break;
                            case CHR: write_c(2,o);
                              fwrite(&l.x.s,sizeof(char),1,o); break;
                            case LNG: write_c(3,o);
                              fwrite(&l.x.l,sizeof(long),1,o); break; 
                            default: printf("error\n"); exit(0); } }
         else if(!strcmp(l.x.s,"label")) { write_c(9,o); l = lexd(i,eo);
           if(l.type == SYM) { addLabel(l.x.s); } 
           else { printf("error\n"); exit(0); } }
         else if(!strcmp(l.x.s,":q")) { exit(0); } } } }

int main(int argc, char **argv) { ls = malloc(sizeof(char *));
  FILE *f; f = fopen("sample.usm","wb");
  while(1) { printf("\n> "); parse(f,stdin,'\n'); }
  fclose(f); return 0; }
