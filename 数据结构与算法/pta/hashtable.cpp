#include<stdio.h>
#include<stdlib.h>

struct hash{
	char o;
	int c;
};

int main(){
	struct hash *a;
	int n,p;
	int i,b,x;
	scanf("%d %d",&n,&p);
	a=(struct hash*)malloc(sizeof(struct hash)*p);
	for(i=0;i<p;++i)
		a[i].o=0;
	scanf("%d",&b);
	printf("%d",b%p);
	a[b%p].o=1,a[b%p].c=b;
	for(i=1;i<n;++i){
		scanf("%d",&b);
		x=b%p;

		while(a[(x)].o){
			if(a[x].c==b){
				printf(" %d",x);
				break;
			}
			else x=(x+1)%p;
		}
		if(a[x].c==b) continue;
		a[x].o=1;
		a[x].c=b;
		printf(" %d",x);
	}
	return 0;
}
