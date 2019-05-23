#include <bits/stdc++.h>
#include "expression_struct.h"
#include "cmake-build-debug/lexer.h"
#include "cmake-build-debug/parser.h"
using namespace std;


extern int yydebug;
extern int yylineno;

void yyerror(const char *error) {
    cerr << error << endl;
}

int yywrap() { return 1; }




int main() {
    yyparse();
    return 0;
}
