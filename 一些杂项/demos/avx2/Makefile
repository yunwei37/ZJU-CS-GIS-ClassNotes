CXX = gcc

target = avx

includes = $(wildcard ./include/*.h)
src = $(wildcard ./src/*.cpp)
tests = $(wildcard ./tests/*.cpp)
obj = $(src:%.cpp=%.o)
tests_obj = $(tests:%.cpp=%.o)

CXXDEBUG = -g -fsanitize=address -fno-omit-frame-pointer
CXXFLAGS := $(CXXDEBUG) -Iinclude-Wall -Wno-format -Wno-unused -mavx2 -O3 -fno-tree-vectorize
LDFLAGS := -fsanitize=address

all: $(target)

$(target): main.o
	@$(CXX) $(LDFLAGS) $< -o $@

%.o: %.cpp $(includes)
	@$(CXX) $(CXXFLAGS) -c $< -o $@

main.o: main.c
	@$(CXX) $(CXXFLAGS) -c $< -o $@

.PHONY: run
run: $(target)
	@./$(target)

.PHONY: fmt
fmt:
	@clang-format --style=LLVM -i src/*.cpp tests/*.cpp include/*.h main.cpp

.PHONY: clean
clean:
	@rm -rf $(target) $(obj) $(tests_obj) main.o test
