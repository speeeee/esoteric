// another
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define INT 0
#define CHR 1

typedef long Int;
typedef double Flt;
typedef char *Chr;
typedef struct { union { Int i; Flt f; Chr c; } x;
                 unsigned int type; unsigned int sz; struct Elem **; } Elem;


