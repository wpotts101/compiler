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
    : build_stmt ';'   { $$ = $1; }
    | for_stmt ';'     { $$ = $1; }
    | print_stmt ';'   { $$ = $1; }
    ;

build_stmt
    : BUILDNODE '{' field_list '}'
      {
          if ($3->nameExpr == nullptr || $3->weightExpr == nullptr) {
              yyerror("buildnode missing required field");
              YYABORT;
          }

          $$ = new BuildNodeStatement($3->nameExpr, $3->weightExpr, $3->parentExpr);
          delete $3;
      }
    ;

field_list
    : field_list field
      {
          if ($2->nameExpr != nullptr) $1->nameExpr = $2->nameExpr;
          if ($2->weightExpr != nullptr) $1->weightExpr = $2->weightExpr;
          if ($2->parentExpr != nullptr) $1->parentExpr = $2->parentExpr;
          delete $2;
          $$ = $1;
      }
    | field
      {
          $$ = $1;
      }
    ;

field
    : NAME '=' string_expr ';'
      {
          $$ = new BuildFields();
          $$->nameExpr = $3;
      }
    | WEIGHT '=' int_expr ';'
      {
          $$ = new BuildFields();
          $$->weightExpr = $3;
      }
    | ISACHILDOF '=' string_expr ';'
      {
          $$ = new BuildFields();
          $$->parentExpr = $3;
      }
    ;

for_stmt
    : FOR ID IN '[' int_expr ':' int_expr ']' block_stmt
      {
          $$ = new ForStatement($2, $5, $7, $9);
          free($2);
      }
    ;

block_stmt
    : '{' stmt_list '}'
      {
          $$ = $2;
      }
    ;

print_stmt
    : PRINT '(' string_expr ')'
      {
          $$ = new PrintStatement($3);
      }
    ;

string_expr
    : STRING
      {
          $$ = new StringLiteral(stripQuotes($1));
          free($1);
      }
    | string_expr '+' int_expr
      {
          $$ = new StringConcatExpr($1, new StringFromIntExpr($3));
      }
    ;

int_expr
    : INT
      {
          $$ = new IntLiteral($1);
      }
    | ID
      {
          $$ = new IntVariable($1);
          free($1);
      }
    | int_expr '+' int_expr
      {
          $$ = new IntAddExpr($1, $3);
      }
    ;

%%

void yyerror(const char* s) {
    std::cerr << "Parse error: " << s << std::endl;
}

int main(int argc, char** argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Could not open input file");
            return 1;
        }
    }

    try {
        yyparse();

        if (gProgram != nullptr) {
            gProgram->execute(gParseTree);
            delete gProgram;
        }
    }
    catch (const std::exception& e) {
        std::cerr << "Runtime error: " << e.what() << std::endl;
        return 1;
    }

    if (argc > 1) {
        fclose(yyin);
    }

    return 0;
}