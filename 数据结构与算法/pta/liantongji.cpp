//7-6 列出连通集 （25 分）
/*给定一个有N个顶点和E条边的无向图，请用DFS和BFS分别
列出其所有的连通集。假设顶点从0到N?1编号。进行搜索时，假
设我们总是从编号最小的顶点出发，按编号递增的顺序访问邻接点。*/

#include<iostream>
#include<list>
using namespace std;

int edge[10][10]={0};
int v[10];
int visit[10]={0};
//dfs递归实现 
int dfs(int v1,int n){
	int count=1,i;
	cout<<v1<<" ";
	v[v1]=0;
	for(i=0;i<n;++i){
		if(edge[v1][i]&&v[i])
				count+=dfs(i,n);
	}
	return count;
}
//bfs队列实现 
int bfs(int v1,int n){
	list<int> a;
	int count=1,i,x;
	cout<<v1<<" ";
	v[v1]=0;
	visit[v1]=0;
	for(i=0;i<n;++i)
		if(edge[v1][i])
				a.push_back(i),visit[i]=0;
	while(!a.empty()){
		x=*a.begin();
		a.pop_front();
		cout<<x<<" ";
		v[x]=0;
		++count;
		for(i=0;i<n;++i){
			if(edge[x][i]&&v[i]&&visit[i])
				a.push_back(i),visit[i]=0;
	}
	}
	return count;
}

int main(){
	
	int n,e,n1;
	int i,e1,e2;
	cin>>n>>e;
	for(i=0;i<e;++i){
		cin>>e1>>e2;
		edge[e1][e2]=1;
		edge[e2][e1]=1;
	}
	//dfs 
	for(i=0;i<n;i++)
		v[i]=1;
	n1=n;
	cout<<"{ ";
	n1=n1-dfs(0,n);
	cout<<"}"<<endl;
	while(n1>0){
		i=0;
		while(!v[i])
			++i;
		cout<<"{ ";
		n1-=dfs(i,n);
		cout<<"}"<<endl;
	}
	//bfs
	for(i=0;i<n;++i)
		visit[i]=1;
	for(i=0;i<n;i++)
		v[i]=1;
	n1=n;
	cout<<"{ ";
	n1=n1-bfs(0,n);
	cout<<"}"<<endl;
	while(n1>0){
		i=0;
		while(!v[i])
			++i;
		cout<<"{ ";
		n1-=bfs(i,n);
		cout<<"}"<<endl;
	}
	return 0;
}
