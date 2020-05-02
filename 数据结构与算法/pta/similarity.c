#include <iostream>
#include<map>
#include<list>
#include<ctype.h>
#include<string>
#include<cctype>
#include<algorithm>
//倒排索引；
//(inverted index)
using namespace std;
//link[i][i]: words in a file;
//link[j][j]: public words;
int link[105][105];

//index:
map<string, list<int> > words;

int main(int argc, const char * argv[]) {
	int n, i, j, k;
	cin >> n;
	string line, aword;
	map<string, list<int> >::iterator word;
//input
	for (i = 1; i <= n; ++i) {
		int count = 0;
		getline(cin, line);
		while (line[0] != '#') {
			j = 0;
			while (j < line.length()) {
				k = 0;
				aword.clear();
        //create word;
				while (k < 10 && isalpha(line[j])) {
					aword += line[j];
					++j;
					++k;
				}
				while (isalpha(line[j]))
					++j;
          //deal with a word;
				if (aword.length()>=3) {
					transform(aword.begin(), aword.end(), aword.begin(), ::tolower);
					word = words.find(aword);
					if (word==words.end()||word->second.back() != i) {
          //if not in this file but exist: 
						if (word != words.end()) {
							list<int>::iterator f;
							f = word->second.begin();
              //update public words;
							while (f != word->second.end()) {
								link[i][*f]++;
								link[*f][i]++;
								++f;
							}
						}
            //if not exist:
						words[aword].push_back(i);
						++count;
					}
				}
				else
					++j;
			}
			getline(cin, line);
		}
		link[i][i]= count;
	}
//output:
	int m, f1, f2;
	cin >> m;
	double per;
	for (i = 0; i < m; ++i) {
		cin >> f1 >> f2;
		per = 1.0*link[f1][f2] / (link[f1][f1] + link[f2][f2] - link[f1][f2])*100;
		printf("%.1f%%\n", per);
	}
	return 0;
}
