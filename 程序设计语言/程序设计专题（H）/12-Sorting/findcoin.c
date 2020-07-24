/*
 * File: findcoin.c
 * ----------------
 * This program uses a search operation to report the names of
 * legal U.S. coins.
 */

#include <stdio.h>
#include <ctype.h>
#include "simpio.h"
#include "genlib.h"

/*
 * Global variables
 * ----------------
 * coinNames  -- Array containing the name of each coin
 * coinValues -- Array containing the corresponding coin values
 * nCoins     -- Number of distinct coins
 */

static string coinNames[] = {
    "penny",
    "nickel",
    "dime",
    "quarter",
    "half-dollar",
};

static int coinValues[] = { 1, 5, 10, 25, 50 };

static int nCoins = sizeof coinValues / sizeof coinValues[0];

/* Private function declarations */

static int FindIntegerInArray(int key, int array[], int n);

/* Main program */

main()
{
    int value, index;

    printf("This program looks up names of U.S. coins.\n");
    printf("Enter coin value: ");
    value = GetInteger();
    index = FindIntegerInArray(value, coinValues, nCoins);
    if (index == -1) {
        printf("There is no such coin.\n");
    } else {
        printf("That's called a %s.\n", coinNames[index]);
    }
}

/*
 * Function: FindIntegerInArray
 * Usage: index = FindIntegerInArray(key, array, n);
 * -----------------------------------------------
 * This function returns the index of the first element in the
 * specified array of integers that matches the value key.  If
 * key does not appear in the first n elements of the array,
 * FindIntegerInArray returns -1.
 */

static int FindIntegerInArray(int key, int array[], int n)
{
    int i;

    for (i = 0; i < n; i++) {
        if (key == array[i]) return (i);
    }
    return (-1);
}
