/*
 * File: mileage.c
 * ---------------
 * This program simulates the operation of a mileage table.
 */

#include <stdio.h>
#include <ctype.h>
#include "simpio.h"
#include "strlib.h"
#include "genlib.h"

/*
 * Constants
 * ---------
 * NCities -- Number of cities
 */

#define NCities 12

/*
 * Global variable: mileageTable
 * -----------------------------
 * This table is a two-dimensional array that holds the distance
 * between the cities whose indices are the row and column numbers.
 * Data source: Rand McNally Road Atlas.
 */

static int mileageTable[NCities][NCities] = {
    {   0,1108, 708,1430, 732, 791,2191, 663, 854, 748,2483,2625},
    {1108,   0, 994,1998, 799,1830,3017,1520, 222, 315,3128,3016},
    { 708, 994,   0,1021, 279,1091,2048,1397, 809, 785,2173,2052},
    {1430,1998,1021,   0,1283,1034,1031,2107,1794,1739,1255,1341},
    { 732, 799, 279,1283,   0,1276,2288,1385, 649, 609,2399,2327},
    { 791,1830,1091,1034,1276,   0,1541,1190,1610,1511,1911,2369},
    {2191,3017,2048,1031,2288,1541,   0,2716,2794,2703, 387,1134},
    { 663,1520,1397,2107,1385,1190,2716,   0,1334,1230,3093,3303},
    { 854, 222, 809,1794, 649,1610,2794,1334,   0, 101,2930,2841},
    { 748, 315, 785,1739, 609,1511,2703,1230, 101,   0,2902,2816},
    {2483,3128,2173,1255,2399,1911, 387,3093,2930,2902,   0, 810},
    {2625,3016,2052,1341,2327,2369,1134,3303,2841,2816, 810,   0},
};

/*
 * Global variable: cityTable
 * --------------------------
 * The array cityTable holds the names of the cities used in the
 * mileage table.
 */

static string cityTable[NCities] = {
    "Atlanta",
    "Boston",
    "Chicago",
    "Denver",
    "Detroit",
    "Houston",
    "Los Angeles",
    "Miami",
    "New York",
    "Philadelphia",
    "San Francisco",
    "Seattle",
};

/* Private function declarations */

static int GetCity(string prompt);
static int FindStringInArray(string key, string array[], int n);

/* Main program */

main()
{
    int city1, city2;

    printf("This program looks up intercity mileage.\n");
    city1 = GetCity("Enter name of city #1: ");
    city2 = GetCity("Enter name of city #2: ");
    printf("Distance between %s", cityTable[city1]);
    printf(" and %s:", cityTable[city2]);
    printf(" %d miles.\n", mileageTable[city1][city2]);
}

/*
 * Function: GetCity
 * Usage: n = GetCity(prompt);
 * ---------------------------
 * This function prompts the user for a city name, reads in a
 * string, and returns the index corresponding to that city,
 * if it exists.  If an undefined city name is entered, the
 * user is given a chance to retry.
 */

static int GetCity(string prompt)
{
    string cityName;
    int index;

    while (TRUE) {
        printf("%s", prompt);
        cityName = GetLine();
        index = FindStringInArray(cityName, cityTable, NCities);
        if (index >= 0) break;
        printf("Unknown city name -- try again.\n");
    }
    return (index);
}

/*
 * Function: FindStringInArray
 * Usage: index = FindStringInArray(key, array, n);
 * ------------------------------------------------
 * This function returns the index of the first element in the
 * specified array of strings that matches the value key.  If
 * key does not appear in the first n elements of the array,
 * FindStringInArray returns -1.
 */

static int FindStringInArray(string key, string array[], int n)
{
    int i;

    for (i = 0; i < n; i++) {
        if (StringEqual(key, array[i])) return (i);
    }
    return (-1);
}
