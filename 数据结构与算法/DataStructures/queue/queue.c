/*
 *	File: queue.c
 *	Author: zhengyusheng 
 *	Date: 25/03/19 22:34
 *	Description: This file implements the queue.h abstraction using an array.

 */

#include <stdio.h>
#include <stdlib.h>

#include "queue.h"

/*
 * Constants:
 * ----------
 * MaxQueueSize -- Maximum number of elements in the queue
 */

#define MaxQueueSize 10

/*
 * Type: queueCDT
 * --------------
 * This type provides the concrete counterpart to the queueADT.
 * The representation used here consists of an array coupled
 * with an integer indicating the effective size.  This
 * representation means that Dequeue must shift the existing
 * elements in the queue.
 */

struct queueCDT {
    void *array[MaxQueueSize];
    int head;
    int tail;
};

/* Exported entries */

/*
 * Function: NewQueue
 * ------------------
 * This function allocates and initializes the storage for a
 * new queue.
 */

queueADT NewQueue(void)
{
    queueADT queue;
    queue = (queueADT)malloc(sizeof(struct queueCDT));
    queue->head = 0;
    queue->tail = 0;
    return queue;
}

/*
 * Function: FreeQueue
 * -------------------
 * This function frees the queue storage.
 */

void FreeQueue(queueADT queue)
{
    free(queue->array);
    free(queue);
}

/*
 * Function: Enqueue
 * -----------------
 * This function adds a new element to the queue.
 */

void Enqueue(queueADT queue, void *obj)
{
    if (queue->head == (queue->tail+1)%MaxQueueSize) {
        printf("Enqueue called on a full queue ");
        return;
    }
    queue->array[queue->tail++] = obj;
    if(queue->tail == MaxQueueSize) queue->tail=0;
}

/*
 * Function: Dequeue
 * -----------------
 * This function removes and returns the data value at the
 * head of the queue.
 */

void *Dequeue(queueADT queue)
{
    void *result = NULL;
    if ( queue->head == queue->tail ){
    	printf("Dequeue of empty queue ");
    	return (result);
	} 
    result = queue->array[queue->head++];
	if(queue->head == MaxQueueSize) queue->head=0;
    return (result);
}

/*
 * Function: QueueLength
 * ---------------------
 * This function returns the number of elements in the queue.
 */

int QueueLength(queueADT queue)
{
    return (queue->tail - queue->head + MaxQueueSize) % MaxQueueSize;
}

/*----------------------------
 * test main function
 */
 
 int main(){
 	queueADT queue = NewQueue();
 	int a[10];
 	int i,tmp;
 	printf("size: %d\n",QueueLength(queue));
 	for(i=0;i<10;++i){
 		a[i]=i;
 		Enqueue(queue, a+i);
 		printf("%d\n",a[i]);
	}
 	printf("size: %d\n",QueueLength(queue));
	for(i=0;i<11;++i){
		if((tmp = Dequeue(queue))!=NULL)
 		printf("%d\n",*(int*)tmp);
	}
 	printf("size: %d\n",QueueLength(queue));	
	for(i=0;i<6;++i){
 		a[i]=i;
 		Enqueue(queue, a+i);
 		printf("%d\n",a[i]);
	}
 	printf("size: %d\n",QueueLength(queue));	
	for(i=0;i<4;++i){
		if((tmp = Dequeue(queue))!=NULL)
 		printf("%d\n",*(int*)tmp);
	}
 	printf("size: %d\n",QueueLength(queue));	
	for(i=0;i<9;++i){
 		a[i]=i;
 		Enqueue(queue, a+i);
 		printf("%d\n",a[i]);
	}
 	printf("size: %d\n",QueueLength(queue));	
	for(i=0;i<10;++i){
		if((tmp = Dequeue(queue))!=NULL)
 		printf("%d\n",*(int*)tmp);
	}
 	printf("size: %d\n",QueueLength(queue));	
 	return 0;
 }
