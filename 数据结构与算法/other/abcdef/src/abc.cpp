#include "abc.h"
#include <iostream>
#include <string_view>

const static std::string_view key_map[10] = {
    {"0"},   {"1"},   {"abc"},  {"def"}, {"ghi"},
    {"jkl"}, {"mno"}, {"pqrs"}, {"tuv"}, {"wxyz"},
};

// return false if the input is not 1 - 9
static bool recursive(const std::string &input, size_t start,
                      std::string &output, std::vector<std::string> &result) {
  if (start == input.size()) {
    // reach the end of input
    result.push_back(output);
    return true;
  }
  if (input[start] < '0' || input[start] > '9') {
    // not a number
    return false;
  }
  const auto key = key_map[input[start] - '0'];
  for (auto k : key) {
    output.push_back(k);
    if (!recursive(input, start + 1, output, result)) {
      return false;
    }
    output.pop_back();
  }
  return true;
}

bool generate_nine_keys(const std::string &input,
                        std::vector<std::string> &result) {
  std::string output;
  if (!recursive(input, 0, output, result)) {
    // wrong input
    return false;
  }
  return true;
}