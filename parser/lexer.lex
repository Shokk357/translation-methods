%{
#include <string>
#include "../expression_struct.h"
#include "parser.h"
%}


white [ \t\r\n]+
digit [0-9]
letter ([A-Za-z_])
symbol {letter}({letter}|{digit})*
int_number ({digit})+

%%
{symbol} {
    yylval.str = new std::string(yytext);
    return NAME;
}
{int_number} {
    yylval.int_value = atoi(yytext);
    return INT;
}

"=" return EQUAL;
";" return SEMICOLON;
"+" return PLUS;
"-" return MINUS;
"*" return TIMES;
"/" return DIV;
"(" return LEFT;
")" return RIGHT;
"^" return POWER;
<<EOF>> return EO;
{white}
%%
