/*vesion 1.0 use stl map in memory implement*/
/*this file include the fuctions used to build or rebuild the index*/

#include <iostream>
#include<ctype.h>
#include<string>
#include<cctype>
#include<fstream>
#include "engine.h"
#include "trie_tree.h"
#include <ctime>
using namespace std;

//time record for building and rebuilding the index  
clock_t start, finish;
double duration;

//a map used to record all the words
map<string, inverstlist > words;

//used to record the name of all the files
string filenames[100000];
int total_number = 0;


//a set to store the stop words
unordered_set<string> stopwords;

/*these two fuction support the sort operation of query,
  arrange according to the word counts in a file*/
//operator for struct afile for list.sort() ( greater )
bool operator < (const afile &a, const afile& b){
	if (a.count > b.count)
		return true;
	else
		return false;
}
//operator for struct afile for list.sort() ( less )
bool operator > (const afile &a, const afile& b){
	if (a.count < b.count)
		return true;
	else
		return false;
}

//read in and build the stop words in a set
bool stop_words() {
	string aword;
	//open the stop word list
	ifstream sw("stop word.txt");
	if (!sw.is_open()) {
		std::cout << "stop word open file error!" << endl;
		return false;
	}
	//read in words one by one
	while (!sw.eof()) {
		sw >> aword;
		stopwords.insert(aword);
	}
	sw.close();
	return true;
}

//rebuild the list from the file
bool rebuild() {
	
	string aword;
	int number,index,fcount,position;
	int word_size;
	map<string, inverstlist >::iterator word;
	int i,j,k;
	//begin to count time;
	start = clock();
	//open the index file
	ifstream input("out.txt");
	//read in the file names and store them in an array
	input >> total_number;
	getline(input, filenames[0]);
	for (i = 0; i < total_number; ++i) 
		getline(input, filenames[i]);
	//get in the total size of words
	input >> word_size;
	for(i=0;i<word_size;++i) {
		input >> aword >> number;//get in the size of files in a word
		words[aword].count = number;
		word = words.find(aword);
		for (j = 0; j < number; ++j) {
			input >> index >> fcount;//get in the file index and position numbers
			afile n;
			n.count = fcount;
			n.index = index;
			//get in each position in the file
			for (k = 0; k < fcount; ++k) {
				input >> position;
				n.position.push_back(position);
			}
			word->second.files.push_back(n);
		}
	}

	input.close();
	//stop time record and print the time and word size of rebuilding index
	finish = clock();
	duration = ((double)(finish - start)) / CLK_TCK;
	cout << "the word size" << words.size() << endl;
	cout << duration << " s" << endl;
	//creat the trie tree for query;
	create_trie();
	
	return true;
}

//stemming words
void stemming(string &aword) {
	char wordc[100] = { 0 };
	//change the string into type "char*"
	for (int g = 0; g < aword.length(); ++g)
		wordc[g] = aword[g];
	//used the word stemming algorithm
	wordc[stem(wordc, 0, aword.length() - 1) + 1] = 0;
	aword = wordc;
}

//create the trie tree for query
bool create_trie() {
	list<int>::iterator position1;
	map<string, inverstlist >::iterator word;
	list<afile>::iterator f;

	ini_trie();
	//scan the words and insert them to the trie tree
	for (word = words.begin(); word != words.end(); ++word) {
		trie_insert(word->first);
	}

	return true;
}

