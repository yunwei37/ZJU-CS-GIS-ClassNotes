//6-5 链式表操作集
#include <stdio.h>
#include <stdlib.h>

typedef int ElementType;
typedef struct LNode *PtrToLNode;
struct LNode {
    ElementType Data;
    PtrToLNode Next;
};
typedef PtrToLNode Position;
typedef PtrToLNode List;
//三种基本操作
Position Find( List L, ElementType X );
List Insert( List L, ElementType X, Position P );
List Delete( List L, Position P );

int main()
{
    List L;
    ElementType X;
    Position P, tmp;
    int N;

    L = NULL;
    scanf("%d", &N);
    while ( N-- ) {
        scanf("%d", &X);
        L = Insert(L, X, L);
        if ( L==NULL ) printf("Wrong Answer\n");
    }
    scanf("%d", &N);
    while ( N-- ) {
        scanf("%d", &X);
        P = Find(L, X);
        if ( P == NULL )
            printf("Finding Error: %d is not in.\n", X);
        else {
            L = Delete(L, P);
            printf("%d is found and deleted.\n", X);
            if ( L==NULL )
                printf("Wrong Answer or Empty List.\n");
        }
    }
    L = Insert(L, X, NULL);
    if ( L==NULL ) printf("Wrong Answer\n");
    else
        printf("%d is inserted as the last element.\n", X);
    P = (Position)malloc(sizeof(struct LNode));
    tmp = Insert(L, X, P);
    if ( tmp!=NULL ) printf("Wrong Answer\n");
    tmp = Delete(L, P);
    if ( tmp!=NULL ) printf("Wrong Answer\n");
    for ( P=L; P; P = P->Next ) printf("%d ", P->Data);
    return 0;
}

Position Find( List L, ElementType X ){
	while(L&&L->Data!=X)
		L=L->Next;
	return L;
} 
 
List Insert( List L, ElementType X, Position P ){
	Position pre=L,a;
	a=(Position)malloc(sizeof(struct LNode));
	a->Data=X;
	a->Next=P;
	if(P==L)	return a;
	if(!L){
		L=a;
		return L;
	}
	while(pre->Next&&pre->Next!=P)
		pre=pre->Next;
	if(P&&!pre->Next){
		printf("Wrong Position for Insertion\n");
		return NULL;
	}
	else
		pre->Next=a;
		return L;
}

List Delete( List L, Position P ){
	Position pre=L,a;
	if(P==L){
		a=P;
		P=P->Next;
		free(a);
		return P;
	}
	while(pre&&pre->Next!=P)
		pre=pre->Next;
	if(!pre){
		printf("Wrong Position for Deletion\n");
		return NULL;
	}
	else{
		pre->Next=P->Next;
		a=P;
		free(a);
		return L;
	}
}
