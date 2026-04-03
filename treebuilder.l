/*Authors: Nathan Beasley and William Potts*/
/*Date: 3/31/26*/
/*Desc: Tokenizes code per given instruction*/
%{
#include <stdio.h>
#include <stdlib.h>

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



"buildnode" { printf("<BUILDNODE, %s>\n", yytext);}
"for" { printf("<FOR, %s>\n", yytext);}
"in" { printf("<IN, %s>\n", yytext);}
"print" { printf("<PRINT, %s>\n", yytext);}
"name" { printf("<NAME, %s>\n", yytext);}
"weight" { printf("<WEIGHT, %s>\n", yytext);}
"isachildof" { printf("<ISACHILDOF, %s>\n", yytext);}

{STRING} { printf("<STRING, %s>\n", yytext);}
{INT} { printf("<INT, %s>\n", yytext);}
{ID} { printf("<ID, %s>\n", yytext);}

[{}()\[\];,:=+]  { ECHO; }
. { printf("<ERROR, %s>\n", yytext); }


%%

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        if (!fp) {
            perror("Error opening input file");
            return 1;
        }
        yyin = fp;
    }

    yylex();

    if (argc > 1) {
        fclose(yyin);
    }

    return 0;
}