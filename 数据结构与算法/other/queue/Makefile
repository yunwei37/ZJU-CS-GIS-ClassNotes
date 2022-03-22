CXX = clang++

target = abc

includes = $(wildcard ./include/*.h)
src = $(wildcard ./src/*.cpp)
tests = $(wildcard ./tests/*.cpp)
obj = $(src:%.cpp=%.o)
tests_obj = $(tests:%.cpp=%.o)

CXXFLAGS := -Iinclude -std=c++20
LDFLAGS := -lpthread

all: $(target)

$(target): $(obj)  main.o
	$(CXX) $(LDFLAGS) $(obj) main.o -o $(target)

%.o: %.cpp $(includes)
	$(CXX) $(CXXFLAGS) -c $< -o $@

main.o: main.cpp

run: $(target)
	./$(target)

test: $(tests_obj) $(obj)
	$(CXX) $(CXXFLAGS) -g $(tests_obj) $(obj) -o test
	./test

fmt:
	clang-format --style=LLVM -i src/*.cpp tests/*.cpp include/*.h main.cpp

.PHONY: clean
clean:
	rm -rf $(target) $(obj) $(tests_obj) main.o test