//this fuction build the invested index from the text
bool building() {

	string line, aword;
	map<string, inverstlist >::iterator word;
	list<afile>::iterator f;
	int j, k;
	
	char wordc[100] = { 0 };//for get in the word form the file and do word stemming
	int m=0;

	unordered_set<string>::iterator sw1;
	
	int total_words = 0;

	//build the stop words
	if (!stop_words())
		return false;
	
	//get the file names and put them in a file(in windows)
	system("dir data\\* /b > data\\name.dat");

	//get the file names and put them in a file(in macOS or linux)
	//system("ls data/*.txt >> name.dat");

	//open the file and read the names
	ifstream fnames("data\\name.dat");
	if (!fnames.is_open()) {
		cout << "open data file error!" << endl;
		return false;
	}

	//read the file names into the array
	int i = 0;
	string fname;
	while (!fnames.eof()) {
		filenames[i] = "data\\";
		getline(fnames,fname );
		filenames[i] += fname;
		//cout << filenames[i]<<endl;
		++i;
	}

	ifstream file1;
	
	//begin recording time 
	start = clock();
	total_number = i;//used to record the total word numbers
	for (i = 0; i < total_number-1; ++i) {
		//open each text file
		file1.open(filenames[i]);
		if (!file1.is_open()) {
			cout << "open file error!"<<filenames[i]<< endl;
			return false;
		}
		cout << "openning " << filenames[i]<<endl;
		
		//read in each file
		int before;//before is used to record the position where the line is read in
		while (!file1.eof()) {
			before = file1.tellg();
			getline(file1, line);
			j = 0;
			//process the line word by word
			while (j < line.length()) {
				//get in a word
				m = 0;
				while (isalpha(line[j])) 
					wordc[m++]= line[j++];
				
				wordc[m] = 0;
				// if too short, pass
				if (m >= 3) {
					m = 0;
					//convert the character to lower form
					while (wordc[m] != '\0') {
						wordc[m]=tolower(wordc[m]);
						++m;
					}
					//doing the word stemming
					wordc[stem(wordc, 0, m - 1) + 1] = 0;
					
					aword = wordc;//change char* to cpp string
					++total_words;//add the number to the total word number 

					//if is a stop word, pass
					sw1 = stopwords.find(aword);
					if (sw1 != stopwords.end()) {
						++j;
						continue;
					}
					
					//find the word in the index
					word = words.find(aword);
					if (word != words.end()) {
						// old word
						f = word->second.files.begin();
						//find the file to insert;
						while (f != word->second.files.end() && f->index != i)
							++f;
						//if not found, create a new afile struct and insert
						if (f == word->second.files.end()) {
							afile n;
							n.index = i;
							n.count = 1;
							n.position.push_back(before);
							word->second.files.push_back(n);
							word->second.count++;
						}
						//if has this file(appear again in same file)
						else if(f->position.back()!= before){
							f->count++;
							f->position.push_back(before);
						}
					}
					//if it's a new word, create a new word struct
					else if (word == words.end()) {
						words[aword].count = 1;
						afile n;
						n.index = i;
						n.count = 1;
						n.position.push_back(before);
						words[aword].files.push_back(n);
						//cout << aword << endl;
					}
				}
				++j;
			}
		}
		file1.close();
	}
	//stop time record and print the data
	finish = clock();
	duration = ((double)(finish - start)) / CLK_TCK;
	cout <<"the word size"<< words.size()<<endl;
	cout << duration << " s" << endl;
	cout <<"total words: "<< total_words << endl;

	/*output the list in the file*/
	out_file();
	//create the trie tree for query
	create_trie();
	return true;
}

/*output the list in the file for rebuilding*/
bool out_file() {

	list<int>::iterator position1;
	map<string, inverstlist >::iterator word;
	list<afile>::iterator f;
	//open or creat the output file
	ofstream output("out.txt");
	
	int i;
	//output the filenames
	output << total_number << endl;
	for (i = 0; i < total_number; ++i)
		output << filenames[i] << endl;

	//out put the total word count
	output << words.size()<<endl;
	for (word = words.begin(); word != words.end(); ++word) {
		//out put the information of each word
		output << word->first << " " << word->second.count << endl;
		word->second.files.sort();//sort the files according to the word count for query
		f = word->second.files.begin();
		for (; f != word->second.files.end(); ++f) {
			//out put the data of each file
			output << f->index << " " << f->count << endl;
			for (position1 = f->position.begin(); position1 != f->position.end(); ++position1)
				output << *position1 << " ";
			output << endl;
		}
	}
	//close the output file 
	output.close();
	return true;
} 

