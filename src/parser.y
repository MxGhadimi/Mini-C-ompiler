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

/* FUNCTION DEFINITIONS */
function_definition
    : type_specifier MAIN LPAREN optional_parameter_list RPAREN compound_statement
    | type_specifier IDENTIFIER LPAREN optional_parameter_list RPAREN compound_statement
    ;

optional_parameter_list
    : parameter_list
    |
    ;

parameter_list
    : parameter_declaration
    | parameter_list COMMA parameter_declaration
    ;

parameter_declaration
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
compound_statement
    : LBRACE RBRACE
    | LBRACE block_list RBRACE
    ;

block_list
    : block_item
    | block_list block_item
    ;

block_item
    : local_declaration
    | statement
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
    : assignment_expression
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
statement
    : matched_statement
    | unmatched_statement
    ;

matched_statement
    : IF LPAREN expression RPAREN matched_statement ELSE matched_statement
    | compound_statement
    | expression_statement
    | matched_iteration_statement
    | jump_statement
    | switch_statement
    ;

expression_statement
    : SEMICOLON
    | expression SEMICOLON
    ;

unmatched_statement
    : IF LPAREN expression RPAREN statement
    | IF LPAREN expression RPAREN matched_statement ELSE unmatched_statement
    | unmatched_iteration_statement
    ;

matched_iteration_statement
    : WHILE LPAREN expression RPAREN matched_statement
    | DO statement WHILE LPAREN expression RPAREN SEMICOLON
    | FOR LPAREN optional_for_initialization SEMICOLON optional_for_condition SEMICOLON optional_for_update RPAREN matched_statement
    ;

unmatched_iteration_statement
    : WHILE LPAREN expression RPAREN unmatched_statement
    | FOR LPAREN optional_for_initialization SEMICOLON optional_for_condition SEMICOLON optional_for_update RPAREN unmatched_statement
    ;

optional_for_initialization
    : for_initialization
    |
    ;

for_initialization
    : type_specifier IDENTIFIER ASSIGN assignment_expression
    | assignment_expression
    ;

optional_for_condition
    : expression
    |
    ;

optional_for_update
    : for_update_expression
    |
    ;

for_update_expression
    : assignment_expression
    | for_update_expression COMMA assignment_expression
    ;

/* SWITCH STATEMENT */
switch_statement
    : SWITCH LPAREN expression RPAREN LBRACE case_list RBRACE
    | SWITCH LPAREN expression RPAREN LBRACE RBRACE
    ;

case_list
    : case_clause
    | case_list case_clause
    ;

case_clause
    : CASE constant_expression COLON optional_statement_sequence
    | DEFAULT COLON optional_statement_sequence
    ;

optional_statement_sequence
    : block_list
    |
    ;

constant_expression
    : INTEGER_LITERAL
    | CHAR_LITERAL
    | MINUS INTEGER_LITERAL %prec UMINUS
    ;

/* JUMP STATEMENTS */
jump_statement
    : RETURN SEMICOLON
    | RETURN expression SEMICOLON
    | BREAK SEMICOLON
    | CONTINUE SEMICOLON
    ;

/* EXPRESSIONS */
expression
    : assignment_expression
    | expression COMMA assignment_expression
    ;

assignment_expression
    : logical_or_expression
    | logical_or_expression ASSIGN assignment_expression
    ;

logical_or_expression
    : logical_and_expression
    | logical_or_expression OR logical_and_expression
    ;

logical_and_expression
    : equality_expression
    | logical_and_expression AND equality_expression
    ;

equality_expression
    : relational_expression
    | equality_expression EQ relational_expression
    | equality_expression NE relational_expression
    ;

relational_expression
    : additive_expression
    | relational_expression LT additive_expression
    | relational_expression GT additive_expression
    | relational_expression LE additive_expression
    | relational_expression GE additive_expression
    ;

additive_expression
    : multiplicative_expression
    | additive_expression PLUS multiplicative_expression
    | additive_expression MINUS multiplicative_expression
    ;

multiplicative_expression
    : unary_expression
    | multiplicative_expression MULT unary_expression
    | multiplicative_expression DIV unary_expression
    | multiplicative_expression MOD unary_expression
    ;

unary_expression
    : postfix_expression
    | INC unary_expression
    | DEC unary_expression
    | MINUS unary_expression %prec UMINUS
    | NOT unary_expression
    ;

postfix_expression
    : primary_expression
    | postfix_expression LBRACKET expression RBRACKET
    | postfix_expression LPAREN RPAREN
    | postfix_expression LPAREN argument_expression_list RPAREN
    | postfix_expression INC
    | postfix_expression DEC
    ;

primary_expression
    : IDENTIFIER
    | INTEGER_LITERAL
    | FLOAT_LITERAL
    | CHAR_LITERAL
    | STRING_LITERAL
    | LPAREN expression RPAREN
    ;

argument_expression_list
    : assignment_expression
    | argument_expression_list COMMA assignment_expression
    ;

%%