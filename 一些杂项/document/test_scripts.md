---
title: 一些可能有用的测试脚本和 Makefile
type: "memo"
date: 2000-03-22 02:31:48
---

## file struct

```
.
├── include
│   └── add.h
├── main.cpp
├── Makefile
├── README.md
├── src
│   └── add.cpp
└── tests
    ├── test_cases.txt
    ├── test_cnt.cpp
    ├── test_results.txt
    └── tests.sh
```

## Makefile

```Makefile
CXX = clang++

target = mixplus

includes = $(wildcard ./include/*.h)
src = $(wildcard ./src/*.cpp)
tests = $(wildcard ./tests/*.cpp)
obj = $(src:%.cpp=%.o)
tests_obj = $(tests:%.cpp=%.o)

CXXDEBUG = -g -fsanitize=address -fno-omit-frame-pointer
CXXFLAGS := $(CXXDEBUG) -Iinclude -std=c++20 -Wall -Wno-format -Wno-unused
LDFLAGS := -fsanitize=address

all: $(target)

$(target): $(obj)  main.o
	@$(CXX) $(LDFLAGS) $(obj) main.o -o $(target)

%.o: %.cpp $(includes)
	@$(CXX) $(CXXFLAGS) -c $< -o $@

main.o: main.cpp

.PHONY: run
run: $(target)
	@./$(target)

test_target: $(tests_obj) $(obj)
	@$(CXX) $(CXXFLAGS) $(tests_obj) $(obj) -o test

.PHONY: test
test: test_target
	@./test
	@tests/tests.sh

.PHONY: fmt
fmt:
	@clang-format --style=LLVM -i src/*.cpp tests/*.cpp include/*.h main.cpp

.PHONY: clean
clean:
	@rm -rf $(target) $(obj) $(tests_obj) main.o test

```

## test.sh

read a line from the test cases and exec, compare it with the result

```sh
#!/bin/bash

TESTS="tests/test_cases.txt"
CASES="tests/test_results.txt"

echo "tests start!"

test_numbers="$(wc -l < $TESTS)"
result_numbers="$(wc -l < $CASES)"
if [ $test_numbers -eq 0 ]; then
    echo "No test cases found!"
    exit 1
fi
if [ $test_numbers -ne $result_numbers ]; then
    echo "Test cases and results are not equal!"
    exit 1
fi

for i in `seq 1 $test_numbers` ; do
    cmd1="sed -n "$i"p $TESTS"
    test_case="$($cmd1)"
    result="$($test_case)"
    cmd2="sed -n "$i"p $CASES"
    test_result="$($cmd2)"
    if [ "$result" == "$test_result" ]; then
        echo "test $i passed!"
    else
        echo $result
        echo $test_result
        echo "test $i failed!"
    fi
done

echo "tests success!"

```