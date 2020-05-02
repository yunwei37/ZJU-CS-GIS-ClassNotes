#include <stdio.h>
#include <stdlib.h>
#include "BST.h"

int main(){
	int n, x, i=1;
	printf("0: stop; \n1: insert x \n2: delete x\n");
	scanf_s("%d", &n);
	BST a = NULL;
	while(n>0){
		if(n==1){
		printf("input x:\n");
		scanf_s("%d",&x);
			if (a == NULL) {
				a = CreateTree(x);
				printTree(a, 0);
			}
			else{
				a = insert(x, a);
				printf("\n%d:\n",i++);
				printTree(a,0);		
			}			
		}
		else if(n==2){
			printf("input x:\n");
			scanf_s("%d",&x);
			printf("\ndelete:\n");
			if(find(a,x)){
				a = delete(x,a);
				printTree(a,0);			
			}
			else
				printf("not found\n");
		}
	printf("0: stop; \n1: insert x \n2: delete x\n");
	scanf_s("%d", &n);
	}
	return 0;
}
