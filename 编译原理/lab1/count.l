
%{
    /*
        实验一、利用LEX计算文本文件的字符数等
    */
#include <stdio.h>

int char_count = 0, word_count = 0, line_count = 1;

int flag = 0; // 0: words acceptable

%}

%option noyywrap

%%

\n {
    ++char_count;
    ++line_count;
    if(flag == 1)
        ++word_count;
    flag = 0;
}

[" "\n\t] {
    if(flag == 1)
        ++word_count;  // 1: read in a word
    flag = 0;    // 0: words acceptable
    ++char_count;
}

[A-Za-z0-9]+ {
    if(flag == 0)
        flag = 1;    // 1： find a word
    char_count += yyleng;
}

. { 
    flag = 2; // error 2: find a symbol in a word
    ++char_count; 
}

%%

int main() {
    yylex();
    if(flag == 1)
        ++word_count;  // 1: read in a word
    printf(" char: %d\n word: %d\n line: %d\n", char_count, word_count, line_count);
    return 0;
}
