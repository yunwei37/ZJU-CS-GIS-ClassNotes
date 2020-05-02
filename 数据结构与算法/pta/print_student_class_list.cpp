//7-47 打印选课学生名单 （25 分）
/*输入的第一行是两个正整数：N（≤40000），
为全校学生总数；K（≤2500），为总课程数。此后N行，
每行包括一个学生姓名（3个大写英文字母+1位数字）、
一个正整数C（≤20）代表该生所选的课程门数、
随后是C个课程编号。简单起见，课程从1到K编号。*/

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<list>
#include<vector>
using namespace std;

struct student{
	char name[5];
	int* c;//保存每个学生的选课； 
}stu[40001];//对头（学生名字）排序； 

int cla[40001][20]={0};//每个学生的课程； 
int count[2501]={0};//每门课程的人数； 
int cmp(const void *a,const void *b){
	return strcmp(((struct student*)a)->name,((struct student*)b)->name);
}

int main(){
	int n,k;
	scanf("%d %d\n",&n,&k);
	int i,x,j,c,m,t;
	char name[5];
	vector<list<int> > a(k+1);
	for(i=0;i<n;i++){
		scanf("%s %d",name,&x);
		strcpy(stu[i].name,name);
		stu[i].c=cla[i]; 
		for(j=0;j<x;j++){
			scanf("%d",&t);
			cla[i][j]=t;
			count[t]++;
		}
	}
	qsort(stu,n,sizeof(struct student),cmp);
	for(i=0;i<n;i++){
		for(j=0;j<20;j++)
		if(stu[i].c[j]){
			a[stu[i].c[j]].push_back(i);			
		}//转到每个课程的链表； 
	}
	for(i=1;i<=k;i++){
		printf("%d %d\n",i,count[i]);
		list<int>::iterator a1;
		for(a1=a[i].begin();a1!=a[i].end();++a1){
			printf("%s\n",stu[*a1].name);		
		}
	}
	return 0;
}
