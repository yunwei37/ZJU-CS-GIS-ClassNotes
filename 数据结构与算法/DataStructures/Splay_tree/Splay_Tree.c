#include "Splay_Tree.h"

Node Creat_Node(int N)
{
	Node node = (Node)malloc(sizeof(struct Node_));
	node -> Left = NULL;
	node -> Right = NULL;
	node -> Num = N;
	return node;
}
// Create a new node and initialize
Node Insert(Node Tree, int N)
{
	if(Tree == NULL)
		return Creat_Node(N);

	if(N > Tree -> Num)
		Tree -> Right = Insert(Tree -> Right, N);
	else
		Tree -> Left = Insert(Tree -> Left, N);

	// Tree = Find(Tree, N);

	return Tree;
}
// insert a node 
Node Find(Node Tree, int N)
{
	if(!Tree)
		return NULL;

	Node Header = Creat_Node(-1);
	Node Root = Tree;
	Node LeftMin = Header;
	Node RightMax = Header;
	// Header is used to remember the root of the LeftMin tree and the RightMax tree
	while(Root -> Num != N)
	{
		if(N < Root -> Num){
			if(!(Root -> Left)) //to ensure it is not empty 
				break;

			if(Root -> Left && N < Root -> Left -> Num)// Zig-zig
				Root = Single_Rotate_Left(Root);

			RightMax -> Right = Root;
			Root = Root -> Left;
			RightMax -> Left = NULL;
			RightMax = RightMax -> Right;
		}else{
			if(!(Root -> Right)) //to ensure it is not empty
				break;

			if(Root -> Right && N > Root -> Right -> Num)// Zig-zig
				Root = Single_Rotate_Right(Root);

			LeftMin -> Left = Root;
			Root = Root -> Right;
			LeftMin -> Right = NULL;
			LeftMin = LeftMin -> Left;
		}
	}

	// link the node
	if(LeftMin != Header){
		LeftMin -> Right = Root -> Left;
	}else{
		LeftMin -> Left = Root -> Left;
	}
	if(RightMax != Header){
		RightMax -> Left = Root -> Right;  
	}else{
		RightMax -> Right = Root -> Right;
	}
	
	Root -> Left = Header -> Left;  
	Root -> Right = Header -> Right;
	return Root;
}

Node Single_Rotate_Left(Node P)
{
	if(!P)
		return NULL;

	Node Root = P -> Right;
	Node L = Root -> Left;
	P -> Right = L;
	Root -> Left = P;
	return Root;
}

Node Single_Rotate_Right(Node P)
{
	if(!P)
		return NULL;

	Node Root = P -> Left;
	Node R = Root -> Right;
	P -> Left = R;
	Root -> Right = P;
	return Root;
}

Node Delete(Node Tree, int N)
{
	if(!Tree)
		return NULL;

	Node L, R;
	Node Sub;
	L = Tree -> Left;
	R = Tree -> Right;
	if(L){
		Sub = L; 
		while(Sub -> Right != NULL) 
			Sub = Sub -> Right;
		// replace with the Left max node
		Tree -> Num = Sub -> Num;
		Tree -> Left = Delete(L, Tree -> Num);
	}else if(R){
		Sub = R;
		while(Sub -> Left != NULL) 
			Sub = Sub -> Left;
		// replace with the right min node
		Tree -> Num = Sub -> Num;
		Tree -> Right = Delete(R, Tree -> Num); 
	}else{
		if(Tree)
			free(Tree);
		Tree = NULL;
	}

	return Tree;
}

void Print(Node Tree)
{
	if(!Tree)
		return;

	printf("%d ", Tree -> Num);
	if(Tree -> Left)
		Print(Tree -> Left);
	if(Tree -> Right)
		Print(Tree -> Right);
}
// print in inlevel order
void Test_Splay_Tree(FILE *fread, FILE *fwrite)
{
	clock_t start, finish;
	double Time;
	start = clock();
	int N;
	fscanf(fread, "%d", &N);
	Node T = NULL;
	for(int i=0; i<N; i++)
	{
		int a;
		fscanf(fread, "%d", &a);
		T = Insert(T, a);
		Find(T, a);
	}

	finish = clock();
	Print_Info(start, finish, fwrite);
	fprintf(fwrite, "  "); 
	start = clock();
	for(int i=0; i<N; i++)
	{
		int a;
		fscanf(fread, "%d", &a);
		Find(T, a);
		T = Delete(T, a);
		// Print(T);
	}

	finish = clock();
	Print_Info(start, finish, fwrite); 
	fprintf(fwrite, "\n");
} 

void Print_Info(clock_t start, clock_t finish, FILE *fwrite)
{
	double Time;
	Time = (double)(finish - start) / CLOCKS_PER_SEC;
	fprintf(fwrite, "%lf", Time);
}