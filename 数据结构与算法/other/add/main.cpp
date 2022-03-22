#include "add.h"
#include <iostream>
#include <string>

int main(int argc, char *argv[]) {
  if (argc != 3) {
    std::cout << "Need two number." << std::endl;
    return 0;
  }
  std::string a = argv[1];
  std::string b = argv[2];
  int x = mixplus(a, b);
  if (x < 0) {
    std::cout << "ERROR" << std::endl;
  }
  std::cout << std::hex << "0x" << x << " ";
  std::cout << std::dec << x << std::endl;
  return 0;
}
