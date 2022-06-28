---
title: c语言手搓一个500+行的类c语言解释器（4）- 语法分析1：EBNF和递归下降文法
date: 2020-04-10T22:37:45-08:00
tags: tutorial
---

# 用c语言手搓一个500+行的类c语言解释器: 给编程初学者的解释器教程（4）- 语法分析1：EBNF和递归下降文法

项目github地址及源码：
[https://github.com/yunwei37/tryC](https://github.com/yunwei37/tryC)

这一章开始进入解释器的核心部分: 语法分析器；

我们来看看两个概念，EBNF和递归下降文法，以及如何用这两个方法来计算tryC中的表达式。

## 基本概念

就像之前所说的那样，语法分析指将词法分析得到的标记流（token）进行分析，组成事先定义好的有意义的语句。那么如何完成这样一个工作呢？我们可以借助一个叫“BNF”的数学工具。

### BNF与上下文无关文法

Backus-Naur符号（就是众所周知的BNF或Backus-Naur Form）是描述语言的形式化的数学方法，由John Backus (也许是Peter Naur)开发，最早用于描述Algol 60编程语言的语法。

BNF类似一种数学游戏：从一个符号开始（叫做起始标志，实例中常用S表示），然后给出替换前面符号的规则。

BNF语法定义的语言是一个字符串集合，可以按照下述规则书写，这些规则叫做书写规范（产生式规则），例如一个四则运算表达式可以表示为：

```c
exp -> exp op exp | ( exp ) | number
op -> + | - | * | /
```

其中'|'用于表示可选择的不同项，"->"用于表示推导规则，从产生式左边的符号可以推导出产生式右边的符号；

要解析一个表达式，我们可以完成这样一个替换：对于

```c
(3+2)*4
```

可以替换为

```c
    exp => exp op exp => exp * number
        => ( exp ) * number
        => ( exp op exp ) * number
        => ( number + number ) * number
```

其中我们把能够被替换的符号叫做非终结符，不能被替换的叫做终结符。

上下文无关文法就是说，这个文法中所有的产生式左边只有一个非终结符，就像上面写的那个文法一样。通常我们在编译器构建中使用的都是上下文无关文法。

### EBNF

EBNF是基本巴科斯范式(BNF)元语法符号表示法的一种扩展，主要对BNF中常见的两种情况，即重复项和可选项添加了相应的语法规则，如用方括号"[ .... ]"
表示可选部分，用花括号"{ ... }"表示重复出现的部分，如上面那个文法可以改写为：

```c
exp -> exp { op exp } | ( exp ) | number
op -> + | - | * | /
```

又比如对于if语句可以写成：

```c
if-stmt -> if ( exp ) statement; [ else statement; ]
```

### 递归下降文法

递归下降分析法也很简单，就是用函数的调用来模拟BNF的替换过程，我们只需要为每个非终结符定义一个分解函数，它就能从起始非终结符开始，不断地调用非终结符的分解函数，不断地对非终结符进行分解，直到匹配输入的终结符。

当然，递归下降分析并不是对于所有的文法都能正常使用的，例如经典的左递归问题：比如这样一个文法

```c
exp -> exp { op exp } | ( exp ) | number
op -> + | - | * | /
```

对于exp的替换需要调用exp的分解函数，而exp的分解函数一进来就调用它自身（即最左边的符号），就会导致无限递归。这时就需要对文法进行改造。

实际上，EBNF文法就是为了映射递归下降分析法的具体程序实现而设计的，因此我们这里就用EBNF文法来实现递归下降分析。

## 来看看怎样用递归下降文法计算tryC中的表达式

上面说了一大堆，现在看看实际的计算表达式的实现是怎样的呢

### 算术表达式

tryC中需要计算四则运算表达式的EBNF文法如下：

```c
exp -> term { addop term }
term -> factor { mulop factor }
factor -> number | ( exp )
addop -> + | -
mulop -> * | /
```

这里对文法进行了一定的改造，让它能够正确表达四则运算的优先级，同时避免了左递归的问题，具体可以自己试着验证一下。

tryC中算术表达式具体的代码实现(就是上述文法直接转换过来的啦)：

(在下一篇文章中还会提及表达式中对变量的处理过程)

```c
double term() {
    double temp = factor();
    while (token == '*' || token == '/') {
        if (token == '*') {
            match('*');
            temp *= factor();
        }
        else {
            match('/');
            temp /= factor();
        }
    }
    return temp;
}

double factor() {
    double temp = 0;
    if (token == '(') {
        match('(');
        temp = expression();
        match(')');
    }
    else if(token == Num ||  token == Char){
        temp = token_val.val;
        match(Num);
    }
    else if (token == Sym) {
        temp = token_val.ptr->value;
        match(Sym);
    }
    else if (token == FuncSym) {
        return function();
    }
    else if (token == ArraySym) {
        symbol* ptr = token_val.ptr;
        match(ArraySym);
        match('[');
        int index = (int)expression();
        if (index >= 0 && index < ptr->value) {
            temp = ptr->pointer.list[index].value;
        }
        match(']');
    }
    return temp;
}

double expression() {
    double temp = term();
    while (token == '+' || token == '-') {
        if (token == '+') {
            match('+');
            temp += term();
        }
        else {
            match('-');
            temp -= term();
        }
    }
    return temp;
}

```
### 布尔表达式
tryC中同样设计了布尔表达式：

tryC中需要计算四则运算表达式的EBNF文法如下：

```c
boolOR = boolAND { '||' boolAND }
boolAND = boolexp { '||' boolexp }
boolexp -> exp boolop exp | ( boolOR ) | !boolexp
boolop -> > | < | >= | <= | ==
```

代码实现：

```c
int boolexp() {
    if (token == '(') {
        match('(');
        int result = boolOR();
        match(')');
        return result;
    }
    else if (token == '!') {
        match('!');
        return boolexp();
    }
    double temp = expression();
    if (token == '>') {
        match('>');
        return temp > expression();
    }
    else if (token == '<') {
        match('<');
        return temp < expression();
    }
    else if (token == GreatEqual) {
        match(GreatEqual);
        return temp >= expression();
    }
    else if (token == LessEqual) {
        match(LessEqual);
        return temp <= expression();
    }
    else if (token == Equal) {
        match(Equal);
        return temp == expression();
    }
    return 0;
}

int boolAND() {
    int val = boolexp();           
    while (token == AND) {
        match(AND);
        if (val == 0)    return 0;         // short cut
        val = val & boolexp();
        if (val == 0) return 0;
    }
    return val;
}

int boolOR() {
    int val = boolAND();
    while (token == OR) {
        match(OR);
        if (val == 1)    return 1;         // short cut
        val = val | boolAND();
    }
    return val;
}
```

## 一些重要概念

- 终结符/非终结符
- BNF/EBNF
- 上下文无关文法
- 递归下降法


可对照源码查看（如果觉得写得还行麻烦您帮我点个star哦）
[https://github.com/yunwei37/tryC](https://github.com/yunwei37/tryC)
