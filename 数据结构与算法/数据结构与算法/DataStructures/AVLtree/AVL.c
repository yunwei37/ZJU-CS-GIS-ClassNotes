#include "AVL.h"

void printAVL(AVL a,int space){
	if(a==NULL) return;
	else{
		printAVL(a->Left,space+1);
		int i;
		for(i=0;i<space;++i)
			putchar('\t');
		printf("%d\n",a->data);		
		printAVL(a->Right,space+1);
	}
}

int height(AVL a) {
	if (a == NULL) return -1;
	else
		return a->h;
}

void update(AVL a) {
	a->h = max(height(a->Left), height(a->Right)) + 1;
}

static AVL findmin(AVL a){
	if(!a)	return a;
	while(a->Left)
		a = a->Left;
	return a;
}

int find(AVL a, int x){
	if(a == NULL)
		return 0;
	if(x == a->data)
		return 1;
	else if(x<a->data)
		return find(a->Left,x);
	else 
		return find(a->Right,x); 
}

AVL CreateAVL(int x) {
	AVL a = (AVL)malloc(sizeof(struct treenode));
	a->data = x;
	a->h = 0;
	a->Left = a->Right = NULL;
	return a;
}

AVL balance(AVL a) {
	if (height(a->Left) > height(a->Right)) {
		/*LL rotation;*/
		if (height(a->Left->Left) > height(a->Left->Right)) {
			AVL left = a->Left;
			a->Left = a->Left->Right;
			left->Right = a;
			update(a);
			update(left);
			return left;
		}
		/*LR rotation;*/
		else {
			AVL left = a->Left;
			AVL mid = left->Right;
			left->Right = mid->Left;
			a->Left = mid->Right;
			mid->Left = left;
			mid->Right = a;
			update(left);
			update(a);
			update(mid);
			return mid;
		}
	}
	if (height(a->Left) < height(a->Right)) {
		/*RL rotation;*/
		if (height(a->Right->Left) > height(a->Right->Right)) {
			AVL right = a->Right;
			AVL mid = right->Left;
			right->Left = mid->Right;
			a->Right = mid->Left;
			mid->Right = right;
			mid->Left = a;
			update(right);
			update(a);
			update(mid);
			return mid;
		}
		/*RR rotation;*/
		else {
			AVL right = a->Right;
			a->Right = a->Right->Left;
			right->Left = a;
			update(a);
			update(right);
			return right;
		}
	}
	return a;
}

AVL insert(int x, AVL a) {
	if (a == NULL)	a = CreateAVL(x);
	else if (x == a->data)	return a;
	else if (x < a->data)
		a->Left = insert(x, a->Left);
	else if (x > a->data)
		a->Right = insert(x, a->Right);
	/*update bf;*/
	if (abs(height(a->Left) - height(a->Right)) > 1)
		a = balance(a);
	update(a);
	return a;
}

AVL delete(int x,AVL a){
	if(a == NULL)	return NULL;
	else if(x < a->data)
		a->Left=delete(x,a->Left);
	else if(x > a->data)
		a->Right=delete(x,a->Right);
	else{
		AVL tmp = a, min;
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
	if(a==NULL)	return a;
	else if (abs(height(a->Left) - height(a->Right)) > 1)
		a = balance(a);
	update(a);
	return a;
}
