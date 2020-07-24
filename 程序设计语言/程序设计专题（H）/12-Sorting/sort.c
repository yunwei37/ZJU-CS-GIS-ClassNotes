/*
 * File: sort.c
 * ------------
 * This file implements the sort.h interface using the selection
 * sort algorithm.
 */

#include <stdio.h>
#include "genlib.h"
#include "sort.h"

/* Private function prototypes */

static int travelThroughTheArray(int array[],int n);
static void SwapIntegerElements(int array[], int p1, int p2);

/*
 * Function: SortIntegerArray
 * --------------------------
 * instead of the seletion sort, we use bubble sort here. 
 */

void SortIntegerArray(int array[], int n)
{
	while(travelThroughTheArray(array,n));
}

/*
 * Function: FindSmallestInteger
 * Usage: index = FindSmallestInteger(array, low, high);
 * -----------------------------------------------------
 * This function returns 1 if there is any sway need to be done
 * during the travel through the array, or return 0 if the array is sorted.
 */

static int travelThroughTheArray(int array[],int n)
{
    int i, stat=0;
    for (i = 0; i < n-1; i++) {
        if (array[i] > array[i+1]){
        	SwapIntegerElements(array,i,i+1);
        	stat=1;
		}
    }
    return (stat);
}

/*
 * Function: SwapIntegerElements
 * Usage: SwapIntegerElements(array, p1, p2);
 * ------------------------------------------
 * This function swaps the elements in array at index
 * positions p1 and p2.
 */

static void SwapIntegerElements(int array[], int p1, int p2)
{
    int tmp;

    tmp = array[p1];
    array[p1] = array[p2];
    array[p2] = tmp;
}
