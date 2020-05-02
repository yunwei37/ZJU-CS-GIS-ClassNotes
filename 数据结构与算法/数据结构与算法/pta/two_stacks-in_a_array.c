//6-7 在一个数组中实现两个堆栈 （20 分）
#include <stdio.h>
#include <stdlib.h>

#define ERROR 1e8
typedef int ElementType;

typedef enum { false, true } bool;
typedef int Position;
struct SNode {
    ElementType *Data;
    Position Top1, Top2;
    int MaxSize;
};
typedef struct SNode *Stack;

Stack CreateStack( int MaxSize );
bool Push( Stack S, ElementType X, int Tag );
ElementType Pop( Stack S, int Tag );


void PrintStack( Stack S, int Tag ){
	if(Tag==1)
		while(S->Top1!=-1){
			printf("%d ",S->Data[S->Top1--]);
		}
	if(Tag==2)
		while(S->Top2!=S->MaxSize){
			printf("%d ",S->Data[S->Top2++]);
		}
}

int main()
{
    int N, Tag, X;
    Stack S;
    int done = 0;

    scanf("%d", &N);
    S = CreateStack(N);
    while ( !done ) {
    	int c;
    	scanf("%d",&c);
        switch( c ) {
        case 0: 
            scanf("%d %d", &Tag, &X);
            if (!Push(S, X, Tag)) printf("Stack %d is Full!\n", Tag);
            break;
        case 1:
            scanf("%d", &Tag);
            X = Pop(S, Tag);
            if ( X==ERROR ) printf("Stack %d is Empty!\n", Tag);
            break;
        case 2:
            PrintStack(S, 1);
            PrintStack(S, 2);
            done = 1;
            break;
        }
    }
    return 0;
}

Stack CreateStack( int MaxSize ){
	Stack a=(Stack)malloc(sizeof(struct SNode));
	a->Data=(ElementType *)malloc(sizeof(ElementType)*MaxSize);
	a->Top1=-1;
	a->Top2=MaxSize;
	a->MaxSize=MaxSize;
	return a;
}

bool Push( Stack S, ElementType X, int Tag ){
	if(S->Top1==S->Top2-1){
		printf("Stack Full\n");
		return false;
	}
	if(Tag==1){
		S->Data[++(S->Top1)]=X;
		return true;
	}
	else{
		S->Data[--(S->Top2)]=X;
		return true;
	}
}
ElementType Pop( Stack S, int Tag ){
	if(Tag==1){
		if(S->Top1==-1){
			printf("Stack %d Empty\n",Tag);
			return ERROR;
		}
		else
			S->Top1--;
			return 0;
	}
	if(Tag==2){
		if(S->Top2==S->MaxSize){
			printf("Stack %d Empty\n",Tag);
			return ERROR;
		}
		else
			S->Top2++;
			return 0;
	}
}
