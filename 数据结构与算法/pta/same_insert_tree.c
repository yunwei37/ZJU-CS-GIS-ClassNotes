/*给定一个插入序列就可以唯一确定一棵二叉搜索树。
然而，一棵给定的二叉搜索树却可以由多种不同的插入序列得到。
例如分别按照序列{2, 1, 3}和{2, 3, 1}插入初始为空的
二叉搜索树，都得到一样的结果。于是对于输入的各种插入序列
，你需要判断它们是否能生成一样的二叉搜索树。 */ 
#include<stdio.h>

int same(int ori[],int a[],int n);

int main(){
	int n,l;
	int ori[10],a[10];
	int i,j;
	scanf("%d %d\n",&n,&l);
	while(n){
		for(i=0;i<n;i++)
			scanf("%d",&ori[i]);
		for(j=0;j<l;j++){
			for(i=0;i<n;i++)
				scanf("%d",&a[i]);
			if(same(ori,a,n))
				printf("Yes\n");
			else
				printf("No\n");
			
		}
		for(i=0;i<n;i++)
			a[i]=0,ori[i]=0;
		scanf("%d %d\n",&n,&l);
	}
	return 0;
}
//使用一个递归算法进行判断： 应该可以改进一下（ 使用递归头...? 
int same(int ori[],int a[],int n){
	int i=0;
	int b[10],b1,c[10],c1;
	int d[10],d1,e[10],e1;
	b1=c1=d1=e1=0;
	if(n==0) return 1;
	else if(ori[0]!=a[0])	return 0;
	else if(n==1)	return 1;
	else{
		for(i=0;i<n;i++){
			if(ori[i]>ori[0])
				b[b1++]=ori[i];
			else if(ori[i]<ori[0])
				c[c1++]=ori[i];
		}
		for(i=0;i<n;i++){
			if(a[i]>a[0])
				d[d1++]=a[i];
			else if(a[i]<a[0])
				e[e1++]=a[i];
		}
		if(d1!=b1||c1!=e1)	return 0;
		return same(b,d,b1)&&same(c,e,c1);
	}
}
