%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "tree.h"
%}

/* literals */
%token INTEGER_LITERAL
%token FLOAT_LITERAL
%token CHAR_LITERAL
%token STRING_LITERAL
%token IDENTIFIER

/* keywords */
%token MAIN
%token IF ELSE
%token FOR WHILE DO
%token SWITCH CASE DEFAULT
%token BREAK CONTINUE
%token RETURN
%token INT FLOAT CHAR VOID
%token CONST

/* operators */
%token PLUS MINUS MULT DIV MOD
%token LT GT LE GE EQ NE
%token AND OR NOT
%token INC DEC
%token ASSIGN

/* punctuators */
%token LPAREN RPAREN
%token LBRACE RBRACE
%token LBRACKET RBRACKET
%token SEMICOLON COMMA COLON


%right ASSIGN
%left OR
%left AND
%left EQ NE
%left LT GT LE GE
%left PLUS MINUS
%left MULT DIV MOD
%right NOT UMINUS
%left LPAREN RPAREN LBRACKET RBRACKET

%%
program
    : declaration_list
    ;

declaration_list
    : external_declaration
    | declaration_list external_declaration
    ;

external_declaration
    : function_definition
    | global_declaration
    ;

// FUNCTION DEFINITIONS
function_definition
    : type_specifier MAIN LPAREN param_list_opt RPAREN compound_stmt
    | type_specifier IDENTIFIER LPAREN param_list_opt RPAREN compound_stmt
    ;

param_list_opt
    : param_list
    |
    ;

param_list
    : param
    | param_list COMMA param
    ;

param
    : type_specifier IDENTIFIER
    | type_specifier IDENTIFIER LBRACKET RBRACKET // array parameters 
    ;


/* TYPE SPECIFIERS */
type_specifier
    : INT
    | FLOAT
    | CHAR
    | VOID
    ;


/* COMPOUND STATEMENT */
compound_stmt
    : LBRACE RBRACE
    | LBRACE block_list RBRACE
    ;

block_list
    : block_item
    | block_list block_item
    ;

block_item
    : local_declaration
    | stmt
    ;


/* DECLARATIONS */
global_declaration
    : type_specifier declarator_list SEMICOLON
    | CONST type_specifier declarator_list SEMICOLON
    ;

local_declaration
    : type_specifier declarator_list SEMICOLON
    | CONST type_specifier declarator_list SEMICOLON
    ;

declarator_list
    : declarator
    | declarator_list COMMA declarator
    ;

declarator
    : IDENTIFIER
    | IDENTIFIER ASSIGN initializer
    | IDENTIFIER LBRACKET INTEGER_LITERAL RBRACKET
    | IDENTIFIER LBRACKET INTEGER_LITERAL RBRACKET ASSIGN array_initializer
    ;

initializer
    : assignment_expr
    ;

array_initializer
    : LBRACE initializer_list RBRACE
    | LBRACE RBRACE
    ;

initializer_list
    : initializer
    | initializer_list COMMA initializer
    ;

/* STATEMENTS */
stmt
    : matched_stmt
    | unmatched_stmt
    ;

matched_stmt
    : IF LPAREN expr RPAREN matched_stmt ELSE matched_stmt
    | compound_stmt
    | expression_stmt
    | iteration_matched
    | jump_stmt
    | switch_stmt
    ;

expression_stmt
    : SEMICOLON
    | expr SEMICOLON
    ;

unmatched_stmt
    : IF LPAREN expr RPAREN stmt
    | IF LPAREN expr RPAREN matched_stmt ELSE unmatched_stmt
    | iteration_unmatched
    ;

iteration_matched
    : WHILE LPAREN expr RPAREN matched_stmt
    | DO stmt WHILE LPAREN expr RPAREN SEMICOLON
    | FOR LPAREN for_init_opt SEMICOLON for_cond_opt SEMICOLON for_update_opt RPAREN matched_stmt
    ;

iteration_unmatched
    : WHILE LPAREN expr RPAREN unmatched_stmt
    | FOR LPAREN for_init_opt SEMICOLON for_cond_opt SEMICOLON for_update_opt RPAREN unmatched_stmt
    ;

for_init_opt
    : for_init
    |
    ;

for_init
    : type_specifier IDENTIFIER ASSIGN assignment_expr
    | assignment_expr
    ;

for_cond_opt
    : expr
    |
    ;

for_update_opt
    : for_update
    |
    ;

for_update
    : assignment_expr
    | for_update COMMA assignment_expr
    ;


/* SWITCH STATEMENT */
switch_stmt
    : SWITCH LPAREN expr RPAREN LBRACE case_list RBRACE
    | SWITCH LPAREN expr RPAREN LBRACE RBRACE
    ;

case_list
    : case_clause
    | case_list case_clause
    ;

case_clause
    : CASE constant_expr COLON stmt_list_opt
    | DEFAULT COLON stmt_list_opt
    ;

stmt_list_opt
    : block_list
    |
    ;

constant_expr
    : INTEGER_LITERAL
    | CHAR_LITERAL
    | MINUS INTEGER_LITERAL %prec UMINUS
    ;


/* JUMP STATEMENTS   */
jump_stmt
    : RETURN SEMICOLON
    | RETURN expr SEMICOLON
    | BREAK SEMICOLON
    | CONTINUE SEMICOLON
    ;


/* EXPRESSIONS */
expr
    : assignment_expr
    | expr COMMA assignment_expr
    ;

assignment_expr
    : logical_or_expr
    | logical_or_expr ASSIGN assignment_expr
    ;

logical_or_expr
    : logical_and_expr
    | logical_or_expr OR logical_and_expr
    ;

logical_and_expr
    : equality_expr
    | logical_and_expr AND equality_expr
    ;

equality_expr
    : relational_expr
    | equality_expr EQ relational_expr
    | equality_expr NE relational_expr
    ;

relational_expr
    : additive_expr
    | relational_expr LT additive_expr
    | relational_expr GT additive_expr
    | relational_expr LE additive_expr
    | relational_expr GE additive_expr
    ;

additive_expr
    : multiplicative_expr
    | additive_expr PLUS multiplicative_expr
    | additive_expr MINUS multiplicative_expr
    ;

multiplicative_expr
    : unary_expr
    | multiplicative_expr MULT unary_expr
    | multiplicative_expr DIV unary_expr
    | multiplicative_expr MOD unary_expr
    ;

unary_expr
    : postfix_expr
    | INC unary_expr
    | DEC unary_expr
    | MINUS unary_expr %prec UMINUS
    | NOT unary_expr
    ;

postfix_expr
    : primary_expr
    | postfix_expr LBRACKET expr RBRACKET
    | postfix_expr LPAREN RPAREN
    | postfix_expr LPAREN argument_list RPAREN
    | postfix_expr INC
    | postfix_expr DEC
    ;

primary_expr
    : IDENTIFIER
    | INTEGER_LITERAL
    | FLOAT_LITERAL
    | CHAR_LITERAL
    | STRING_LITERAL
    | LPAREN expr RPAREN
    ;

argument_list
    : assignment_expr
    | argument_list COMMA assignment_expr
    ;

%%
