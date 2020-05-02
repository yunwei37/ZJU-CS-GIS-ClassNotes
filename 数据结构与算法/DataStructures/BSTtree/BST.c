#include "BST.h"

void printTree(BST a,int space){
	if(a==NULL) return;
	else{
		printTree(a->Left,space+1);
		int i;
		for(i=0;i<space;++i)
			putchar('\t');
		printf("%d\n",a->data);		
		printTree(a->Right,space+1);
	}
}

static BST findmin(BST a){
	if(!a)	return a;
	while(a->Left)
		a = a->Left;
	return a;
}

int find(BST a, int x){
	if(a == NULL)
		return 0;
	if(x == a->data)
		return 1;
	else if(x<a->data)
		return find(a->Left,x);
	else 
		return find(a->Right,x); 
}

BST CreateTree(int x) {
	BST a = (BST)malloc(sizeof(struct treenode));
	a->data = x;
	a->Left = a->Right = NULL;
	return a;
}

BST insert(int x, BST a) {
	if (a == NULL)	a = CreateTree(x);
	else if (x == a->data)	return a;
	else if (x < a->data)
		a->Left = insert(x, a->Left);
	else if (x > a->data)
		a->Right = insert(x, a->Right);
	return a;
}

BST delete(int x, BST a){
	if(a == NULL)	return NULL;
	else if(x < a->data)
		a->Left=delete(x,a->Left);
	else if(x > a->data)
		a->Right=delete(x,a->Right);
	else{
		BST tmp = a, min;
		if(a->Right == NULL){
			a = a->Left;
			free(tmp);
		}else if(a->Left == NULL){
			a = a->Right;
			free(tmp);
		}else{
			min = findmin(a->Right);
			a->data = min->data;
			a->Right = delete(min->data,a->Right);
		}		
	}
	return a;
}
