//7-7 六度空间 （30 分）
/*“六度空间”理论又称作“六度分隔（
Six Degrees of Separation）”理论。
这个理论可以通俗地阐述为：“你和任何
一个陌生人之间所间隔的人不会超过六个，也就是说，最多通过五
个人你就能够认识任何一个陌生人。”如图1所示。
假如给你一个社交网络图，请你对每个节点计算符合
“六度空间”理论的结点占结点总数的百分比。*/

#include<stdio.h>

//使用单源无权最短路算法，迭代计算路径长度，
//当出现第一个节点路径为7时退出循环，计算经过的节点个数 
int a[10001][10001] = { 0 };// 
int v[10001] = { 0 };
//visit表和邻接矩阵 
struct queue {
	int a[10001];
	int first, last;
	int sum;
}q;

void push(int x) {
	if (q.first == 999)
		q.first = 0;
	else q.first++;
	q.a[q.first] = x;
	q.sum++;
}

int pop() {
	int t = q.a[q.last];
	if (q.last == 999)
		q.last = 0;
	else q.last++;
	q.sum--;
	return t;
}
//循环队列 
int main() {
	int n, m;
	int i, j;
	scanf("%d %d", &n, &m);
	int v1, v2;
	for (i = 0; i < m; ++i) {
		scanf("%d%d", &v1, &v2);
		a[v1][v2] = 1;
		a[v2][v1] = 1;
	}
	int len, now, num;//当前边数值，作为访问标记； 

	for (i = 1; i <= n; ++i){
		//队列初始化	
		q.sum = 0;
		q.first = 999;
		q.last =0;
		len = 0;
		num = 1;
		push(i);
		for (j = 1; j <= n; ++j)
			v[j] = -1;
		v[i]=0;
		while (1) {
			if (q.sum==0) {
				break;
			}
			now = pop();
			for (j = 1; j <= n; ++j) {
				if (a[now][j] && v[j] == -1) {
					push(j);
					v[j] = v[now]+1;
					if(v[j]==7) break;
					++num;
				}
			}
			if(v[j]==7) break;
		}
		double per = 1.0*num / n * 100;
		printf("%d: %.2f%%\n", i, per);
	}
	return 0;
}
