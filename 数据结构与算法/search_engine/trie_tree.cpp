/*this file include the impliment of trie tree*/
#include "trie_tree.h"

using namespace std;

//the tree node list of single root, for the simplify of the functions below
list<Trie_node> root;

// the insert operation of trie tree
void trie_insert(string s)
{
	int l = s.length();
	list<Trie_node>::iterator next1, cur;
	cur = root.begin();
	for (int i = 0; i < l; i++)
	{	//find the node to insert
		next1 = cur->next.begin();
		while (next1 != cur->next.end() && next1->ch != s[i])
			++next1;
		if (next1 == cur->next.end())
		{	//if not found, create a new node
			Trie_node o;
			o.word = "";
			o.ch = s[i];
			cur->next.push_back(o);
			next1 = --cur->next.end();
		}
		cur = next1;
	}
	//make the node string this word
	cur->word = s;
}

//find the word in the trie tree and return the iterator
list<Trie_node >::iterator trie_find(string s)
{
	int l = s.length();
	list<Trie_node >::iterator next1, cur;
	cur = root.begin();
	//ding the finding
	for (int i = 0; i < l; i++) {
		next1 = cur->next.begin();
		while (next1 != cur->next.end() && next1->ch != s[i])
			++next1;
		if (next1 == cur->next.end()) {
			return next1;
		}
		else
			cur = next1;
	}
	return cur;
}

//create a new trie tree
void ini_trie() {
	Trie_node root1;
	root.push_back(root1);
}



