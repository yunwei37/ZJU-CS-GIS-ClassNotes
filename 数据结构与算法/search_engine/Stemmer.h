/*this file is not changed as well*/
#ifndef _STEMMER_H_
#define _STEMMER_H_


#include <string.h>  /* for memmove */
#include <stdio.h>
#include <stdio.h>
#include <stdlib.h>      /* for malloc, free */
#include <ctype.h>       /* for isupper, islower, tolower */
#define TRUE 1
#define FALSE 0
#define INC 0           /* size units in which s is increased */
#define LETTER(ch) (isupper(ch) || islower(ch))

static int i_max = INC;  /* maximum offset in s */
static char * b;       /* buffer for word to be stemmed */
static int k, k0, j;     /* j is a general offset into the string */
						 /* cons(i) is TRUE <=> b[i] is a consonant. */
static char * s;         /* a char * (=string) pointer; passed into b above */

static int cons(int i);
static int m();
static int vowelinstem();
static int doublec(int j);
static int cvc(int i);
static int ends(char * s);
static void setto(char * s);
static void r(char * s);
static void step1ab();
static void step1c();
static void step2();
static void step3();
static void step4();
static void step5();
int stem(char * p, int i, int j);
void increase_s();

void stemfile(FILE * f, FILE * out);

#endif
