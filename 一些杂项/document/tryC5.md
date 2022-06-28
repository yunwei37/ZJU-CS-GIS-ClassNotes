---
title: c语言手搓一个500+行的类c语言解释器（5）- 语法分析2 tryC的语法分析实现
date: 2020-04-10T22:37:45-08:00
tags: tutorial
---


# 用c语言手搓一个500+行的类c语言解释器: 给编程初学者的解释器教程（5）- 语法分析2: tryC的语法分析实现

项目github地址及源码：
[https://github.com/yunwei37/tryC](https://github.com/yunwei37/tryC)

## tryC的语法分析

完整的tryC文法：

(这里我们用单引号包裹那些在BCNF文法定义中出现但又作为终结符出现的字符)

```c
exp -> term { addop term }
term -> factor { mulop factor }
factor -> number | ( exp ) | Sym | array_name '[' exp ']' | function        // 处理数组单元、函数、变量等
addop -> + | -
mulop -> * | /

boolOR = boolAND { '||' boolAND }
boolAND = boolexp { '||' boolexp }
boolexp -> exp boolop exp | ( boolOR ) | !boolexp
boolop -> > | < | >= | <= | ==

statement -> '{' { statement } '}'                                  |       // 语句块
            if-stmt -> if ( exp ) statement [ else statement ]      |       // 选择语句
            while-stmt -> while ( exp ) statement                   |       // 循环语句
            Sym = exp;                                               |       // 赋值语句
            print ( exp );                                           |       // 输入输出语句
            puts ( Str );                                            |
            read ( Sym );                                            |
            return ( exp );                                          |       // 函数的返回语句
            func func_name statement;                                |       // 函数定义    
            array array_name length;                                 |       // 数组定义  
```

## statement的代码实现

布尔表达式和算术表达式的代码之前已经讲过了，这里看看statement的实现，以及如何在语法分析的同时解释执行：

这里使用的方法是，对于流程控制语句，在语法分析的时候就进行条件判断，如果if判断失败或者while不进入循环块，就跳过该语句块不进行语法分析、解释执行；

其中RETURNFLAG用来表示在函数中返回，跳过剩余的语句；statement默认返回0，当有return语句在其中出现时才需要使用返回值。

### 代码块：

在一个statement中通过花括号包含多个语句

```c
double statement() {
    if (token == '{') {
        match('{');
        while (token != '}') {
            if (RETURNFLAG == statement()) 
                return RETURNFLAG;
        }
        match('}');
    }
    ....
```

### if语句
由于tryC解释器是边进行语法分析，边解释执行的，因此如果不需要解释执行执行某一个语句块，就调用函数

```c
skipStatments()
```

跳过该语句块，不对其进行语法分析，不解释执行；（在if语句和while语句中使用）：

```c
...
    else if (token == If) {
        match(If);
        match('(');
        int boolresult = boolOR();
        match(')');
        if (boolresult) {
            if (RETURNFLAG == statement()) 
                return RETURNFLAG;
        }
        else skipStatments();
        if (token == Else) {
            match('Else');
            if (!boolresult) {
                if (RETURNFLAG == statement())
                    return RETURNFLAG;
            }
            else skipStatments();
        }
    }
...

```

其中skipStatments()的实现如下：

```c
void skipStatments() {
    if(token == '{')
        token = *src++;
    int count = 0;
    while (token && !(token == '}' && count == 0)) {
        if (token == '}') count++;
        if (token == '{') count--;
        token = *src++;
    }
    match('}');
}
```

### while语句

```c
...
    else if (token == While) {
        match(While);
        char* whileStartPos = src;
        char* whileStartOldPos = old_src;
        int boolresult;
        do {
            src = whileStartPos;
            old_src = whileStartOldPos;
            token = '(';
            match('(');
            boolresult = boolOR();
            match(')');
            if (boolresult) {
                if (RETURNFLAG == statement()) 
                    return RETURNFLAG;
            }
            else skipStatments();
        }while (boolresult);
    }
...

```

### 赋值语句

赋值语句的左边可以是数组中间的一个单元，也可以是一个变量，右边是字符串或表达式、字符。

(在下一篇文章中还会提及具体变量赋值的实现)

数组需要先定义才能进行赋值。

```c
...
    else if (token == Sym || token == ArraySym) {
        symbol* s = token_val.ptr;
        int tktype = token;
        int index;
        match(tktype);
        if (tktype == ArraySym) {
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
            if (token == Str) {
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

### 定义函数语句

定义函数的时候并不执行函数体，所以同样跳过语句块；

```c
...
    else if (token == Func) {
        match(Func);
        symbol* s = token_val.ptr;
        s->type = FuncSym;
        match(Sym);
        s->pointer.funcp = src;
        s->value = token;
        skipStatments();
        match(';');
    }
...

```

### 定义数组语句

定义数组并分配空间

```c
...
    else if (token == Array) {
        match(Array);
        symbol* s = token_val.ptr;
        match(Sym);
        match('(');
        int length = (int)expression();
        match(')');
        s->pointer.list = (double*)malloc(sizeof(struct symStruct) * length + 1);
        for (int i = 0; i < length; ++i)
            s->pointer.list[i].type = Num;
        s->value = length;
        s->type = ArraySym;
        match(';');
    }
...

```

### 返回语句

返回RETURNFLAG作为标志；

```c
...
    else if (token == Return) {
        match(Return);
        match('(');
        return_val = expression();
        match(')');
        match(';');
        return RETURNFLAG;
    }
...

```

### 输入输出语句
```c
...
    else if (token == Print || token == Read || token == Puts) {
        int func = token;
        double temp;
        match(func);
        match('(');
        switch (func) {
        case Print: 
            temp = expression();
            printf("%lf\n", temp);
            break;
        case Puts: 
            printf("%s\n", (char*)token_val.ptr);
            match(Str);
            break;
        case Read:
            scanf("%lf", &token_val.ptr->value);
            token_val.ptr->type = Num;
            match(Sym);
        }
        match(')');
        match(';');
    }
    return 0;
}

```

可对照源码查看（如果觉得写得还行麻烦您帮我点个star哦）
[https://github.com/yunwei37/tryC](https://github.com/yunwei37/tryC)
