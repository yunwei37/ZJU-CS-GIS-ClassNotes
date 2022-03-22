#include "add.h"
#include <cassert>
#include <iostream>
#include <vector>

struct TestInput {
  int result;
  std::string a;
  std::string b;
  friend std::ostream &operator<<(std::ostream &os, const TestInput &test) {
    os << "TestInput(" << test.result << ", " << test.a << ", " << test.b
       << ")";
    return os;
  }
  bool operator==(const TestInput &test) const { return result == test.result; }
  TestInput do_test() const {
    TestInput test_result;

    test_result.result = mixplus(a, b);
    return test_result;
  }
};

const TestInput test_cases[] = {
    TestInput{0, "0", "0"},        TestInput{0, "0", "0x0"},
    TestInput{3, "2", "0x1"},      TestInput{-1, "", "0"},
    TestInput{-1, "10", "0x"},     TestInput{-1, "10", "0xdeagon"},
    TestInput{-1, "10", "helllo"},
};

int main(void) {
  std::cout << "test start!" << std::endl;
  for (size_t i = 0; i < sizeof(test_cases) / sizeof(test_cases[0]); i++) {
    auto result = test_cases[i].do_test();
    if (!(test_cases[i] == result)) {
      std::cout << "test failed: num " << i << std::endl;
      std::cout << "input: " << test_cases[i].a << " " << test_cases[i].b
                << std::endl;
      std::cout << "result: " << result << std::endl;
      std::cout << "expected: " << test_cases[i] << std::endl;
      exit(1);
    }
  }
  std::cout << "test success!" << std::endl;
  return 0;
}
