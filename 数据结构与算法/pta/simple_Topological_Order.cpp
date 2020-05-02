/*7-34 任务调度的合理性 （25 分）
输入说明：输入第一行给出子任务数N（≤100），
子任务按1~N编号。随后N行，每行给出一个子任务的依赖集合：
首先给出依赖集合中的子任务数K，
随后给出K个子任务编号，整数之间都用空格分隔。*/

#include<iostream>
using namespace std;

int main(){
	int n,a[101][101]={0},b[101]={0};
	//a为邻接矩阵，b为每个节点的入度； 
	cin>>n;
	int i,j;
	int count=n;//还有几个顶点存活 
	for(i=1;i<=n;i++){
		int x,k;
		cin>>x;
		b[i]=x;
		for(j=0;j<x;j++){
			cin>>k;
			a[i][k]=1;
		}
	}
	while(count){
		i=1;
		while(i<=n&&b[i])	++i;
		if(i>n) break;
		b[i]=-1;
		count--;
		for(j=1;j<=n;j++){
			if(a[j][i])
				--b[j];
		}
	}
	if(!count)
		cout<<1;
	else if(i>n)
		cout<<0;
	return 0;
}
