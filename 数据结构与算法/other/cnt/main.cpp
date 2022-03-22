#include "cnt.h"
#include <iostream>
#include <string>

int main(int argc, char *argv[]) {
  std::string input;
  std::unordered_map<std::string, int> result;

  if (argc < 2) {
    std::cout << "Need a string." << std::endl;
    return 0;
  }
  input = argv[1];
  count_double_triple(input, result);
  for (auto r : result) {
    std::cout << r.first << " " << r.second << std::endl;
  }
  return 0;
}
