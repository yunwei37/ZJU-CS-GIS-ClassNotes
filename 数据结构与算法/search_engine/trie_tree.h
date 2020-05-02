/*this head file include the declarations of trie tree*/
#pragma once

#ifndef trie_tree_h_
#define trie_tree_h_

#include<string>
#include<list>
using namespace std;

/*the trie node struct*/
struct Trie_node
{
	string word;
	char ch;
	list<Trie_node> next;
};

// the insert operation of trie tree
void trie_insert(string s);

//find the word in the trie tree and return the iterator
list<Trie_node >::iterator trie_find(string s);

//create a new trie tree
void ini_trie();


void travel(list<Trie_node >::iterator cur);

#endif
