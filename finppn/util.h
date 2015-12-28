// utility functions

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h>

typedef int (*predicate)(int);

char *join(char *, char *, char *);
char *tok(predicate, int);

int num(int); int str(int); int sym(int);
