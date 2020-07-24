/* list.h: the impliment of a list without headnode.
 * version 1.0 by ZhengYusheng 25/3/2018
 */


#ifndef _LIST_H
#define _LIST_H

#include <stdio.h>
#include <stdlib.h>

/* the defination of the list structure*/
#define ERROR NULL
typedef int ElementType; 
typedef struct LNode *PtrToLNode;
struct LNode {
    ElementType Data;
    PtrToLNode Next;
};
typedef PtrToLNode Position;
typedef PtrToLNode List;

/* Returns the location of the first X in 
 * the linear table. If not, return to ERROR.
 */
Position Find( List L, ElementType X );

/* Insert X before the node pointed to by location P, 
 * and return the list header of the linked list. 
 * If parameter P points to an illegal location, 
 * print "Wrong Position for Insertion" and return ERROR.
 */ 
List Insert( List L, ElementType X, Position P );

/* Delete the element of position P and return to the 
 * list header of the linked list. If parameter P points to an illegal location, 
 * print "Wrong Position for Deletion" and return ERROR.
 * List Delete( List L, Position P );
 */
List Delete( List L, Position P );

Position Find( List L, ElementType X ){
	while(L&&L->Data!=X)//search for the next node;
		L=L->Next;
	return L;
} 
 
List Insert( List L, ElementType X, Position P ){
	Position pre=L,a;
	a=(Position)malloc(sizeof(struct LNode));
	a->Data=X;
	a->Next=P;
	if(P==L)	return a;//insert at the head node;
	while(pre->Next&&pre->Next!=P)//find the pre node if insertion
		pre=pre->Next;
	if(P&&!pre->Next){
		printf("Wrong Position for Insertion\n");
		return ERROR;//if can not find the position;
	}
	else
		pre->Next=a;
		return L;//do the insertion;
}

List Delete( List L, Position P ){
	Position pre=L,a;
	if(P==L){
		a=P;
		P=P->Next;
		free(a);
		return P;//delete the head node;
	}
	while(pre&&pre->Next!=P)
		pre=pre->Next;// find the pre node of deletion;
	if(!pre){
		printf("Wrong Position for Deletion\n");
		return ERROR;// if its a wrong position;
	}
	else{
		pre->Next=P->Next;
		a=P;
		free(a);
		return L;//do the deetion;
	}
}

#endif
