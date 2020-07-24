#include<stdio.h>
#include<string.h>

char printBuffer[100];//用来保存结果以便回溯 
int bufferCount=0;//保存输出字符串长度 
int printCount=0;//用来换行 

void ListMnemonics(char *a);
void printChar(char *chars,char *a);

void printChar(char *chars,char *a){
	printBuffer[bufferCount++]=chars[0];
	ListMnemonics(a+1);
	printBuffer[bufferCount-1]=chars[1];
	ListMnemonics(a+1);
	printBuffer[bufferCount-1]=chars[2];
	ListMnemonics(a+1);
	bufferCount--;
}

void ListMnemonics(char *a){
	if(strlen(a)==0){
		printBuffer[bufferCount]=0;
		printf("%s  ",printBuffer);
		if(printCount==8){ 
			putchar('\n');
			printCount=0;
		}else
			printCount++; 
		return;
	}
	 char t=*a;
	 switch(t){
	 	case '0':case '1':
	 		printBuffer[bufferCount++]=t;
	 		ListMnemonics(a+1);
	 		bufferCount--;
	 		break;
	 	case '2':
			printChar("ABC",a);
	 		break;
	 	case '3':
			printChar("DEF",a);
	 		break;
	 	case '4':
	 		printChar("GHI",a);
	 		break;
		case '5':
	 		printChar("JKL",a);
	 		break;
		case '6':
	 		printChar("MNO",a);
	 		break;
		case '7':
	 		printChar("PRS",a);
	 		break;
		case '8':
	 		printChar("TUV",a);
	 		break;
		case '9':
	 		printChar("WXY",a);
	 		break;		
	 }
}

int main() {
	printf("This program displays mnemonics for a telephone number.\n");
	printf("Number: ");
	char a[100];
	scanf("%s",a);
	ListMnemonics(a);
	return 0;
}
