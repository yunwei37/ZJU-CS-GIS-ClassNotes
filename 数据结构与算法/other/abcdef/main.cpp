#include "abc.h"
#include <iostream>
#include <string>

int main(int argc, char *argv[]) {
  std::string input;
  std::vector<std::string> result;

  std::cout << "please input a series of digit:" << std::endl;
  std::cin >> input;
  if (!generate_nine_keys(input, result)) {
    std::cout << "invalid input!" << std::endl;
  }
  for (auto r : result) {
    std::cout << r << " ";
  }
  std::cout << std::endl;
  return 0;
}
