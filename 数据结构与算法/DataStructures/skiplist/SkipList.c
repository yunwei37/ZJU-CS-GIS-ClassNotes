#include <stdlib.h>
#include "SkipList.h"
#include <time.h>



/* Returns a random level for the new skiplist node we are going to create.
 * The return value of this function is between 1 and ZSKIPLIST_MAXLEVEL
 * (both inclusive), with a powerlaw-alike distribution where higher
 * levels are less likely to be returned. 
 */
int RandomLevel(void) {
	int level = 1;
	while ((rand() & 0xFFFF) < (SKIPLIST_P * 0xFFFF))
		level += 1;
	return (level < SKIPLIST_MAXLEVEL) ? level : SKIPLIST_MAXLEVEL;
}

/*
 * create a new skip list node
 */
skiplistNode *slCreateNode(int level, int key, void *obj) {
	skiplistNode *zn = malloc(sizeof(skiplistNode) + level * sizeof(struct skiplistLevel));
	zn->key = key;
	zn->data = obj;
	return zn;
}

/*
 * create a new skip list table
 */
skiplist *slCreate(void) {
	int j;
	skiplist *zsl;
	srand(clock());

	zsl = malloc(sizeof(skiplist));
	// init
	zsl->level = 1;
	zsl->length = 0;

	// create a head node with 32 levels, zero key, and NULL data
	zsl->header = slCreateNode(SKIPLIST_MAXLEVEL, -0xfffffff, NULL);
	for (j = 0; j < SKIPLIST_MAXLEVEL; j++) {
		// set the forward pointer null
		zsl->header->level[j].forward = NULL;
	}
	// set backward NULL
	zsl->header->backward = NULL;
	zsl->tail = NULL;
	return zsl;
}

/* free the list node
 */
void slFreeNode(skiplistNode *node) {
	free(node);
}

/*free the total list
*/
void slFree(skiplist *zsl) {
	skiplistNode *node = zsl->header->level[0].forward, *next;
	free(zsl->header);
	while (node) {
		next = node->level[0].forward;
		slFreeNode(node);
		node = next;
	}
	free(zsl);
}

skiplistNode *slInsert(skiplist *zsl, int key, void *obj) {
	// updata[] record the node in each level after the insert position
	skiplistNode *update[SKIPLIST_MAXLEVEL], *x;

	int i, level;
	// from the header
	x = zsl->header;

	// start searching from the top level
	for (i = zsl->level - 1; i >= 0; i--) {
		//if the next node is not null and the key is less than the current node
		while (x->level[i].forward && x->level[i].forward->key < key) {
			//find the next node
			x = x->level[i].forward;
		}
		// store the node after the insert position and go down to the next level
		update[i] = x;
	}

	if (x->key == key)
		return NULL;

	 // generate the level randomly
	level = RandomLevel();

	//if the level number is greater than current level number
	if (level > zsl->level) {
		for (i = zsl->level; i < level; i++) {
			update[i] = zsl->header;
		}
		// update the level
		zsl->level = level;
	}

	// create a node to insert
	x = slCreateNode(level, key, obj);
	for (i = 0; i < level; i++) {
		// use the node record in the update[] array to do the insert
		x->level[i].forward = update[i]->level[i].forward; 
		update[i]->level[i].forward = x;
	}

	//deal with the backward pointer  
	x->backward = (update[0] == zsl->header) ? NULL : update[0];
	// x->level[0].forward == update[0]->level[0].forward
	if (x->level[0].forward)
		x->level[0].forward->backward = x;
	else
		//the node is the tail
		zsl->tail = x;

	// increase the length
	zsl->length++;

	//return the insert node pointer
	return x;
}

/* Internal function used by zslDelete
 * used to delete a node
 */
void slDeleteNode(skiplist *zsl, skiplistNode *x, skiplistNode **update) {
	int i;
	for (i = 0; i < zsl->level; i++) {
		//if the next node is to be deleted, deal with the forward pointer
		if (update[i]->level[i].forward == x) {
			update[i]->level[i].forward = x->level[i].forward;
		}
	}
	//deal with the pointer to the next node;
	if (x->level[0].forward) {
		x->level[0].forward->backward = x->backward;
	}
	else {
		zsl->tail = x->backward;
	}
	//drease the level number
	while (zsl->level > 1 && zsl->header->level[zsl->level - 1].forward == NULL)
		zsl->level--;

	//decrease the table length
	zsl->length--;
}

int slDelete(skiplist *zsl, int key) {
	skiplistNode *update[SKIPLIST_MAXLEVEL], *x;
	int i;

	//travel the skip list to find the node to delete
	// and ,record the next node in the update[] array
	x = zsl->header;
	for (i = zsl->level - 1; i >= 0; i--) {
		while (x->level[i].forward && x->level[i].forward->key < key)
			x = x->level[i].forward;
		update[i] = x;
	}

	x = x->level[0].forward;

	if (x && key == x->key) {
		slDeleteNode(zsl, x, update);
		slFreeNode(x);
		return 1;
	}
	return 0; /* not found */
}

void* slFind(skiplist *zsl, int key) {
	skiplistNode  *x;
	int i;

	//travel the skip list to find the node
	x = zsl->header;
	for (i = zsl->level - 1; i >= 0; i--) {
		while (x->level[i].forward && x->level[i].forward->key < key)
			x = x->level[i].forward;
		if (x->level[i].forward && x->level[i].forward->key == key)
			return x->level[i].forward->data;
	}
	return NULL;
}