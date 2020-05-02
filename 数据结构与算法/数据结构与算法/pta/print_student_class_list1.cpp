//7-49 打印学生选课清单 （25 分）
#include<bits/stdc++.h>//万能头文件get 
using namespace std;
//参考： https://blog.csdn.net/Dream_Weave/article/details/81185805
//不使用优先队列而在最后进行sort排序； 
map<string,vector<int> > mp;
//不能用cin... 
int main(){
    int n,m;
    scanf("%d%d",&n,&m);
    int k,id;
    char name[7];
    for(int i=0;i<m;i++){
        scanf("%d%d",&id,&k);
        for(int j=0;j<k;j++){
            scanf("%s",name);
            mp[name].push_back(id);
        }
    }
    vector<int> tpq;
    for(int i=0;i<n;i++){
            scanf("%s",name);
            tpq=mp[name];
            printf("%s",name);
            printf(" %d",tpq.size());
            sort(tpq.begin(),tpq.end());
        vector<int>::iterator tpq1=tpq.begin();
        while(tpq1!=tpq.end()){   
            printf(" %d",*tpq1);
            ++tpq1;
        }
        printf("\n");
    }
    return 0;
}
