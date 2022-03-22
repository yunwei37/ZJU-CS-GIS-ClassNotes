#include "intersect.h"
#include <errno.h>
#include <iostream>
#include <string>

int main(int argc, char *argv[]) {
  if (argc != 9) {
    std::cout << "usage: check L1p1.x L1p1.y L1p2.x L1p2.y L2p1.x L2p1.y "
                 "L2p2.x L2p2.y"
              << std::endl;
    exit(1);
  }
  double para[8];
  for (size_t i = 0; i < 8; ++i) {
    try {
      para[i] = std::stod(argv[i + 1]);
    } catch (std::invalid_argument &e) {
      std::cout << "invalid argument: " << argv[i + 1] << std::endl;
      exit(1);
    }
  }
  Point x1 = Point(para[0], para[1]);
  Point y1 = Point(para[2], para[3]);
  Point x2 = Point(para[4], para[5]);
  Point y2 = Point(para[6], para[7]);
  if (intersect(x1, y1, x2, y2)) {
    std::cout << "TRUE" << std::endl;
  } else {
    std::cout << "FALSE" << std::endl;
  }
  return 0;
}
