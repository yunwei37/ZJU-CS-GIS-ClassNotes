#include<stdio.h>
#include<stdlib.h>
#include<time.h>

// this is a file generator for pressure testing 
int main(){
	int i,j,k,m,n,p;
	FILE *f;
	char a[20]="test";
	char word[18];
	const int buff='z'-'a';
	//create file 
	for(i=10000;i<100000;++i){
		itoa(i,a+4,10);
		f= fopen(a,"w");
		printf("%s\n",a);
		srand(clock());
		//ouput the words
		for(j=0;j<1500;++j){
			fprintf(f," ");
			n=rand()%5;
			//create a word
			for(k=0;k<n;++k){
				word[2*k]=rand()%buff+'a';
				word[2*k+1]=rand()%buff+'A';
			}
			word[2*k]=0;
			fprintf(f,"%s",word);
		}
		fclose(f);
	}
	return 0;
}
