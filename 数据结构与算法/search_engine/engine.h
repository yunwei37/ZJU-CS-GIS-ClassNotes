/* this file includes the declarations of the engine.cpp*/
#pragma once

#ifndef ENGINE_H_
#define ENGINE_H_

#include<map>
#include<unordered_set>
#include<list>
#include<string>
#include<algorithm>
#include "Stemmer.h"
using namespace std;

/*the main data structs of inverst index*/
//record the file and the position used to output the sentences in the inverst list
struct afile {
	int index;//file index in the name array
	int count;//count the word numbers in this file
	list<int> position;//record the position of sentence
};

//the inverst list of a word
struct inverstlist {
	int count;//count the file numbers include this word
	list< afile> files;//record the files
};

//build the invested index from the text
bool building();

//rebuild the list from the file
bool rebuild();

void question();

void display_sentence(int word_count);

bool find_word(string aword);

bool find_prefix(string aword);

//stemming words
void stemming(string &aword);

//read in and build the stop words in a set
bool stop_words();

//create the trie tree for query
bool create_trie();

/*output the list in the file for rebuilding*/
bool out_file();

#endif
