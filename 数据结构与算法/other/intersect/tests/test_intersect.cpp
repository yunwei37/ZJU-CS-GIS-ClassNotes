#include "intersect.h"
#include <cassert>
#include <iostream>

struct TestInput {
  Point x1, y1, x2, y2;
  bool result;
  friend std::ostream &operator<<(std::ostream &os, const TestInput &test) {
    os << test.x1 << std::endl;
    os << test.y1 << std::endl;
    os << test.x2 << std::endl;
    os << test.y2 << std::endl;
    os << "expect:" << test.result << std::endl;
    return os;
  }
};

const TestInput test_cases[] = {
    TestInput{Point(1, 0), Point(0, 0), Point(1, 0), Point(0, 0), true},
    TestInput{Point(1, 1), Point(0, 0), Point(1, 0), Point(0, 1), true},
    TestInput{Point(3, 3), Point(2, 2), Point(1, 0), Point(0, 1), false},
    TestInput{Point(1, 1), Point(0, 0), Point(2, 2), Point(0, 0), true},
    TestInput{Point(3, 3), Point(1, 1), Point(-1, -1), Point(0, 0), false},
    TestInput{Point(0, 0), Point(1, 1), Point(0, -1), Point(1, 0), false},
    TestInput{Point(3.43, 3), Point(1.34, 1), Point(-1.1, -1), Point(0, 0.12),
              false},
};

int main(void) {
  std::cout << "test start!" << std::endl;
  for (auto test_case : test_cases) {
    if (intersect(test_case.x1, test_case.y1, test_case.x2, test_case.y2) !=
        test_case.result) {
      std::cout << "test failed:" << std::endl;
      std::cout << test_case;
      exit(1);
    }
  }
  std::cout << "test success!" << std::endl;
  return 0;
}
