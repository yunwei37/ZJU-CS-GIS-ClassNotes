#ifndef _BST_H
#define _BST_H

#include<stdio.h>
#include<stdlib.h>

typedef struct treenode* ptn;
typedef ptn BST;
struct treenode {
	int data;
	ptn Left;
	ptn Right;
};


BST CreateTree(int x);

BST insert(int x,BST a);

BST delete(int x,BST a);

int find(BST a, int x);

void printTree(BST a,int space);

#endif
