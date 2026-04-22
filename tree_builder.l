/*Authors: Nathan Beasley and William Potts*/
/*Date: 3/31/26*/
/*Desc: Tokenizes code per given instruction*/
%{
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include "tree_builder.tab.h"

extern FILE *yyin;
%}

%option noyywrap
%x COMMENT

WS [ \t\r\n]+
INT [0-9]+
ID [A-Za-z_][A-Za-z0-9_]*
STRING \"([^\\\n]|(\\.))*\"

%%
{WS} ;
"//".* ;

"/*" { BEGIN(COMMENT); }
<COMMENT>"*/" { BEGIN(INITIAL); }
<COMMENT>\n ;
<COMMENT>. ;



"buildnode" { return BUILDNODE;}
"for" { return FOR; }
"in" { return IN;}
"print" { return PRINT;}
"name" { return NAME;}
"weight" { return WEIGHT;}
"isachildof" { return ISACHILDOF;}

{STRING} { 
    yylval.str = strdup(yytext);
    return STRING;
}
{INT} { 
    yylval.num = atoi(yytext);
    return INT;
}
{ID} { 
    yylval.str = strdup(yytext);
    return ID;
}

"{" {return '{';}
"}" {return '}';}
"[" {return '[';}
"]" {return ']';}
"(" {return '(';}
")" {return ')';}
";" {return ';';}
"," {return ',';}
":" {return ':';}
"=" {return '=';}
"+" {return '+';}
. { printf("<ERROR, %s>\n", yytext); 
    exit(1);}


%%