#include "add.h"
#include <iostream>
#include <assert.h>

inline bool isHex(const std::string &a) {
  if (a.size() <= 2) {
    return false;
  }
  if (!(a[0] == '0' && (a[1] == 'x' || a[1] == 'X'))) {
    return false;
  }
  for(size_t i = 2; i < a.size(); i++) {
    if (!((a[i] >= '0' && a[i] <= '9') || (a[i] >= 'a' && a[i] <= 'f') ||
          (a[i] >= 'A' && a[i] <= 'F'))) {
      return false;
    }
  }
  return true;
}

inline bool isValid(const std::string &a) {
  if (a.size() == 0) {
    return false;
  }
  if (!isHex(a) && a.size() > 1) {
    for (auto c:a) {
      if (c < '0' || c > '9') {
        return false;
      }
    }
    return a[0] != '0';
  }
  return true;
}

int mixplus(const std::string &a, const std::string &b) {
  if (!isValid(a) || !isValid(b)) {
    return -1;
  }
  int x = std::stoi(a.c_str(), nullptr, 0);
  int y = std::stoi(b.c_str(), nullptr, 0);
  return x + y;
  return -1;
}