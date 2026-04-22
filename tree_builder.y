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
BlockStatement* gProgram = nullptr;

struct BuildFields {
    StringExpr* nameExpr;
    IntExpr* weightExpr;
    StringExpr* parentExpr;

    BuildFields() : nameExpr(nullptr), weightExpr(nullptr), parentExpr(nullptr) {}
};

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
    IntExpr* intExpr;
    StringExpr* stringExpr;
    Statement* stmt;
    BlockStatement* block;
    BuildFields* fields;
}

%token BUILDNODE FOR IN PRINT NAME WEIGHT ISACHILDOF
%token <str> ID STRING
%token <num> INT

%type <num> int_expr
%type <str> string_expr
%type <stmt> stmt build_stmt for_stmt print_stmt
%type <block> stmt_list block_stmt
%type <fields> field_list field

%%

program
    : stmt_list
      {
        gProgram = $1;
      }
    ;

stmt_list
    : stmt_list stmt
      {
        $1->addStatement($2);
        $$ = $1;
      }
    | stmt
      {
        $$ = new BlockStatement();
        $$->addStatement($1);
      }
    ;

stmt
    : build_stmt ';' {$$=$1;}
    | for_stmt ';' {$$=$1;}
    | print_stmt ';' {$$=$1;}
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
        gParseTree.printTree($3);
        free($3);
      }
    ;

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