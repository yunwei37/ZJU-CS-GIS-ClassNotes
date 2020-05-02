//7-20 表达式转换 （25 分）
/*算术表达式有前缀表示法、中缀表示法和后缀表示法
等形式。日常使用的算术表达式是采用中缀表示法，即二
元运算符位于两个运算
数中间。请设计程序将中缀表达式转换为后缀表达式。*/
//baidu的代码不知道神魔鬼.. 

#include<stdio.h>
#include<ctype.h>
#include<vector>
using namespace std;

int main(){
	vector<char> a;
	char ch;
	int x;
	int flag=0;
	ch=getchar();
	if(ch=='(')
		a.push_back(ch);
	else if(ch!='+')
		putchar(ch);
	while((ch=getchar())!='\n'){
		if(isdigit(ch)&&flag){
			putchar(' ');
			putchar(ch);
			flag=0;
		}else if(isdigit(ch)||ch=='.')
			putchar(ch);
		else if(flag&&(ch=='-'||ch=='+')){
			putchar(' ');
			putchar(ch);
			flag=1;			
		}
		else if(ch=='*'||ch=='/'){
			flag=1;
			if(a.empty())
				a.push_back(ch);
			else if(a.back()=='+'||a.back()=='-'||a.back()=='(')
				a.push_back(ch);
			else{
				putchar(' ');
				putchar(a.back());
				a.pop_back();
				a.push_back(ch);
			}
		}else if(ch=='+'||ch=='-'){
			flag=1;
			if(a.empty()||a.back()=='(')
				a.push_back(ch);
			else{
				while(!a.empty()&&(a.back()!='+'&&a.back()!='-')){
					putchar(' ');
					putchar(a.back());
					a.pop_back();
				}if(!a.empty()){
					putchar(' ');
					putchar(a.back());
					a.pop_back();
				}
				a.push_back(ch);
			}
		}else if(ch=='('){
			a.push_back(ch);
		}else{
			while(!a.empty()&&a.back()!='('){
				putchar(' ');
				putchar(a.back());
				a.pop_back();
			}
			if(!a.empty())
				a.pop_back();
		}
	}
	while(!a.empty()){
		putchar(' ');
		putchar(a.back());
		a.pop_back();
	}
	return 0;
}
