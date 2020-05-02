/*
 * File: queue.h
 * -------------
 * This file provides an interface to a simple queue
 * abstraction.
 */

#ifndef _queue_h
#define _queue_h

/*
 * Type: queueADT
 * --------------
 * This line defines the abstract queue type as a pointer to
 * its concrete counterpart.  Clients have no access to the
 * underlying representation.
 */

typedef struct queueCDT *queueADT;

/*
 * Function: NewQueue
 * Usage: queue = NewQueue();
 * --------------------------
 * This function allocates and returns an empty queue.
 */

queueADT NewQueue(void);

/*
 * Function: FreeQueue
 * Usage: FreeQueue(queue);
 * ------------------------
 * This function frees the storage associated with queue.
 */

void FreeQueue(queueADT queue);

/*
 * Function: Enqueue
 * Usage: Enqueue(queue, obj);
 * ---------------------------
 * This function adds obj to the end of the queue.
 */

void Enqueue(queueADT queue, void *obj);

/*
 * Function: Dequeue
 * Usage: obj = Dequeue(queue);
 * ----------------------------
 * This function removes the data value at the head of the queue
 * and returns it to the client.  Dequeueing an empty queue is
 * an error.
 */

void *Dequeue(queueADT queue);

/*
 * Function: QueueLength
 * Usage: n = QueueLength(queue);
 * ------------------------------
 * This function returns the number of elements in the queue.
 */

int QueueLength(queueADT queue);

#endif
