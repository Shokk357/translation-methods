%{
#include "../expression_struct.h"
#include <map>
int yylex(void);
void yyerror(const char *);
std::map<std::string, int> variables;
%}

%union {
    std::string* str;
    int int_value;
    expression_struct* expr;
}

%token<str> NAME
%token<int_value> INT
%token EQUAL PLUS MINUS TIMES DIV LEFT RIGHT SEMICOLON EO POWER

%type<expr> expression
%type<expr> expression1
%type<expr> composition
%type<expr> composition1
%type<expr> factor
%type<expr> pow
%type<expr> pow1
%start main

%%

main: input EO{
    return 0;
}

input: line input
     |
     ;

line: NAME EQUAL expression SEMICOLON {
        std::string str = *$1;
        int val = $3->value;
      variables[str] = val;
      printf("%s = %d;\n", str.c_str(), val);
};

expression
    : composition expression1 { expression_struct* tmp = new expression_struct();
                                int res = $1->value;
                                int count = $2->operations.size();
                                for (int i = 0; i < count; i++){
                                    int val = $2->numbers.front();
                                    char operation = $2->operations.front();
                                    $2->operations.pop_front();
                                    $2->numbers.pop_front();
                                    if (operation == '+'){
                                        res += val;
                                    }
                                    if (operation == '-'){
                                        res -= val;
                                    }
                                }
                                tmp->value = res;
                                $$ = tmp;
                              }
    ;

expression1
    : PLUS composition expression1 { $3->numbers.push_front($2->value);
                                     $3->operations.push_front('+');
                                     $$ = $3;
                                   }
    | MINUS composition expression1 { $3->numbers.push_front($2->value);
                                      $3->operations.push_front('-');
                                      $$ = $3;
                                    }
    | { $$ = new expression_struct(); }
    ;

composition
    : pow composition1 { expression_struct* tmp = new expression_struct();
                            int res = $1->value;
                            int count = $2->operations.size();
                            for (int i = 0; i < count; i++){
                                int val = $2->numbers.front();
                                char operation = $2->operations.front();
                                $2->operations.pop_front();
                                $2->numbers.pop_front();
                                if (operation == '*'){
                                    res *= val;
                                }
                                if (operation == '/'){
                                    if (val == 0){
                                        yyerror("Devision by zero");
                                        return 1;
                                    }
                                    res /= val;
                                }
                            }
                            tmp->value = res;
                            $$ = tmp;
                          }
    ;

composition1
    : TIMES pow composition1 { $3->numbers.push_front($2->value);
                                  $3->operations.push_front('*');
                                  $$ = $3;
                                }
    | DIV pow composition1 { $3->numbers.push_front($2->value);
                                $3->operations.push_front('/');
                                $$ = $3;
                              }
    | { $$ = new expression_struct(); }
    ;

pow
    : factor pow1 {
        expression_struct* tmp = new expression_struct();
        $2->numbers.push_front($1->value);
        int res = 1;
        int count = $2->operations.size();
        for (int i = 0; i < count; i++){
            res = 1;
            int second = $2->numbers.back();
            $2->numbers.pop_back();
            int first = $2->numbers.back();
            $2->numbers.pop_back();
            for (int j = 0; j < second; j++){
                res *= first;
            }
            $2->numbers.push_back(res);
        }
        res = $2->numbers.front();
        tmp->value = res;
        $$ = tmp;
    }
    ;

pow1
    : POWER factor pow1 {
        $3->numbers.push_front($2->value);
        $3->operations.push_front('^');
        $$ = $3;
    }
    | { $$ = new expression_struct(); }
    ;

factor
    : NAME { expression_struct* tmp = new expression_struct();
             if (variables.count(*$1) == 0){
                std::string out = "Undefined variable: " + *$1;
                yyerror(out.c_str());
                return 1;
             } else tmp->value = variables[*$1];
             $$ = tmp;
           }
    | LEFT expression RIGHT { $$ = $2; }
    | MINUS factor { $2->value = -$2->value;
                     $$ = $2;
                   }
    | INT { expression_struct* tmp = new expression_struct();
            tmp->value = $1;
            $$ = tmp;
          }
    ;
%%
