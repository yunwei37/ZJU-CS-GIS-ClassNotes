#include<stdio.h>
#define MAX 100000

int max3(int a,int b,int c){
	if(a>b)
		if(a>c) return a;
		else return c;
	else
		if(b<c) return c;
		else return b;
}

int MaxSubsequenceSum_n(void){
	int n,i,a,sum=0,max=0;
	scanf("%d",&n);
  	for(i=0;i<n;i++){
    	scanf("%d",&a);
    	sum+=a;
    	if(sum<0) sum=0;
    	if(max<sum) max=sum;
	}
	return max;
}

int MaxSubsequenceSum_n2(void){
	int n,a[MAX],sum=0,max=0;
	int i,j;
	scanf("%d",&n);
  	for(i=0;i<n;i++)
  		scanf("%d",a+i);
  	for(i=0;i<n;i++){
  		sum=0;
  		for(j=i;j<n;j++){
  			sum+=a[j];
  			if(sum>max)
  				max=sum;
		  }
	  }
	  return max;
}

int MaxSubsequenceSum_n3(void){
	int n,a[MAX],sum=0,max=0;
	int i,j,k;
	scanf("%d",&n);
  	for(i=0;i<n;i++)
  		scanf("%d",a+i);
  	for(i=0;i<n;i++)
	  	for(j=i;j<n;j++){
  		sum=0;
  		for(k=i;k<=j;k++)
  			sum+=a[k];
  		if(sum>max)
  			max=sum;
	  }
	  return max;
}

int mss(int a[],int left,int right){
	if(left==right)
		if(a[left]>0) return a[left];
		else return 0;
/*	if(right-left==1)
		if(a[left]>0&&a[right]>0) return a[left]+a[right];
		else if(a[left]>0||a[right]>0) return a[left]>0?a[left]:a[right];
		else return 0; */
	int maxsumleft,maxsumright;
	int maxborderleft=0,maxborderright=0;
	int mid,sum,i;
	mid=(right-left)/2+left;
	maxsumleft=mss(a,left,mid);
	maxsumright=mss(a,mid+1,right);
	
	sum=0,i=mid;
	while(i>=left){
		sum+=a[i--];
		if(sum>maxborderleft) 
			maxborderleft=sum;
	}
	
	sum=0,i=mid+1;
	while(i<=right){
		sum+=a[i++];
		if(sum>maxborderright) maxborderright=sum;
	}
	return max3(maxsumleft,maxsumright,maxborderleft+maxborderright);
}

int MaxSubsequenceSum_logn(void){
	int n,a[MAX],sum=0,max=0;
	int i,j;
	scanf("%d",&n);
  	for(i=0;i<n;i++)
  		scanf("%d",a+i);
  	return mss(a,0,n-1);
}

int main(){
  int sum;
  sum=MaxSubsequenceSum_n3();  
  printf("%d",sum);
  return 0;
}
