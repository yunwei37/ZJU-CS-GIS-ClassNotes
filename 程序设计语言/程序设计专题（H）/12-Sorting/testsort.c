/*
 * File: testsort.c
 * ----------------
 * This program tests the sort.c implementation.  In this example
 * the array is considered to be a list of exam scores.  The
 * test program reads in a list of scores, sorts them, and then
 * displays the sorted list.
 */

#include <stdio.h>
#include "genlib.h"
#include "simpio.h"
#include "sort.h"

/*
 * Constants
 * ---------
 * MaxScores -- Maximum number of scores
 * Sentinel  -- Value used to terminate input
 */

#define MaxScores 100
#define Sentinel   -1

/* Private function prototypes */

static int GetIntegerArray(int array[], int max, int sentinel);
static void PrintIntegerArray(int array[], int n);

/* Main program */

main()
{
    int scores[MaxScores];
    int n;

    printf("Enter exam scores, one per line, ending\n");
    printf("with the sentinel value %d.\n", Sentinel);
    n = GetIntegerArray(scores, MaxScores, Sentinel);
    SortIntegerArray(scores, n);
    printf("\nThe sorted exam scores are:\n");
    PrintIntegerArray(scores, n);
}

/*
 * Function: GetIntegerArray
 * Usage: n = GetIntegerArray(array, max, sentinel);
 * -------------------------------------------------
 * This function reads elements into an integer array by
 * reading values, one per line, from the keyboard.  The end
 * of the input data is indicated by the parameter sentinel.
 * The caller is responsible for declaring the array and
 * passing it as a parameter, along with its allocated
 * size.  The value returned is the number of elements
 * actually entered and therefore gives the effective size
 * of the array, which is typically less than the allocated
 * size given by max.  If the user types in more than max
 * elements, GetIntegerArray generates an error.
 */

static int GetIntegerArray(int array[], int max, int sentinel)
{
    int n, value;

    n = 0;
    while (TRUE) {
        printf(" ? ");
        value = GetInteger();
        if (value == sentinel) break;
        if (n == max) Error("Too many input items for array");
        array[n] = value;
        n++;
    }
    return (n);
}

/*
 * Function: PrintIntegerArray
 * Usage: PrintIntegerArray(array, n);
 * -----------------------------------
 * This function displays the first n values in array,
 * one per line, on the console.
 */

static void PrintIntegerArray(int array[], int n)
{
    int i;

    for (i = 0; i < n; i++) {
        printf("%d\n", array[i]);
    }
}
