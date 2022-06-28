---
title: c语言手搓一个500+行的类c语言解释器（2）- 简介和设计
date: 2020-04-10T22:37:45-08:00
tags: tutorial
---

# 用c语言手搓一个500+行的类c语言解释器: 给编程初学者的解释器教程（2）- 简介和设计

项目github地址及源码：
[https://github.com/yunwei37/tryC](https://github.com/yunwei37/tryC)

## 需要了解的一些基本概念

### 编译器和解释器的区别不同

通常我们说的 “编译器” 是一种计算机程序，负责把一种编程语言编写的源码转换成另外一种计算机代码，后者往往是以二进制的形式被称为目标代码(object code)。这个转换的过程通常的目的是生成可执行的程序。

而解释器是一种计算机程序，它直接执行由编程语言或脚本语言编写的代码，它并不会把源代码预编译成机器码，而是一行一行地分析源代码并且直接执行，相对编译器而言可能效率较为低下，但实现也相对简单，并且容易在不同的机器上进行移植（比如x86和mips指令集的机器）。

### 先来看看通常的编译器是如何实现的：

编译器从源码翻译为目标代码大致需要这样几个步骤，每个步骤都依赖于上一个步骤的结果：

1. 词法分析：

    编译器对源程序进行阅读，并将字符序列，也就是源代码中一个个符号收集到称作记号（token）的单元中；比如:

    ```c
        num = 123.4;
    ```

    这样个赋值语句中，变量num算是一个token，“=”符号算是一个token，“123.4”算是一个token；每个token有自己的类别和属性，比如“123.4”的类别是数字，属性（值）是123.4

2. 语法分析：

    语法分析指将词法分析得到的标记流（token）进行分析，组成事先定义好的有意义的语句，这与自然语言中句子的语法分析类似。通常可以用抽象语法树表示语法分析的结果，比如赋值语句：

    ```c
        num = 123.4 * 3;
    ```

    可以用这样一个抽象语法树来表示:

    ```mermaid
        graph TD
        = --> num
        = --> *
        * --> 123.4
        * --> 3
    ```

3. 语义分析：
    程序的语义就是它的“意思”，程序的语义确定程序的运行方式。语义分析阶段通常包括声明和类型检查、计算需要的一些属性值等等。编译器在这个阶段中通常会维护一个叫做“符号表”的东西，保存变量的值、属性和名称。同样以
    
    ```c
        num = 123.4 * 3;
    ```
    
    为例，假如我们是第一次在这里遇见“num”，就将num的名称字符串“num” 和当前计算出来的初始值370.2插入符号表中，当下次再遇见num时。我们就知道它是一个数字，已经初始化完毕，并且当前值是370.2；

4. 目标代码生成：
    在语义分析之后，我们就可以将语法分析和语义分析的结果（通常是抽象语法树）转换成可执行的目标代码。

解释器与编译器仅在代码生成阶段有区别，而在前三个阶段如词法分析、语法分析、语义分析基本是一样的。

当然，已经有许多工具可以帮助我们处理阶段1和2，如 flex 用于词法分析，bison 用于语法分析；但它们的功能都过于强大，屏蔽了许多实现上的细节，对于学习构建编译器帮助不大，所以我们要完全手写这些功能。

> （实际上完成一个可以跑起来的解释器并不难，而且还是一件很有成就感的事，不是嘛？）

## tryC编译器的设计：

从上面可以看出，我们的tryC解释器需要这三个模块：

1. 词法分析
2. 语法分析
3. 语义分析和解释执行

需要这两个数据结构（用来在阶段之间保存或传递值）：

1. token，用来在词法分析和语法分析之间传递标记；
2. 符号表，保存语义分析阶段遇见的变量值，使用一个数组存储；

在了解过这些之后，我们先来大概看看代码的基本结构：

（从上往下在代码中依次对应，“...”表示省略的相关代码，在后续文章中会详细讲解）

- 数据结构的声明部分：token类型、符号表结构：

```c
#include <stdio.h>
...

typedef struct symStruct {  
    int type;                
    char name[MAXNAMESIZE];    
    double value;             
    ..........
} symbol;
symbol symtab[SYMTABSIZE];          // 符号表
int symPointer = 0;             

char* src, * old_src;               // 当前分析的源代码位置指针

// tokens 的枚举类型
enum {
    Num = 128, Char, Str, Array, Func,
    ........
};

// token 的表示形式
int token;                      // current token type
union tokenValue {
    symbol* ptr;               
    double val;                 
} token_val;

```

- 词法分析的两个函数：

```c
// 获取输入流中的下一个记号：
void next() {
    char* last_pos;

    while (token = *src) {
        ++src;
        if(token == AAA ){
            .....
        }else if(token == BBB ){
            .....
        }
    }
}

// 匹配一个记号，并获取下一个token：
void match(int tk) {
    if (token == tk) {
        next();
    }
    else {          // 遇到了一个错误
        exit(-1);
    }
}

```

- 语法分析和语义分析，以及执行阶段：使用递归下降法实现（后面会再提到什么是递归下降法啦）

```c

// 计算表达式的值：
double expression(){}
double factor(){}
double term(){}

// 计算布尔表达式的值：
int boolOR();
int boolAND();
int boolexp();

// 执行一个语句；
double statement();

// 执行一个函数：
double function();

```

- main() 函数，代码的入口，并

```c

int main(int argc, char** argv)
{   
    // 往符号表里面添加关键词
    int i, fd;
    src = "array func else if return while print puts read";
    for (i = Array; i <= Read; ++i) {
        next();
        symtab[symPointer -1].type = i;
    }

    src = old_src = (char*)malloc(POOLSIZE); // 分配空间

    ....

    fd = open(*argv, 0);        // 打开读取文件

    read(fd, src, POOLSIZE - 1);

    src[i] = 0; 
    close(fd);
    next();
    while (token != 0) {        // 一条一条语句执行
        statement();
    }
    return 0;
}

```

## 重要概念

- 编译器/解释器
- 词法分析
- 语法分析
- 语义分析
- token
- 符号表

可参照github源码查看（如果觉得写得还行麻烦您帮我点个star哦）
[https://github.com/yunwei37/tryC](https://github.com/yunwei37/tryC)