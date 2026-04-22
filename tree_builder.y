%{
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <string>
#include "parse_tree.h"

extern int yylex();
extern FILE* yyin;
void yyerror(const char* s);

ParseTree gParseTree;

struct NodeSpec 
{
    std::string name;
    int weight = 0;
    std::string parent = "";
    bool hasName = false;
    bool hasWeight = false;
    bool hasParent = false;
};

static NodeSpec currentNode;

static std::string stripQuotes(const std::string& s)
{
    if (s.size() >= 2 && s.front() == '"' && s.back() == '"')
    {
        return s.substr(1, s.size()-2);
    }
    return s;
}
%}

%union 
{
    int num;
    char* str;
}

%token BUILDNODE FOR IN PRINT NAME WEIGHT ISACHILDOF
%token <str> ID STRING
%token <num> INT

%type <num> int_expr
%type <str> string_expr

%%

program
    : stmt_list
    ;

stmt_list
    : stmt_list stmt
    | stmt
    ;

stmt
    : build_stmt ';'
    | for_stmt ';'
    | print_stmt ';'
    ;

build_stmt
    : BUILDNODE
      {
        currentNode = NodeSpec();
      }
       '{' field_list '}'
      {
        if(!currentNode.hasName || !currentNode.hasWeight)
        {
            yyerror("Buildnode missing name or weight");
            YYABORT;
        }

        gParseTree.buildnode(
            currentNode.name,
            currentNode.weight,
            currentNode.hasParent ? currentNode.parent : ""
        );
      }
    ;

field_list
    : field_list field
    | field
    ;

field
    : NAME '=' string_expr ';'
      {
        currentNode.name = $3;
        currentNode.hasName = true;
        free($3);
      }
    | WEIGHT '=' int_expr ';'
      {
        currentNode.weight = $3;
        currentNode.hasWeight = true;
      }
    | ISACHILDOF '=' string_expr ';'
      {
        currentNode.parent = $3;
        currentNode.hasParent = true;
        free($3);
      }
    ;

for_stmt
    : FOR ID IN '[' int_expr ':' int_expr ']' '{' stmt_list '}'
      {

      }
    ;

print_stmt
    : PRINT '(' string_expr ')'
      {
          $$ = new PrintStatement($3);
      }

string_expr
    : STRING
      {
        std::string s = stripQuotes($1);
        free($1);
        $$ = strdup(s.c_str());
      }
    | string_expr '+' INT
      {
        std::string s = std::string($1) + std::to_string($3);
        free($1);
        $$ = strdup(s.c_str());
      }
    | string_expr '+' ID
      {
        int value = gParseTree.getVariable($3);
        std::string s = std::string($1) + std::to_string(value);
        free($1);
        free($3);
        $$ = strdup(s.c_str());
      }
    ;

int_expr
    : INT
      {
        $$ = $1;
      }
    | ID
      {
        $$ = gParseTree.getVariable($1);
        free($1);
      }
    | int_expr '+' int_expr
      {
        $$ = $1 + $3;
      }
    ;
%%