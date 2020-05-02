//7-14 电话聊天狂人 （25 分）
/*输入首先给出正整数N（≤10?5??），为
通话记录条数。随后N行，每行给出一条通话记录。
简单起见，这里只列出拨出方和接收方的11
位数字构成的手机号码，其中以空格分隔。*/

#include<iostream>
#include<map>
using namespace std;
//使用map in stl：第一次 
int main(){
	map<string,int> tele;
	int n,i;
	int max=1;
	string t1,t2;
	cin>>n;
	map<string,int>::iterator tele1;
	for(i=0;i<n;++i){
		cin>>t1>>t2;
		if((tele1=tele.find(t1))!=tele.end()){
			tele1->second++;
			if(tele1->second>max)
				max=tele1->second;			
		}
		else
			tele.insert(pair<string,int>(t1,1));
		if((tele1=tele.find(t2))!=tele.end()){
			tele1->second++;
			if(tele1->second>max)
				max=tele1->second;			
		}
		else
			tele.insert(pair<string,int>(t2,1));
	}
	int count=0;
	for(tele1=tele.begin();tele1!=tele.end();++tele1){
		if(tele1->second==max&&!count){
			cout<<tele1->first<<" "<<max;
			++count;			
		}

		else if(tele1->second==max)
			++count;
	}
	if(count>1)
		cout<<" "<<count;
	return 0;
}
