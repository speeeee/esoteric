#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef struct Lit { char *val; struct Lit **vals; } Lit;

void swap(void); void drop(void); void push(Lit);
void push_int(int); void push_str(char *);
void RSTK_ADD(void); void RSTK_SUB(void); void RSTK_MUL(void); void RSTK_DIV(void);

// a sample lambda-expr generated by the language.  Lamdbas are called when the
// macro, RSTK_CALL/2, is given a non-empty string as its second input.
#define RSTK_LAMBDA_1(x) swap(); drop();

// any list in rstk is by default a lambda.

// `stk' is the target stack.  Everything is a string representation of itself.
// Lambdas are represented by strings, and are named after their macro equivalent.
Lit *stk; int top = 0;
// initialize `stk'.
void init(void) { stk = malloc(100*sizeof(Lit)); }

// for calling lambdas, RSTK_CALL/2 is used.  This matches any strings that match
// their respective lambda names.
void RSTK_CALL(char *lambda) {
  if(!strcmp(lambda,"RSTK_LAMBDA_1")) { RSTK_LAMBDA_1(); } }

// stdlib
// index of top element.
// int top(void) { int i; for(i=0; stk[i].val||stk[i].vals; i++); return i; }
void push(Lit x) { if(top>sizeof(stk)/sizeof(Lit)) {
                     realloc(stk, sizeof(stk)/sizeof(Lit)*2); }
                   stk[top] = x; top++; }
void push_int(int x) { char *str; sprintf(str,"%i",x); 
                       Lit n = (Lit) { str, NULL }; push(n); }
void push_str(char *x) { Lit n = (Lit) { x, NULL }; push(n); }
void swap(void) { Lit temp = stk[top-1]; stk[top-1] = stk[top-2];
                  stk[top-2] = temp; }
void drop(void) { stk[top-1] = (Lit) { NULL, NULL }; top--; }
void RSTK_ADD(void) { int res = atoi(stk[top-1].val)+atoi(stk[top-2].val);
                      drop(); drop(); push_int(res); }

void outstk(void) { for(int i=0; i<top; i++) { printf("%s ", stk[i].val); }
                    printf("\n"); }

int main(int argc, char **argv) { 
  init();
  //stk[top] = (Lit) { "hello", NULL }; top++;
  push_str("hello");
  outstk();
  //stk[top] = (Lit) { "hallo", NULL }; top++;
  push_str("hallo");
  outstk();
  RSTK_CALL("RSTK_LAMBDA_1");
  outstk();
  printf("%s\n", stk[0].val); return 0; }
