#include<list>
#include<string>
#include<iostream>
#include<algorithm>
using namespace std;

list<struct dic> roots;

struct dic {
	string name;
	list<struct dic> subdics;
	list<string> files;
	bool operator < (dic b)
	{
		return this->name < b.name;
	}

	bool operator > (dic b)
	{
		return this->name > b.name;
	}
} root;

void printfile(string name, int space) {
	for (int i = 0; i < space; ++i)
		cout << " ";
	cout << name << endl;
}


void printdic(list<struct dic >::iterator d,int space) {
	for (int i = 0; i < space; ++i)
		cout << " ";
	cout << d->name << endl;
	d->subdics.sort();
	d->files.sort();
	int i = 0;
	if (!d->subdics.empty()) {
		list<struct dic >::iterator subd = d->subdics.begin();
		while (subd != d->subdics.end()) {
			printdic(subd, space + 2);
			++subd;
		}
	}
	if (!d->files.empty()) {
		list<string>::iterator file;
		file = d->files.begin();
		while (file != d->files.end()) {
			printfile(*file, space + 2);
			++file;
		}
	}
}

int main() {
	list<struct dic >::iterator dic1,father;
	root.name= "root";
	roots.push_back(root);
	int n, i, j,k;
	cin >> n;
	string filename;
	for (i = 0; i < n; ++i) {
		cin >> filename;
		j = 0;
		string path;
		father = roots.begin();
		while (j < filename.length()) {
			path.clear();
			while (j < filename.length() && filename[j] != '\\') {
				path += filename[j];
				++j;
			}
			if (filename[j] == '\\') {
				k = 0;
				dic1 = father->subdics.begin();
				while (dic1 != father->subdics.end() && dic1->name != path)	++dic1;
				if (dic1 == father->subdics.end()) {
					struct dic n;
					n.name = path;
					father->subdics.push_back(n);
					father = --(father->subdics.end());
				}
				else {
					father = dic1;
				}
				++j;
			}
			else {
				father->files.push_back(path);
			}
		}
	}
	father = roots.begin();
	printdic(father, 0);
	return 0;
}
