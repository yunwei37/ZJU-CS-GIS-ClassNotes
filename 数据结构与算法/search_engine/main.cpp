/*the main function of the programme*/
#include<iostream>
#include<fstream>

#include "engine.h" 

using namespace std;

int main() {
	int r;
	cout << "do you want to build the reverse-list(1) or not(0)?" << endl;
	cin >> r;
	if (r)
		building();//build the invested index from the text
	else
		rebuild();//rebuild the index from the output file
	question();//processing query
	return 0;
}



