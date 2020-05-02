/*给定某数字A（1≤A≤9）以及非负整数N（0≤N≤100000），
求数列之和S=A+AA+AAA+?+AA?A（N个A）。例如A=1, N=3时，
S=1+11+111=123。*/ 

#include <stdio.h>
#define MAX 100002

int main(){	
int i, j, A, N, flg, temp, carry; 
char output[MAX] = { 0 };
	scanf("%d%d", &A, &N);	flg = 0;
		
	if (N == 0){
		printf("0\n");
		return 0;			
	}

	else if (N == 1){
		printf("%d\n", A);
		return 0;
	}		
	
	carry = 0;//进位数 
	for (i = 0; i < N; i++){		
		output[i] = (A * (N - i) + carry) % 10;	
		carry = (A * (N - i) + carry) / 10;
		}//每一位计算 
		
		while (carry){	
			output[i++] = carry % 10;	
			carry = carry / 10;		
			flg = 1;		
			}//最高位进位 
			
			if (flg == 1){	
				for (i = N; i > 0; i--)		
					printf("%d", output[i]);	
					printf("%d\n", output[i]);		
					}	
			else{		
				for (i = N - 1; i > 0; i--)		
					printf("%d", output[i]);	
					printf("%d\n", output[i]);		
					}

 	return 0;
}

