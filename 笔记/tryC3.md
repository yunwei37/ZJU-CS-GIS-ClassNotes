---
title: c语言手搓一个500+行的类c语言解释器（3）- 词法分析
date: 2020-04-10T22:37:45-08:00
tags: tutorial
---

# 用c语言手搓一个500+行的类c语言解释器: 给编程初学者的解释器教程（3）- 词法分析

项目github地址及源码：
[https://github.com/yunwei37/tryC](https://github.com/yunwei37/tryC)

这一篇讲讲在tryC中词法分析器是怎样构建的


## 词法分析器是什么玩意

回想一下上一篇我们说的词法分析阶段，编译器做了这样一件事：

    对源程序进行阅读，并将字符序列，也就是源代码中一个个符号收集到称作记号（token）的单元中

帮编译器执行词法分析阶段的模块，就叫词法分析器啦。词法分析器能够对源码字符串做预处理，以减少语法分析器的复杂程度。

词法分析器以源码字符串为输入，输出为标记流（token stream），即一连串的标记，比如对于源代码中间:

```c
    num = 123.4;
```

这样一个赋值语句中，变量num算是一个token，“=”符号算是一个token，“123.4”算是一个token；每个token有自己的类别和属性，比如“123.4”的类别是数字，属性（值）是123.4；每个token可以用这一对儿表示：{token, token value}，就像“123.4”可以表示为{Num, 123.4}

词法分析器输入上面那句话，就得到这样一个标记流：

```c
{Sym, num}, {'=', assign}, {Num, 123.4}
```

## 词法分析器的具体实现

由于词法分析器对于各个语言基本都是大同小异，在其他地方也有很多用途，并且手工构造的话实际上是一个很枯燥又容易出错的活计，因此其实已经有了不少现成的实现，比如 lex/flex 。

通常词法分析器的实现会涉及到正则表达式、状态机的一些相关知识，或者通过正则表达式用上面那些工具来生成。但对于我们这样一个简单的解释器来说，手工构造词法分析器，并且完全不涉及到正则表达式的知识，理解起来也并不是很困难啦。

### 先来看看token是怎样写的

token的数据结构如下：

```c

int token;                      // current token type
union tokenValue {              // token value
    symbol* ptr;               
    double val;                 
} token_val;
```

- 用一个整型变量 token 来表示当前的 token 是什么类型的；
- 用一个联合体来表示附加的token属性，ptr可以附加指针类型的值，val可以附加数值。

token 的类型采用枚举表示定义：

```c
/* tokens and classes (operators last and in precedence order) */
enum {
    Num = 128, Char, Str, Array, Func,
    Else, If, Return, While, Print, Puts, Read,
    Assign, OR, AND, Equal, Sym, FuncSym, ArraySym, Void,
    Nequal, LessEqual, GreatEqual, Inc, Dec
};
```

比如我们会将“==”标记为Equal，将Num标记为Sym等等。从这里也可以看出，一个标记（token）可能包含多个字符；而词法分析器能减小语法分析复杂度的原因，正是因为它相当于通过一定的编码（采用标记来表示一定的字符串）来压缩和规范化了源码。

另外，一些单个字符我们直接作为token返回，比如：

```c
'}' '{' '(' ')' ';' '[' ']' .....
```

### 词法分析器真正干活的函数们

首先需要说明一下，源码字符串为输入，输出为标记流（token stream），这里的标记流并不是一次性将所有的源代码翻译成长长的一串标记串，而是需要一个标记的时候再转换一个标记，原因如下：

1. 字符串转换成标记流有时是有状态的，即与代码的上下文是有关系的。
2. 保存所有的标记流没有意义且浪费空间。

所以通常的实现是提供一个函数，每次调用该函数则返回下一个标记。这里说的函数就是 next() 。

这是next()的基本框架：其中“AAA”"BBB"是token类型；

```c
void next() {
    while (token = *src) {
        ++src;
        if(token == AAA ){
            .....
        }else if(token == BBB ){
            .....
        }
    }
}
```

用while循环的原因有以下几个：

- 处理错误：
    如果碰到了一个我们不认识的字符，可以指出错误发生的位置，然后用while循环跳过当前错误，获取下一个token并继续编译；

- 跳过空白字符；
    在我们实现的tryC语言中，空格是用来作为分隔用的，并不作为语法的一部分。因此在实现中我们将它作为“不识别”的字符进行跳过。

现在来看看AAA、BBB具体是怎样判断的：

#### 换行符和空白符

```c
...
if (token == '\n') {
    old_src = src;              // 记录当前行，并跳过；
}
else if (token == ' ' || token == '\t') {        }
...

```

#### 注释

```c
...
else if (token == '#') {            // skip comments
    while (*src != 0 && *src != '\n') {
                src++;
    }
}
...

```

#### 单个字符

```c
...
else if ( token == '*' || token == '/'  || token == ';' ||  token == ',' ||
token == '(' || token == ')' || token == '{' || token == '}' ||  token == '[' || token == ']') {
    return;
}

...

```

#### 数字

token 为Num；
token_val.val为值；

```c
...
else if (token >= '0' && token <= '9') {        // process numbers
    token_val.val = (double)token - '0';
    while (*src >= '0' && *src <= '9') {
        token_val.val = token_val.val * 10.0 + *src++ - '0';
    }
    if (*src == '.') {
        src++;
        int countDig = 1;
        while (*src >= '0' && *src <= '9') {
            token_val.val = token_val.val + ((double)(*src++) - '0')/(10.0 * countDig++);
        }
    }
    token = Num;
    return;
}

...

```

#### 字符串

token 为Str；
token_val.ptr保存字符串指针；

```c
...
        else if (token == '"' ) {               // parse string
            last_pos = src;
            char tval;
            int numCount = 0;
            while (*src != 0 && *src != token) {
                src++;
                numCount++;          
            }
            if (*src) {
                *src = 0;
                token_val.ptr = malloc(sizeof(char) * numCount + 8);
                strcpy(token_val.ptr, last_pos);
                *src = token;
                src++;
            }
            token = Str;
            return;
        }

...

```

#### 字符

token 为Char；
token_val.val为值；

```c
...
        else if (token == '\'') {               // parse char
            token_val.val = *src++;
            token = Char;
            src++;
            return;
        }

...

```

#### 变量：这是最复杂的一部分

对变量的处理需要以下几个步骤：
1. 获取完整的变量名：
2. 在符号表中查找变量：
3. 如果在符号表中找到了变量，根据变量不同的类型，返回不同的token值；
4. 如果没有找到，在符号表中间插入新的变量

关于符号表具体的内容，会独立出一篇文章来解释。

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

#### 其他的一些符号，可能需要再多读取一个字符才能确定具体token

```c
...
        else if (token == '=') {            // parse '==' and '='
            if (*src == '=') {
                src++;
                token = Equal;
            }
            return;
        }
        else if (token == '+') {            // parse '+' and '++'
            if (*src == '+') {
                src++;
                token = Inc;
            }
            return;
        }
        else if (token == '-') {            // parse '-' and '--'
            if (*src == '-') {
                src++;
                token = Dec;
            }
            return;
        }
        else if (token == '!') {               // parse '!='
            if (*src == '=') {
                src++;
                token = Nequal;
            }
            return;
        }
        else if (token == '<') {               // parse '<=',  or '<'
            if (*src == '=') {
                src++;
                token = LessEqual;
            }
            return;
        }
        else if (token == '>') {                // parse '>=',  or '>'
            if (*src == '=') {
                src++;
                token = GreatEqual;
            }
            return;
        }
        else if (token == '|') {                // parse  '||'
            if (*src == '|') {
                src++;
                token = OR;
            }
            return;
        }
        else if (token == '&') {                // parse  '&&'
            if (*src == '&') {
                src++;
                token = AND;
            }
            return;
        }

...

```


#### 错误处理

```c
...
        else {
            printf("unexpected token: %d\n", token);
        }

...

```

#### match函数：用于匹配当前token并获取下一个token

```c
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

可对照源码查看（如果觉得写得还行麻烦您帮我点个star哦）
[https://github.com/yunwei37/tryC](https://github.com/yunwei37/tryC)

