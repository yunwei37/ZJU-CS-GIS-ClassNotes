#include "cnt.h"
#include <cassert>
#include <iostream>
#include <vector>

struct TestInput {
  std::unordered_map<std::string, int> result;
  std::string input;
  friend std::ostream &operator<<(std::ostream &os, const TestInput &test) {
    for (auto r : test.result) {
      os << r.first << " " << r.second << std::endl;
    }
    return os;
  }
  bool operator==(const TestInput &test) const { return result == test.result; }
  TestInput do_test() const {
    TestInput test_result;

    count_double_triple(this->input, test_result.result);
    return test_result;
  }
};

const TestInput test_cases[] = {
    TestInput{std::unordered_map<std::string, int>() =
                  {
                      {"ab", 1},
                  },
              "ab"},
    TestInput{std::unordered_map<std::string, int>() =
                  {
                      {"ab", 1},
                      {"bc", 1},
                      {"cd", 1},
                      {"abc", 1},
                      {"bcd", 1},
                  },
              "abcd"},
    TestInput{std::unordered_map<std::string, int>() =
                  {
                      {"ab", 3},
                      {"ba", 2},
                      {"aba", 2},
                      {"bab", 2},
                  },
              "ababab"},
    TestInput{std::unordered_map<std::string, int>() = {}, ""},
};

int main(void) {
  std::cout << "test start!" << std::endl;
  for (size_t i = 0; i < sizeof(test_cases) / sizeof(test_cases[0]); i++) {
    auto result = test_cases[i].do_test();
    if (!(test_cases[i] == result)) {
      std::cout << "test failed: num " << i << std::endl;
      std::cout << "input: " << test_cases[i].input << std::endl;
      std::cout << "result: " << result << std::endl;
      std::cout << "expected: " << test_cases[i] << std::endl;
      exit(1);
    }
  }
  std::cout << "test success!" << std::endl;
  return 0;
}
