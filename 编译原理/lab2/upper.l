%{
        /*  
            实验二、利用LEX进行字母的大小写转换
            将本书中的tiny语言关键字大写的程序：
            注释放在花括号中;
        */
#include <ctype.h>
#include <stdio.h>
#include <string.h>

int state = 0;     // 0：可接受关键字；1：接受关键字；2：错误
char buffer[20]; // 用于保存关键字在下一次输出

%}


%option noyywrap

%%

[" "\n\t;()]|"{".*"}" {
    if(state == 1){
        for (int i = 0; i < strlen(buffer); ++i) 
            putchar( toupper(buffer[i]) );
    }
    state = 0;
    printf("%s", yytext);
}

if|then|else|end|repeat|until|read|write {
    if( state == 0 ){
        strcpy(buffer,yytext);
        state = 1;
    }else{
        if(state == 1)
            printf("%s", buffer); 
        state = 2;
        printf("%s", yytext);
    }
}

. { 
    if(state == 1)
        printf("%s", buffer); 
    state = 2;
    printf("%s", yytext);
}

%%

int main() {
    yylex();
    if(state == 1)
        for (int i = 0; i < strlen(buffer); ++i)
                putchar( toupper(buffer[i]) );
    return 0;
}
