CXX = clang++

target = cnt

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

.PHONY: fmt
fmt:
	@clang-format --style=LLVM -i src/*.cpp tests/*.cpp include/*.h main.cpp

.PHONY: clean
clean:
	@rm -rf $(target) $(obj) $(tests_obj) main.o test
