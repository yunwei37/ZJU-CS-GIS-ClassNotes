//A project from pta's problems about binary tree

#include <stdio.h>
#include <stdlib.h>

typedef int ElementType;
typedef struct TNode *Position;
typedef Position BinTree;
struct TNode{
    ElementType Data;
    BinTree Left;
    BinTree Right;
};

void PreorderTraversal( BinTree BT );
void InorderTraversal( BinTree BT ); 
void LevelorderTraversal( BinTree BT ) ;
void PostorderTraversal( BinTree BT );

BinTree Insert( BinTree BST, ElementType X );
BinTree Delete( BinTree BST, ElementType X );
Position Find( BinTree BST, ElementType X );
Position FindMin( BinTree BST );
Position FindMax( BinTree BST );

int main()
{
    BinTree BST, MinP, MaxP, Tmp;
    ElementType X;
    int N, i;

    BST = NULL;
    scanf("%d", &N);
    for ( i=0; i<N; i++ ) {
        scanf("%d", &X);
        BST = Insert(BST, X);
    }
    
    printf("Preorder:"); PreorderTraversal(BST); printf("\n");
    printf("Levelorder:"); LevelorderTraversal(BST); printf("\n");
    printf("Postorder:"); PostorderTraversal(BST); printf("\n");
    MinP = FindMin(BST);
    MaxP = FindMax(BST);
    scanf("%d", &N);
    for( i=0; i<N; i++ ) {
        scanf("%d", &X);
        Tmp = Find(BST, X);
        if (Tmp == NULL) printf("%d is not found\n", X);
        else {
            printf("%d is found\n", Tmp->Data);
            if (Tmp==MinP) printf("%d is the smallest key\n", Tmp->Data);
            if (Tmp==MaxP) printf("%d is the largest key\n", Tmp->Data);
        }
    }
    
    scanf("%d", &N);
    for( i=0; i<N; i++ ) {
        scanf("%d", &X);
        BST = Delete(BST, X);
    }
    
    printf("Inorder:"); InorderTraversal(BST); printf("\n");

    return 0;
}

void PreorderTraversal( BinTree BT ){
	if( BT ){
		printf("%d ",BT->Data);
		PreorderTraversal(BT->Left);
		PreorderTraversal(BT->Right);
	}
}

void PostorderTraversal( BinTree BT ){
	if( BT ){
		PostorderTraversal( BT->Left );
		PostorderTraversal( BT->Right );
		printf("%d",BT->Data);
	}
}

void InorderTraversal( BinTree BT ){
	if(BT){
		InorderTraversal(BT->Left);
		printf("%d ",BT->Data);
		InorderTraversal(BT->Right);
	}
}

Position FindMin( BinTree BST ){
	if(BST)
		while(BST->Left) BST=BST->Left;
	else 
		return NULL;
	return BST;
}

Position FindMax( BinTree BST ){
	if(BST)
		while(BST->Right) BST=BST->Right;
	else 
		return NULL;
	return BST;
}

BinTree Insert( BinTree BST, ElementType X ){
	if(!BST){
		BST=(Position)malloc(sizeof(struct TNode));
		BST->Data=X;
		BST->Left=BST->Right=NULL;
	}
	else{
		if(X<BST->Data)
			BST->Left=Insert(BST->Left,X);
		else if(X>BST->Data)
			BST->Right=Insert(BST->Right,X);
	}
	return BST;
}

BinTree Delete( BinTree BST, ElementType X ){
	Position tmp;
	if(!BST) printf("Not Found\n");
	else if(X<BST->Data)
		BST->Left= Delete(BST->Left,X);
	else if(X>BST->Data)
		BST->Right=Delete(BST->Right,X);
	else
		if(BST->Left&&BST->Right){
			tmp=FindMin(BST->Right);
			BST->Data=tmp->Data;
			BST->Right=Delete(BST->Right,tmp->Data);
		}else{
			tmp=BST;
			if(!BST->Left)
				BST=BST->Right;
			else
				BST=BST->Left;
			free(tmp);
		}
	return BST;
}

Position Find( BinTree BST, ElementType X ){
	if(!BST) return NULL;
	if(X>BST->Data)
		return Find(BST->Right,X);
	else if(X<BST->Data)
		return Find(BST->Left,X);
	else 
		return BST;
}

void LevelorderTraversal( BinTree BT ){
  if(!BT) return;
  BinTree a[10000],T;
  int head=0,tail=0;
  a[head]=BT;
  head++;//queue
  while(head>tail){
    T=a[tail];
    tail++;
    printf(" %d",T->Data);
    if(T->Left){
      a[head]=T->Left;
      head++;
    }
    if(T->Right){
      a[head]=T->Right;
      head++;
    }
  }
}


