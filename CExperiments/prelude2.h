#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#define INT 0
#define FLT 1
#define CHR 2
#define STR 3
#define LST 4
#define LAM 5
#define FUN 6
#define SUC 7
#define SYM 8

typedef void  *A;
typedef long   Int;
typedef double Flt;
typedef char   Chr;

typedef struct Elem Elem;
typedef struct Lit Lit;
typedef Lit (*FPtr)(Elem *);

struct Lit { union { Int i; Flt f; Chr c; Chr *s; Elem *e; } x; unsigned int type; };
//struct Lit { Int i; Flt f; Chr c; Elem *e; unsigned int type; };
struct Elem { Lit lx; struct Elem *next; };
typedef struct { int t; union { char *la; FPtr f; }; } Fun;

Lit liti(long);
Lit litsy(char *);

Lit readInt(void);
Elem *list(int, ...);
Elem *nlist(Lit);
// Elem *cons(Elem *, Elem *)
Lit printAtom(Elem *);

Fun fun(FPtr);
Fun lam(char *);
Lit call(Fun, Elem *);

// == lambda storage   ===================================================//
//    lambda expressions are stored as strings that refer to function pointers.
//    it also has a small grammar to specify composition and similar actions on
//    functions.  "fun1,fun2" is an example of a composition.

// == standard library ===================================================//
