#pragma once
#ifndef SKIPLIST_H_
#define SKIPLIST_H_

#define SKIPLIST_MAXLEVEL 32 /* Should be enough for 2^32 elements */
#define SKIPLIST_P 0.25      /* Skiplist P = 1/4 */

/*  a specialized version of Skiplists */
//data structure of the listnode
typedef struct skiplistNode {
	// data
	void *data;
	// key: to compare
	int key;
	// backward pointer
	struct skiplistNode *backward;
	// the levels of the skiplist
	struct skiplistLevel {
		// forward pointer
		struct skiplistNode *forward;
	} level[];
} skiplistNode;

//data structure of the skiplist
typedef struct skiplist {
	// head and tail node
	struct skiplistNode *header, *tail;
	// number of nodes
	unsigned long length;
	// the max level number
	int level;
} skiplist;

//
skiplist *slCreate(void);

void slFree(skiplist *zsl);

skiplistNode *slInsert(skiplist *zsl, int key, void *obj);

int slDelete(skiplist *zsl, int key);

void* slFind(skiplist *zsl, int key);

#endif