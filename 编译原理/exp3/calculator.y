%{
#include <stdio.h>
#include <ctype.h>
#include <math.h>

%}

%code requires {

#define YYLTYPE int
#define YYSTYPE int
}

%token NUMBER

%%

command : exp1 {

}
; 
exp1: exp1 '\n' exp {
    printf("%d\n", $3);
}
| exp { 
        printf("%d\n", $1);
};

exp : exp '+' term {
    $$ = $1 + $3;
}
    | exp '-' term {
        $$ = $1 - $3;
}
    | term { $$ = $1; }
    ;

term : term '*' factor {
    $$ = $1 * $3;
}
     | term '/' factor {
    $$ = $1 / $3;
}
     | factor { $$ = $1; }
;

factor : '-' numfactor {
    $$ = - $2;
} 
| numfactor '^' numfactor {
    $$ = pow($1 , $3);
}
    | numfactor { $$ = $1; }
;

numfactor : NUMBER { $$ = $1; }
       | '(' exp ')' { $$ = $2; }
       ;

%%

int main() {
    yyparse();
}


int yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    return 0;
}