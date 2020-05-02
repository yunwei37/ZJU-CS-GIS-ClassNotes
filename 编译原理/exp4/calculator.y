%{
#include <stdio.h>
#include <ctype.h>
#include <math.h>

%}

%code requires {
typedef enum {
    TYPE_INTEGER,
    TYPE_FLOAT
} value_type_t;

typedef struct {
    int integer_value;
    float float_value;
    value_type_t value_type;
} node;

#define YYLTYPE node
#define YYSTYPE node
}

%token NUMBER

%%

command : exp1 {

}
; 
exp1: exp1 '\n' exp {
    if ($3.value_type == TYPE_INTEGER) {
        printf("%d\n", $3.integer_value);
    } else {
        printf("%f\n", $3.float_value);
    }

}
| exp { 
    if ($1.value_type == TYPE_INTEGER) {
        printf("%d\n", $1.integer_value);
    } else {
        printf("%f\n", $1.float_value);
    }

};

exp : exp '+' term {
    if ($1.value_type == TYPE_INTEGER && $3.value_type == TYPE_INTEGER) {
        $$.value_type = TYPE_INTEGER;
        $$.integer_value = $1.integer_value + $3.integer_value;
    } else if ($1.value_type == TYPE_INTEGER) {
        $$.value_type = TYPE_FLOAT;
        $$.float_value = $1.integer_value + $3.float_value;
    } else if ($3.value_type == TYPE_INTEGER) {
        $$.value_type = TYPE_FLOAT;
        $$.float_value = $1.float_value + $3.integer_value;
    } else {
        $$.value_type = TYPE_FLOAT;
        $$.float_value = $1.float_value + $3.float_value;
    }
}
    | exp '-' term {
    if ($1.value_type == TYPE_INTEGER && $3.value_type == TYPE_INTEGER) {
        $$.value_type = TYPE_INTEGER;
        $$.integer_value = $1.integer_value - $3.integer_value;
    } else if ($1.value_type == TYPE_INTEGER) {
        $$.value_type = TYPE_FLOAT;
        $$.float_value = $1.integer_value - $3.float_value;
    } else if ($3.value_type == TYPE_INTEGER) {
        $$.value_type = TYPE_FLOAT;
        $$.float_value = $1.float_value - $3.integer_value;
    } else {
        $$.value_type = TYPE_FLOAT;
        $$.float_value = $1.float_value - $3.float_value;
    }
}
    | term { $$ = $1; }
    ;

term : term '*' factor {
    if ($1.value_type == TYPE_INTEGER && $3.value_type == TYPE_INTEGER) {
        $$.value_type = TYPE_INTEGER;
        $$.integer_value = $1.integer_value * $3.integer_value;
    } else if ($1.value_type == TYPE_INTEGER) {
        $$.value_type = TYPE_FLOAT;
        $$.float_value = $1.integer_value * $3.float_value;
    } else if ($3.value_type == TYPE_INTEGER) {
        $$.value_type = TYPE_FLOAT;
        $$.float_value = $1.float_value * $3.integer_value;
    } else {
        $$.value_type = TYPE_FLOAT;
        $$.float_value = $1.float_value * $3.float_value;
    }
}
     | term '/' factor {
    if ($1.value_type == TYPE_INTEGER && $3.value_type == TYPE_INTEGER) {
        $$.value_type = TYPE_INTEGER;
        $$.integer_value = $1.integer_value / $3.integer_value;
    } else if ($1.value_type == TYPE_INTEGER) {
        $$.value_type = TYPE_FLOAT;
        $$.float_value = $1.integer_value / $3.float_value;
    } else if ($3.value_type == TYPE_INTEGER) {
        $$.value_type = TYPE_FLOAT;
        $$.float_value = $1.float_value / $3.integer_value;
    } else {
        $$.value_type = TYPE_FLOAT;
        $$.float_value = $1.float_value / $3.float_value;
    }
}
     | factor { $$ = $1; }
;

factor : '-' numfactor {
    if ($2.value_type == TYPE_INTEGER) {
        $$.value_type = TYPE_INTEGER;
        $$.integer_value = - $2.integer_value ;
    } else if ($2.value_type == TYPE_FLOAT) {
        $$.value_type = TYPE_FLOAT;
        $$.float_value = - $2.float_value;
    }
} 
| numfactor '^' numfactor {
    if ($1.value_type == TYPE_INTEGER && $3.value_type == TYPE_INTEGER) {
        $$.value_type = TYPE_INTEGER;
        $$.integer_value = pow($1.integer_value,$3.integer_value);
    } else if ($1.value_type == TYPE_INTEGER) {
        $$.value_type = TYPE_FLOAT;
        $$.float_value = pow($1.integer_value,$3.float_value);
    } else if ($3.value_type == TYPE_INTEGER) {
        $$.value_type = TYPE_FLOAT;
        $$.float_value = pow($1.float_value,$3.integer_value);
    } else {
        $$.value_type = TYPE_FLOAT;
        $$.float_value = pow($1.float_value,$3.float_value);
    }
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