#ifndef _AVL_H
#define _AVL_H

#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#define max(a,b) (a>b?a:b)


typedef struct treenode* ptn;
typedef ptn AVL;
struct treenode {
	int h;
	int data;
	ptn Left;
	ptn Right;
};

int height(AVL a);

void update(AVL a);

AVL CreateAVL(int x);

AVL balance(AVL a);

AVL insert(int x, AVL a);

AVL delete(int x,AVL a);

int find(AVL a, int x);

void printAVL(AVL a,int space);

#endif
