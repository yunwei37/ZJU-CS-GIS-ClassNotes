#ifndef _INTERSECT_H
#define _INTERSECT_H
#include <string>
#include <vector>

// generate the possible value from the nine keys input
//
// return false if the input is not 1 - 9
bool generate_nine_keys(const std::string &s, std::vector<std::string> &result);

#endif