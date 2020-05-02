/*this file included the impliment of query processing*/
#include "engine.h"
#include<iostream>
#include<fstream>
#include<cctype>
#include "trie_tree.h"
#include <ctime>
#include<set>

/*display the search time*/
extern clock_t start, finish;
extern double duration;

/*the map and the filenames declare in the "engine.cpp"*/
extern map<string, inverstlist > words;
extern string filenames[100000];

//the sentence found when finding several words together
struct sentence {
	string word;
	list<int>::iterator position1;
	list<afile>::iterator f;
	//the operator for the compare of two sentence
	bool const operator == (const sentence &s1) {
		if (this->f == s1.f && this->position1 == s1.position1 && this->word==s1.word)
			return true;
		else
			return false;
	}
};
//the operator for the stl set
bool operator > (const sentence &s1,const sentence &s2) {
	if (*s2.position1 > *s1.position1)
		return true;
	else
		return false;
}
//the operator for the stl set
bool operator < (const sentence &s1, const sentence &s2) {
	if (*s2.position1 < *s1.position1)
		return true;
	else
		return false;
}


multiset<sentence> sentences;
set<sentence> sentences_found;

/*find the word and display all the place it appeared*/
bool display_word(string aword) {
	map<string, inverstlist >::iterator word;
	list<afile>::iterator f;
	list<int>::iterator position1;
	ifstream file1;

	/*change the word to lower chacraters*/
	transform(aword.begin(), aword.end(), aword.begin(), ::tolower);
	stemming(aword);//doing the word stemming

	/*find the word in the index*/
	word = words.find(aword);
	if (word != words.end()) {
		cout << "----------------------------------------------" << endl;//out put the word data
		cout << "search for:   " << word->first << " \n" << "appear times:   " << word->second.count << endl;
		f = word->second.files.begin();

		/*find the files contains the word*/
		int count_f=0;
		string line1;
		cout << "displaying the top ten files:"<<endl;//displaying the top ten files include the greatest number of this word
		for (; f != word->second.files.end()&&count_f<10; ++f,++count_f) {
			cout << endl;
			cout <<"the word is in:  "<< filenames[f->index] << " \n" << "appear  "<<f->count <<"  times"<< endl;
			//open each file
			file1.open(filenames[f->index]);
			if (!file1.is_open()) {
				cout << "open file error!" << endl;
			}
			cout << "in these sentence: " << endl;
			int count_p = 0;
			//out put each sentence include the word( the first five sentences )
			for (position1 = f->position.begin(); position1 != f->position.end()&&count_p<5; ++position1,++count_p) {
				//file1.seekg(*position1);
				file1.seekg(*position1, ios::beg);
				getline(file1, line1);
				cout << line1 << endl;
			}
			file1.close();
		}
		//output the remain file names
		if (f != word->second.files.end())
			cout << "\nthe word are also in these files:" << endl;
		while (f != word->second.files.end()) {
			cout << filenames[f->index] << " " << f->count << endl;
			++f;
		}
	}
	return true;
}

//the main fuction of query processing
void question() {
	string line, aword;
	int i;
	int c=1 ,d = 1;
	char ch;
	/*the questioning will continue until 0 is input*/
	while (c) {
		cout << "\ninput a word, or a sentence(which may be search word by word), or a prefix end with *:" << endl;
		cout << "if you want to search word by word: enter 1, or search by sentence enter 0"<<endl;
		cin >> d;
		if (d > 0) {
			//search word by word;
			ch = getchar();
			aword.clear();
			int flag = 1;
			while ((ch = getchar()) != '\n') {
				if (flag) {
					//start the time count
					start = clock();
					flag = 0;
				}
				if (isalpha(ch))
					aword += ch;//get the word
				else if (ch == '*')
					find_prefix(aword);//find prefix
				else {
					display_word(aword);//find the word
					aword.clear();
				}
			}
			display_word(aword);
		}
		else {
			//search the sentence together
			/*get the words in a sentence*/
			aword.clear();
			//sentences.clear();
			ch = getchar();
			int flag = 1;
			int word_count = 0;
			while ((ch = getchar()) != '\n') {
				if (flag) {
					start = clock();//start the time count
					flag = 0;
				}
				if (isalpha(ch))
					aword += ch;//get the word
				else {
					if (find_word(aword))//find each word and put them in the multiset for further processing
						word_count++;
					aword.clear();
				}
			}
			find_word(aword);
			display_sentence(word_count);//display the sentence found
		}
		finish = clock();
		//print the finding data
		duration = ((double)(finish - start)) / CLK_TCK;
		cout << "search in " << duration << " seconds" << endl;
		cout << "continue? 0 is not." << endl;
		cin >> c;
		getchar();//get the '\n'
	}

	return;
}

int count_word = 0;

//this function support the finding of a prefix
bool find_prefix(string aword) {
	list<Trie_node >::iterator next1, cur;
	cur = trie_find(aword);//find the prefix in the trie tree
	travel(cur);//do the inorder travel in the trie tree
	cout << count_word << " words have this prefix" << endl;//print the word number
	return true;
}

//doing the travel in the trie tree
void travel(list<Trie_node >::iterator cur) {
	if (cur->next.begin() == cur->next.end()) {
		display_word(cur->word);
		++count_word;
		return;
	}
	list<Trie_node >::iterator next1;
	for (next1 = cur->next.begin(); next1 != cur->next.end();++next1) {
		travel(next1);
	}
}

//this function find the words and put the found postion in a sentence struct,
//and insert them in the multiset
bool find_word(string aword) {
	map<string, inverstlist >::iterator word;
	list<afile>::iterator f;
	list<int>::iterator position1;
	ifstream file1;
	
	/*change the word to lower chacraters*/
	transform(aword.begin(), aword.end(), aword.begin(), ::tolower);
	stemming(aword);//doing the word stemming
	/*find the word in the index*/
	word = words.find(aword);
	if (word != words.end()) {
		f = word->second.files.begin();
		/*find the files contains the word*/
		string line1;
		for (; f != word->second.files.end(); ++f) {
			for (position1 = f->position.begin(); position1 != f->position.end(); ++position1) {
				sentence n;//insert the position in the multiset
				n.f = f;
				n.position1 = position1;
				sentences.insert(n);
			}
		}
		return true;
	};
	return false;
}

//this function display the sentence for sentence query
void display_sentence(int word_count) {
	list<afile>::iterator f;
	multiset<sentence>::iterator sentence1;
	set<sentence>::iterator sentence2;
	ifstream file1;
	//put the sentence in the multiset with the same number of word count into the set of sentences_found
	sentences_found.clear();
	for (sentence1 = sentences.begin(); sentence1 != sentences.end(); ++sentence1) {
		if (sentences.count(*sentence1) == word_count)
			sentences_found.insert(*sentence1);
	}
	//print the sentence in the sentences_found set
	cout << "the sentences containing these words: " << endl;
	for (sentence2 = sentences_found.begin(); sentence2 != sentences_found.end(); ++sentence2) {
		string line1;
		cout << " in:  " << filenames[sentence2->f->index] << endl;
		file1.open(filenames[sentence2->f->index]);
		if (!file1.is_open()) {
			cout << "open file error!" << endl;
		}
		file1.seekg(*sentence2->position1, ios::beg);
		getline(file1, line1);
		cout << line1 << endl;
			
			file1.close();
	}
		
}
