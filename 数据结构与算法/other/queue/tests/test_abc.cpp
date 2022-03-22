#include "abc.h"
#include <cassert>
#include <iostream>
#include <vector>

struct TestInput {
  bool vaild;
  std::vector<std::string> result;
  std::string input;
  friend std::ostream &operator<<(std::ostream &os, const TestInput &test) {
    for (auto r : test.result) {
      std::cout << r << " ";
    }
    return os;
  }
  bool do_test() const {
    std::vector<std::string> result;
    bool is_valid;

    is_valid = generate_nine_keys(this->input, result);
    if (is_valid != this->vaild) {
      return false;
    }
    if (result.size() != this->result.size()) {
      return false;
    }
    for (size_t i = 0; i < result.size(); i++) {
      if (result[i] != this->result[i]) {
        return false;
      }
    }
    return true;
  }
};

const TestInput test_cases[] = {
    TestInput{true,
              std::vector<std::string>() = {"tp", "tq", "tr", "ts", "up", "uq",
                                            "ur", "us", "vp", "vq", "vr", "vs"},
              "87"},
    TestInput{true, std::vector<std::string>() = {"01"}, "01"},
    TestInput{false, std::vector<std::string>() = {}, "ab"},
};

int main(void) {
  std::cout << "test start!" << std::endl;
  for (auto test_case : test_cases) {
    if (!test_case.do_test()) {
      std::cout << "test failed:" << std::endl;
      std::cout << test_case;
      exit(1);
    }
  }
  std::cout << "test success!" << std::endl;
  return 0;
}
