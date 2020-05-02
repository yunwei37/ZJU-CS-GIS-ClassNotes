/*对于二叉搜索树，我们规定任一结点的
左子树仅包含严格小于该结点的键值，而其右子树包含大
于或等于该结点的键值。如果我们交换每个
节点的左子树和右子树，得到的树叫做镜像二叉搜索树。

现在我们给出一个整数键值序列，请编写程序
判断该序列是否为某棵二叉搜索树或某镜像二叉
搜索树的前序遍历序列，如果是，则输出对应二叉
树的后序遍历序列。*/

//镜像二叉搜索树即为中序遍历序列逆序的搜索树； 
#include<stdio.h>

int a[1005];//序列; 
//deal1 和 printtree1非镜像
//镜像对称； 
int  deal1(int begin, int end) {
	if (begin >= end)
		return 1;
	int flag = 1;
	int i = begin + 1;
	while (i <= end && a[i] <= a[begin])	++i;
	flag &= deal1(begin + 1, i - 1);
	if (i <= end)
		flag &= deal1(i, end);
	//若右子树中有节点小于根节点； 
	while (i <= end) {
		if (a[i] < a[begin])
			return 0;
		++i;
	}
	if (flag) return 1;
	else return 0;
}

int  deal2(int begin, int end) {
	if (begin >= end)
		return 1;
	int flag = 1;
	int i = begin + 1;
	while (i <= end && a[i] >= a[begin])	++i;
	flag &= deal2(begin + 1, i - 1);
	if (i <= end)
		flag &= deal2(i, end);
	while (i <= end) {
		if (a[i] > a[begin])
			return 0;
		++i;
	}
	if (flag) return 1;
	else return 0;
}

void printtree1(int begin, int end) {
	if (begin > end) return;
	if (begin == end) {
		printf("%d ", a[begin]);
		return;
	}
	int i = begin + 1;
	while (i <= end && a[i] <= a[begin])	++i;
	printtree1(begin + 1, i - 1);
	if (i <= end)
		printtree1(i, end);
	printf("%d ", a[begin]);
	return;
}

void printtree2(int begin, int end) {
	if (begin > end) return;
	if (begin == end) {
		printf("%d ", a[begin]);
		return;
	}
	int i = begin + 1;
	while (i <= end && a[i] >= a[begin])	++i;
	printtree2(begin + 1, i - 1);
	if (i <= end)
		printtree2(i, end);
	printf("%d ", a[begin]);
	return;
}

int main() {
	int n, i,j;
	scanf("%d", &n);
	for (i = 0; i < n; ++i)
		scanf("%d", a + i);
	i = 1,j=1;
	int flag1 = 1,flag2=1;
	//flag1;
	while (i < n&&a[i] <= a[0])	++i;
	flag1 &= deal1(1, i - 1);
	if (i < n)
		flag1 &= deal1(i, n - 1);
	//flag2;
	while (j < n&&a[j] >= a[0])	++j;
	flag2 &= deal2(1, j - 1);
	if (j < n)
		flag2 &= deal2(j, n - 1);

	if (flag1) {
		printf("YES\n");
		printtree1(1, i - 1);
		if (i < n)
			printtree1(i, n - 1);
		printf("%d", a[0]);
	}
	else if (flag2) {
		printf("YES\n");
		printtree2(1, j - 1);
		if (j < n)
			printtree2(j, n - 1);
		printf("%d", a[0]);
	}
	else
		printf("NO");
	return 0;
}
