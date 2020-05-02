// ConsoleApplication5.cpp : 此文件包含 "main" 函数。程序执行将在此处开始并结束。
//

#include<stdio.h>
#include<stdlib.h>
#include <time.h>
#include "SkipList.h"

void print(skiplist *s) {
	skiplistNode  *x;
	printf("order:\n");
	int i;
	for (i = s->level - 1; i >= 0; i--) {
		x = s->header;
		while (x->level[i].forward) {
			printf("%d ", (x->level[i].forward->key));
			x = x->level[i].forward;
		}
		printf("\n");
	}
}

void test(int n) {

	clock_t start, end;
	double time;

	skiplist *s2;
	s2 = slCreate();
	int i, j;
	int range = n * 10;

	start = clock();
	for (i = 0; i < n; ++i) {
		j = rand() % range;
		slInsert(s2, j, &j);
	}
	end = clock();
	time = (end - start)*1.0 / CLK_TCK;
	printf("insert: %f\n", time);
	//print(s1);
	//print(s2);

	start = clock();
	for (i = 0; i < n; i++) {
		j = rand() % range;
		int* n = slFind(s2, j);
		//printf("find: %d\n", *n);
	}
	end = clock();
	time = (end - start)*1.0 / CLK_TCK;
	printf("find: %f\n", time);

	start = clock();
	for (i = 0; i < n; i++) {
		j = rand() % range;
		slDelete(s2, j);
	}
	end = clock();
	time = (end - start)*1.0 / CLK_TCK;
	printf("delete: %f\n", time);
	printf("number: %d\n\n", n);
}

int main() {
	for(int i=10;i<2000000;i+=100000)
		test(i);
	return 0;
}



