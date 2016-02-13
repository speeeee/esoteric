/* bytecode
   op-codes: 00 - pushb (1 byte, chars)
             01 - pushw (4 bytes, ints, pointers)
             02 - pushd (8 bytes, doubles, long ints)
             03 - malloc (pushes address to stack) (4 bytes)
             04 - realloc (4 bytes, 4 bytes)
             05 - free   (frees address at top of stack) (4 bytes)
             06 - mov (4 bytes)
             07 - mov_s [stack-only]
             08 - call (4 bytes)
             09 - out (4 bytes)
             0A - in (returns char)
             0B - label
             0C - ref (references stack by displacement) (4 bytes)
             0D - jns (jump if null stack) (LABEL or 4 bytes)
             0E - jmp (LABEL or 4 bytes)
             0F - terminate
             10 - pop
             11 - out_s
             12 - in_s

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

typedef long   Int;
typedef double Flt;
typedef char   Chr;

typedef struct Lit Lit;
struct Lit { union { Int i; Flt f; Chr c; Chr *s; } x;
             unsigned int type; };

Lit liti(long i) { Lit l; l.x.i = i; l.type = INT; return l; }
Lit litsy(char *x) { Lit l; l.x.s = x; l.type = SYM; return l; }

char *tok(FILE *s,int c) {
  int sz = 0; int lsz = 10; char *str = malloc(lsz*sizeof(char));
  while(!isspace(c)&&c!='('&&c!=')') { 
    if(sz==lsz) { str = realloc(str,(lsz+=10)*sizeof(char)); }
    str[sz++] = c; c = fgetc(s); } ungetc(c,stdin); str[sz] = '\0'; return str; }
long int tokl(FILE *s,int c) { 
  int sz = 0; int lsz = 10; char *str = malloc(lsz*sizeof(char));
  while(isdigit(c)) {
    if(sz==lsz) { str = realloc(str,(lsz+=10)*sizeof(char)); }
    str[sz++] = c; c = fgetc(s); } ungetc(c,stdin); str[sz] = '\0';
    long int e = atol(str); return e; }
Lit lexd(FILE *s, int eofchar) { int c;
  while(/*isspace(c = fgetc(s))*/(c = fgetc(s))==' '||c=='\t');
  if(isdigit(c)) { //Lit q; fscanf(s,"%li",&q.x.i); q.type = INT; return q; }
                   return liti(tokl(s,c)); }
  if(c==eofchar||c==EOF) { Lit e; e.x.i = EOF; e.type = END; return e; }
  else { return litsy(tok(s,c)); } }
Lit lex(FILE *s) { return lexd(s,EOF); }

void parse(FILE *f, FILE *s, int eo) { Lit l;
  while((l = lexd(s,eo)).type != END) {
  if(l.type != SYM) { printf("ERROR: must start with op-code.\n"); }
  else { if(!strcmp(l.x.s,"test")) {
           fwrite("hello world", 1, 11, f); }
         if(!strcmp(l.x.s,"terminate")) { exit(0); } } } }

int main(int argc, char **argv) {
  FILE *f; f = fopen("sample.usm","wb");
  while(1) { printf("\n> "); parse(f,stdin,'\n'); }
  fclose(f); return 0; }
