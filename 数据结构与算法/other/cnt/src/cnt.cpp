#include "cnt.h"
#include <iostream>

void count_double_triple(const std::string &input,
                         std::unordered_map<std::string, int> &result) {
  if (input.size() < 2) {
    return;
  }
  for (size_t i = 0; i < input.size() - 2; i++) {
    std::string s = input.substr(i, 3);
    result[s]++;
    s = input.substr(i, 2);
    result[s]++;
  }
  if (input.size() > 1) {
    std::string s = input.substr(input.size() - 2, 2);
    result[s]++;
  }
  return;
}