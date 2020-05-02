//6-10 阶乘计算升级版

#include <stdio.h>

void Print_Factorial ( const int N );

int main()
{
    int N;
    scanf("%d", &N);
    Print_Factorial(N);
    return 0;
}

void Print_Factorial ( const int N ){
	
	if(N<0){
		printf("Invalid input");
		return;
	} 
	if(N==0){
		printf("1");
		return;
	} 
	
	char a[1000000]={1},c[1000000];//a为最终结果，c为中间保存上一次的值用来做乘法：a=c*i 
	char p=0;//进位 
	int count=1,i,j,k,b,d;//number to plus：i为阶乘值，count为位数，j为乘数，d计算j的位数，b为乘法进行到哪一位 
	for(i=1;i<=N;i++){//factorial number to plus
		
		for(j=0;j<count;j++){
				c[j]=a[j];
				a[j]=0;		
		}//set up c=a
		
		d=0;
		for(j=i;j;j/=10){
			k=j%10;//each digit
			for(b=0;b<count+1;b++){
				a[b+d]+=c[b]*k+p;
				p=0;
				if(a[b+d]>9){
					p=a[b+d]/10;
					a[b+d]=a[b+d]%10;
				}//处理进位 
			}
			if(p)	a[b+d]=p;
			d++;
		}
		 
		for(j=count+4;j>=0;j--)
			if(a[j]!=0) break;
		count=j+1;//确认count（这步应可以想办法解决 
	}
	
	for(i=count-1;i>=0;i--)
		printf("%d",a[i]);
		
}
