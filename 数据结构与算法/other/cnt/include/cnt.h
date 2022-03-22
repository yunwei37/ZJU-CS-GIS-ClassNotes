#ifndef _INTERSECT_H
#define _INTERSECT_H
#include <string>
#include <unordered_map>

// count the occurance of each double or triple in the input string
void count_double_triple(const std::string &input,
                         std::unordered_map<std::string, int> &result);

#endif