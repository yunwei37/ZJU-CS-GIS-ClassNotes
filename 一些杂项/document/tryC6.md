---
title: c语言手搓一个500+行的类c语言解释器（6）- 语义分析：符号表和变量、函数
date: 2020-04-10T22:37:45-08:00
tags: tutorial
---


# 用c语言手搓一个500+行的类c语言解释器: 给编程初学者的解释器教程（6）- 语义分析：符号表和变量、函数

项目github地址及源码：
[https://github.com/yunwei37/tryC](https://github.com/yunwei37/tryC)

这一部分，我们再回过头来看看变量、函数是怎样存储和处理的、以及符号表是怎样构建的。

## 符号表

我们先来回顾一下符号表的定义：

> 符号表是一种用于语言翻译器（例如编译器和解释器）中的数据结构。在符号表中，程序源代码中的每个标识符都和它的声明或使用信息绑定在一起，比如其数据类型、作用域以及内存地址。

简单来说就是，我们在符号表中存储对应的变量的各种信息，在定义的时候对符号表进行插入，以便下次碰见它的时候可以知道这个变量的具体信息。

我们可以在符号表中保存五种变量：Num（数值）, Char（字符）, Str（字符串）, Array（数组）, Func（函数）

tryC符号表的完整定义如下：

```c
/* this structure represent a symbol store in a symbol table */
typedef struct symStruct {  
    int type;                  // 符号的类型:  Num, Char, Str, Array, Func
    char name[MAXNAMESIZE];    // 符号名称
    double value;              // 如果是数值变量，记录它的值; 如果是数组或者字符串，记录它的长度
    union {
        char* funcp;            // 指向函数定义在源代码中位置的字符指针
        struct symStruct* list; // 指向数组列表
    } pointer;
    int levelNum;               // 作用域层
} symbol;
symbol symtab[SYMTABSIZE];      // 用数组定义符号表
int symPointer = 0;             // 符号表数组当前使用的最大下标的指针+1（栈顶 + 1）
int currentlevel = 0;           // 当前作用域层
```

## 作用域

作用域就是程序中定义的变量所存在的区域，超过该区域变量就不能被访问。

（这里就不具体举例介绍了）

作用域可以相互嵌套；当内层作用域和外层作用域存在同名变量时，在内层的程序访问的应当是内层的变量，在外层的程序访问的应当是外层的变量；在函数中的变量，只有在所在函数被调用时才动态地为变量分配存储单元，并在调用结束时回收。

作用域可以是块作用域、函数作用域等，tryC中只实现了函数作用域。

我们可以用currentlevel这个变量记录当前的嵌套深度；

```c
int currentlevel = 0; 
```

对于函数作用域我们可以这样处理：在函数调用时加深作用域层，并把需要传入的参数插入符号表；并在函数退出的时候，删除该作用域层的所有变量，并减少作用域层，对应代码如下：

```c
double function() {
    currentlevel++;
    return_val = 0;

    .....

    while (symtab[symPointer - 1].levelNum == currentlevel) {
        symPointer--;
    }
    currentlevel--;
    return return_val;
}
```

由于插入的变量肯定在符号表数组的最上面，因此只要减少符号表数组最大值的指针就可以表示删除啦。

## 变量

对变量的处理主要分为几个部分：

- 词法分析阶段，当我们遇见一个标识符名称时，需要返回对应的token；
- 在表达式中，当遇见一个变量时，我们需要获取它的值；
- 在定义语句中，对变量进行定义和在符号表中插入相关信息；

### 词法分析阶段

当我们在词法分析的时候，对变量的处理需要以下几个步骤：
1. 获取完整的变量名：
2. 在符号表中查找变量，从上往下查找，这样返回的一定是最近作用域的那个变量：
3. 如果在符号表中找到了变量，根据变量不同的类型，返回不同的token值；
4. 如果没有找到，在符号表中间插入新的变量，返回的token值为void；这时应该对应赋值语句

```c
...
        else if ((token >= 'a' && token <= 'z') || (token >= 'A' && token <= 'Z') || (token == '_')) {
            last_pos = src - 1;             // process symbols
            char nameBuffer[MAXNAMESIZE];
            nameBuffer[0] = token;
            while ((*src >= 'a' && *src <= 'z') || (*src >= 'A' && *src <= 'Z') || (*src >= '0' && *src <= '9') || (*src == '_')) {
                nameBuffer[src - last_pos] = *src;
                src++;
            }
            nameBuffer[src - last_pos] = 0;                 // get symbol name
            int i;
            for (i = symPointer-1; i >= 0; --i) {           // search symbol in symbol table 
                if (strcmp(nameBuffer, symtab[i].name) == 0) {      // if find symbol: return the token according to symbol type
                    if (symtab[i].type == Num || symtab[i].type == Char) {
                        token_val.ptr = &symtab[i];
                        token = Sym;
                    }
                    else if (symtab[i].type == FuncSym) {
                        token_val.ptr = &symtab[i];
                        token = symtab[i].type;
                    }
                    else if (symtab[i].type == ArraySym) {
                        token_val.ptr = &symtab[i];
                        token = symtab[i].type;
                    }
                    else {
                        if (symtab[i].type == Void) {
                            token = Sym;
                            token_val.ptr = &symtab[i];
                        }
                        else token = symtab[i].type;
                    }
                    return;
                }
            }
            strcpy(symtab[symPointer].name, nameBuffer);        // if symbol not found, create a new one 
            symtab[symPointer].levelNum = currentlevel;
            symtab[symPointer].type = Void;
            token_val.ptr = &symtab[symPointer];
            symPointer++;
            token = Sym;
            return;
        }
...

```

### 在表达式中对变量的处理：

在表达式中遇到的标识符可能是三种形式：
1. 普通变量：Char或Num，token_val传递数值类型；
2. 函数变量：进行调用函数操作；
3. 数组变量：获取token_val传递的数组指针，获取下标，进行边界检查，获取元素；

```c
double factor() {
    double temp = 0;
    .....
    else if (token == Sym) {                // 普通变量
        temp = token_val.ptr->value;
        match(Sym);
    }
    else if (token == FuncSym) {            // 函数变量
        return function();
    }
    else if (token == ArraySym) {           // 数组变量
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
```

### 在变量定义语句中对变量的处理

由于是动态类型语言，我们对变量的定义语句也是变量的赋值语句；根据赋值的类型确定变量的类型。进入赋值语句时，传递过来的token_val包含的是一个指向当前变量结构体的指针，赋值就是对其进行操作：

赋值语句的左边可以是数组中间的一个单元，也可以是一个变量，右边是字符串或表达式、字符。

数组需要先定义才能进行赋值。

```c
...
    else if (token == Sym || token == ArraySym) {
        symbol* s = token_val.ptr;
        int tktype = token;
        int index;
        match(tktype);
        if (tktype == ArraySym) {                   // 对数组进行特殊判断：获取要赋值的数组单元；
            match('[');
            index = expression();
            match(']');
            match('=');
            if (index >= 0 && index < s->value) {
                s->pointer.list[index].value = expression();
            }
        }
        else {
            match('=');
            if (token == Str) {                     // 根据赋值类型进行不同的操作
                s->pointer.funcp = (char*)token_val.ptr;
                s->type = Str;
                match(Str);
            }
            else if (token == Char) {
                s->value = token_val.val;
                s->type = Char;
                match(Char);
            }
            else {
                s->value = expression();
                s->type = Num;
            }
        }
        match(';');
    }
...

```

## 函数

tryC的函数实现完整代码：这个函数做了以下几件事：

1. 对变量的作用域进行控制；
2. 将函数参数中的变量直接插入作用域；
3. 保存当前词法分析的源代码位置和token，并跳转到函数定义时的源代码位置和token；
4. 语法分析和执行定义时的函数体，如果碰到返回语句，就将返回值存入return_val；
5. 恢复保存的当前源代码位置和token；
6. 返回值从全局变量return_val中获取；

由于function()函数本身是递归的，且变量作用域等可以得到控制，因此可以实现函数的递归调用。

```c
double function() {
    currentlevel++;
    return_val = 0;             // 对变量的作用域进行控制；

    symbol* s = token_val.ptr;  // 将函数参数中的变量直接插入作用域；
    match(FuncSym);
    match('(');
    while (token != ')') {
        symtab[symPointer] = *token_val.ptr;
        strcpy(symtab[symPointer].name, token_val.ptr->name);
        symtab[symPointer].levelNum = currentlevel;
        symPointer++;
        match(Sym);
        if (token == ',')
            match(',');
    }
    match(')');
    char* startPos = src;                   // 保存当前词法分析的源代码位置和token
    char* startOldPos = old_src;
    int startToken = token;
    old_src = src = s->pointer.funcp;       // 跳转到函数定义时的源代码位置和token；
    token = (int)s->value;
    statement();                            // 语法分析和执行定义时的函数体
    src = startPos;
    old_src = startOldPos;
    token = startToken;                     // 恢复保存的当前源代码位置和token；

    while (symtab[symPointer - 1].levelNum == currentlevel) {
        symPointer--;
    }
    currentlevel--;
    return return_val;
}
```

可对照源码查看（如果觉得写得还行麻烦您帮我点个star哦）
[https://github.com/yunwei37/tryC](https://github.com/yunwei37/tryC)
