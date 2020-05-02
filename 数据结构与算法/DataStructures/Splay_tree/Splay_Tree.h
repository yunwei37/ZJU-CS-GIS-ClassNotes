#ifndef Splay_Tree_H
#define Splay_Tree_H

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
typedef struct Node_ *Node;
// Node is a pointer
struct Node_
{
	int Num;
	Node Left;
	Node Right;
};

Node Creat_Node(int N);
// Create an ampty node
Node Insert(Node Tree, int N);
// insert a Node with num equals to N
Node Find(Node Tree, int N);
// find the wanted node
Node Delete(Node Tree, int N);
// Delete the Node of num = N in a Tree
Node Single_Rotate_Left(Node P);
Node Single_Rotate_Right(Node P);
void Print(Node Tree);
// Print in inorder level
void Test_Splay_Tree(FILE *fread, FILE *fwrite);
void Print_Info(clock_t start, clock_t finish, FILE *fwrite);
// print the time used
#endif