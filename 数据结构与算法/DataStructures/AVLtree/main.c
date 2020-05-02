#include <stdio.h>
#include <stdlib.h>
#include "AVL.h"

int main(){
	int n, x, i=1;
	printf("0: stop; \n1: insert x \n2: delete x\n");
	scanf_s("%d", &n);
	AVL a=NULL;
	while(n>0){
		if(n==1){
		printf("input x:\n");
		scanf_s("%d",&x);
			if (a == NULL) {
				a = CreateAVL(x);
				printAVL(a, 0);
			}
			else{
				a = insert(x, a);
				printf("\n%d:\n",i++);
				printAVL(a,0);		
			}			
		}
		else if(n==2){
			printf("input x:\n");
			scanf_s("%d",&x);
			printf("\ndelete:\n");
			if(find(a,x)){
				a = delete(x,a);
				printAVL(a,0);			
			}
			else
				printf("not found\n");
		}
	printf("0: stop; \n1: insert x \n2: delete x\n");
	scanf_s("%d", &n);
	}
	return 0;
}
/*
int main() {
	int n, x, i;
	scanf("%d %d", &n, &x);
	AVL a;
	a = CreateAVL(x);
	for (i = 1; i < n; ++i) {
		scanf("%d", &x);
		a = insert(x, a);
		printAVL(a,0);
	}
	x = a->data;
	printf("%d", x);
	return 0;
}*/
