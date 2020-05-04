
%{
#include <stdio.h>
#include "y.tab.h"
%}

%option noyywrap

%%

[0-9]+ {
    yylval = atoi(yytext);
    return NUMBER;
}

[^ \t\n] {
    return yytext[0];
}

\n {
    return yytext[0];
}

. {}

%%