/*pta 6-6 带头结点的链式表操作集 （20 分）
本题要求实现带头结点的链式表操作集。*/

#include <stdio.h>
#include <stdlib.h>

#define ERROR NULL
typedef enum {false, true} bool;
typedef int ElementType;
typedef struct LNode *PtrToLNode;
struct LNode {
    ElementType Data;
    PtrToLNode Next;
};
typedef PtrToLNode Position;
typedef PtrToLNode List;

List MakeEmpty(); 
Position Find( List L, ElementType X );
bool Insert( List L, ElementType X, Position P );
bool Delete( List L, Position P );

int main()
{
    List L;
    ElementType X;
    Position P;
    int N;
    bool flag;

    L = MakeEmpty();
    scanf("%d", &N);
    while ( N-- ) {
        scanf("%d", &X);
        flag = Insert(L, X, L->Next);
        if ( flag==false ) printf("Wrong Answer\n");
    }
    scanf("%d", &N);
    while ( N-- ) {
        scanf("%d", &X);
        P = Find(L, X);
        if ( P == ERROR )
            printf("Finding Error: %d is not in.\n", X);
        else {
            flag = Delete(L, P);
            printf("%d is found and deleted.\n", X);
            if ( flag==false )
                printf("Wrong Answer.\n");
        }
    }
    flag = Insert(L, X, NULL);
    if ( flag==false ) printf("Wrong Answer\n");
    else
        printf("%d is inserted as the last element.\n", X);
    P = (Position)malloc(sizeof(struct LNode));
    flag = Insert(L, X, P);
    if ( flag==true ) printf("Wrong Answer\n");
    flag = Delete(L, P);
    if ( flag==true ) printf("Wrong Answer\n");
    for ( P=L->Next; P; P = P->Next ) printf("%d ", P->Data);
    return 0;
}

Position FindPre(Position P, List L){
	while(L&&P!=L->Next)
		L=L->Next;
	return L;
}

List MakeEmpty(){
	List L=(List)malloc(sizeof(struct LNode));
	L->Next=NULL;
	return L;
}
 
Position Find( List L, ElementType X ){
	L=L->Next;
	while(L&&L->Data!=X)
		L=L->Next;
	if(!L)
		return ERROR;
	return L;
}
 

bool Insert( List L, ElementType X, Position P ){
	Position pre=FindPre(P,L);
	if(!pre){
		printf("Wrong Position for Insertion\n");
		return false;
	}
	Position a=(Position)malloc(sizeof(struct LNode));
	a->Data=X;
	a->Next=P;
	pre->Next=a;
	return true;
}

bool Delete( List L, Position P ){
	Position pre=FindPre(P,L);
	if(!pre){
		printf("Wrong Position for Deletion\n");
		return false;
	}
	pre->Next=P->Next;
	free(P);
	return true;
} 
