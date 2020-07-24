/* merge two non-descending list sequences
 * version 1.0:  pass the onlin test on the pta "数据结构与算法题目集" 7-51
 * by ZhengYusheng 25/2/2019
 *
 * Two non-descending list sequences S1 and 
 * S2 are known. The design function constructs a 
 * new non-descending list S3 which is the union of S1 and S2. 
 * 
 * Input Description: The input is divided into two lines, 
 * each of which gives a non-descending sequence composed of 
 * several positive integers. The end of the sequence is 
 * represented by -1 (-1 does not belong to this sequence). 
 * Numbers are spaced by spaces.
 * 
 * Output Description: A new non-descending linked 
 * list is output in one line after merging. The numbers 
 * are separated by spaces, and no extra spaces are allowed at the end. 
 * If the new linked list is empty, output "NULL"
 */
 
#include <stdio.h>
#include <stdlib.h>
#include "list.h"

int main()
{	/*declares*/
    List L1,L2,L;
    ElementType X;
    Position tmp,P;
    
	/*get the list L1*/
    L1 = NULL;
    scanf("%d", &X);
    while ( X!=-1 ) {
        L1 = Insert(L1, X, L1);//insert in the head node;
        if ( L1==ERROR ) printf("Wrong Answer\n");
        scanf("%d", &X);
    }
    
    /*get the list L2*/
    L2 = NULL;
    scanf("%d", &X);
    while ( X!=-1 ) {
        L2 = Insert(L2, X, L2);//insert in the head node;
        if ( L2==ERROR ) printf("Wrong Answer\n");
        scanf("%d", &X);
    }
	
	/*create the result list: choose the node with larger int and do the insertion*/
	L = NULL;
    while ( L1!=NULL && L2!=NULL ) {// if the both L1 and L2 exist:
    	if(L1->Data > L2->Data){// L1 is larger;
        	L = Insert(L, L1->Data, L);//insert L1 in the head node of L;
        	tmp=L1;
			L1=L1->Next;
			free(tmp);//free the L1 node;
		}else{// L2 is larger or the data of both list node is equal;
			L = Insert(L, L2->Data, L);//insert L2 in the head node of L;
			tmp=L2;
			L2=L2->Next;
			free(tmp);//free the l2 node; 
		}
        if ( L==ERROR ) printf("Wrong Answer\n");
    }
    /*if L1 is left, insert the rest of L1*/
    while(L1!=NULL){
    	L = Insert(L, L1->Data, L);//insert L1 in the head node of L;
        tmp=L1;
		L1=L1->Next;
		free(tmp); //free the node; 
	}
	/*if L2 is left, insert the rest of L2*/
	while(L2!=NULL){
    	L = Insert(L, L2->Data, L);//insert L2 in the head node of L;
        tmp=L2;
		L2=L2->Next;
		free(tmp);  //free the node; 
	}
	
	/*print the L list;*/
	P=L;
	if(P!=NULL){//print the head node without space;
		printf("%d",P->Data);
		P=P->Next;
	}else{//if the list is empty, print NULL;
		printf("NULL");
	}
	while(P!=NULL){// print the rest nodes with space;
		printf(" %d",P->Data);
		P=P->Next;
	}
	 return 0;
}

