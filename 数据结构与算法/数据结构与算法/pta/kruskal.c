// 7-10 公路村村通 （30 分）
/*现有村落间道路的统计数据表中，
列出了有可能建设成标准公路的若干条道路的成本，
求使每个村落都有公路连通所需要的最低成本。*/
//Kruskal算法 
#include<stdio.h>
#include<stdlib.h>

struct road{
	int v1;
	int v2;
	int cost;
} e[3004];//数组排序并选取最小值； 

int v[1001]={0};

int sort(const void *a,const void *b){
	return ((struct road*)a)->cost-((struct road*)b)->cost;
}

int root(int x){
	if(v[x]==0)	return x;
	else return v[x]=root(v[x]);
}

int main(){
	int n,m;
	scanf("%d%d",&n,&m);
	int i;
	for(i=0;i<m;++i)
		scanf("%d %d %d",&e[i].v1,&e[i].v2,&e[i].cost);		
	qsort(e,m,sizeof(struct road),sort);
	int sum=0;
	//并查集 
	for(i=0;i<m;i++){
		if(root(e[i].v1)!=root(e[i].v2)){
			v[root(e[i].v2)]=root(e[i].v1);// 路径压缩 
			sum+=e[i].cost;
		}
	}
	int flag=1;
	for(i=1;i<=n;i++){
		if(v[i]==0&&flag) flag=0;
		else if(v[i]==0) break;
	}
	if(i<=n)	printf("-1");
	else
		printf("%d",sum);
}
