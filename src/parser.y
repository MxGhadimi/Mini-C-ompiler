%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "tree.h"

extern FILE *token_file;
extern int line_counter;
extern int column_counter;

int readNextToken(void);
void initializeTokenFile(const char* filename);
void closeTokenFile(void);

char current_token_type[64];
char current_token_value[256];
int current_token_line;
int current_token_column;
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

/* TOKEN READING FUNCTIONS */
int readNextToken(void) {
    char line[512];
    
    if (!token_file) return 0;
    
    while (fgets(line, sizeof(line), token_file) != NULL) {
        /* Skip header lines */
        if (strstr(line, "TOKEN LIST") != NULL ||
            strstr(line, "TOKEN TYPE") != NULL ||
            strstr(line, "----------") != NULL ||
            strstr(line, "Total tokens") != NULL) {
            continue;
        }
        
        if (strlen(line) < 5) continue;
        
        /* Parse the line */
        char type[64], value[256];
        int line_num, col_num;
        
        if (sscanf(line, "%63s %255s Line: %d, Col: %d",
                   type, value, &line_num, &col_num) >= 2) {
            
            /* Skip ERROR tokens */
            if (strcmp(type, "ERROR") == 0) {
                fprintf(stderr, "Skipping lexical error: %s\n", value);
                continue;
            }
            
            strcpy(current_token_type, type);
            strcpy(current_token_value, value);
            current_token_line = line_num;
            current_token_column = col_num;
            line_counter = line_num;
            column_counter = col_num;
            
            return 1;
        }
    }
    
    return 0;
}

int yylex(void) {
    if (!readNextToken()) {
        return 0; /* EOF */
    }
    
    /* KEYWORDS */
    if (strcmp(current_token_type, "KEYWORD") == 0) {
        if (strcmp(current_token_value, "main") == 0) return MAIN;
        if (strcmp(current_token_value, "if") == 0) return IF;
        if (strcmp(current_token_value, "else") == 0) return ELSE;
        if (strcmp(current_token_value, "for") == 0) return FOR;
        if (strcmp(current_token_value, "while") == 0) return WHILE;
        if (strcmp(current_token_value, "do") == 0) return DO;
        if (strcmp(current_token_value, "switch") == 0) return SWITCH;
        if (strcmp(current_token_value, "case") == 0) return CASE;
        if (strcmp(current_token_value, "default") == 0) return DEFAULT;
        if (strcmp(current_token_value, "break") == 0) return BREAK;
        if (strcmp(current_token_value, "continue") == 0) return CONTINUE;
        if (strcmp(current_token_value, "return") == 0) return RETURN;
        if (strcmp(current_token_value, "int") == 0) return INT;
        if (strcmp(current_token_value, "float") == 0) return FLOAT;
        if (strcmp(current_token_value, "char") == 0) return CHAR;
        if (strcmp(current_token_value, "void") == 0) return VOID;
        if (strcmp(current_token_value, "const") == 0) return CONST;
    }
    
    /* IDENTIFIER */
    if (strcmp(current_token_type, "IDENTIFIER") == 0) {
        yylval.sval = strdup(current_token_value);
        return IDENTIFIER;
    }
    
    /* INTEGER */
    if (strcmp(current_token_type, "INTEGER") == 0) {
        yylval.sval = strdup(current_token_value);
        return INTEGER_LITERAL;
    }
    
    /* FLOAT */
    if (strcmp(current_token_type, "FLOAT") == 0) {
        yylval.sval = strdup(current_token_value);
        return FLOAT_LITERAL;
    }
    
    /* CHAR */
    if (strcmp(current_token_type, "CHAR") == 0) {
        yylval.sval = strdup(current_token_value);
        return CHAR_LITERAL;
    }
    
    /* STRING */
    if (strcmp(current_token_type, "STRING") == 0) {
        yylval.sval = strdup(current_token_value);
        return STRING_LITERAL;
    }
    
    /* OPERATORS */
    if (strcmp(current_token_type, "OPERATOR") == 0) {
        if (strcmp(current_token_value, "+") == 0) return PLUS;
        if (strcmp(current_token_value, "-") == 0) return MINUS;
        if (strcmp(current_token_value, "*") == 0) return MULT;
        if (strcmp(current_token_value, "/") == 0) return DIV;
        if (strcmp(current_token_value, "%") == 0) return MOD;
        if (strcmp(current_token_value, "++") == 0) return INC;
        if (strcmp(current_token_value, "--") == 0) return DEC;
        if (strcmp(current_token_value, "=") == 0) return ASSIGN;
        if (strcmp(current_token_value, "==") == 0) return EQ;
        if (strcmp(current_token_value, "!=") == 0) return NE;
        if (strcmp(current_token_value, "<") == 0) return LT;
        if (strcmp(current_token_value, ">") == 0) return GT;
        if (strcmp(current_token_value, "<=") == 0) return LE;
        if (strcmp(current_token_value, ">=") == 0) return GE;
        if (strcmp(current_token_value, "&&") == 0) return AND;
        if (strcmp(current_token_value, "||") == 0) return OR;
        if (strcmp(current_token_value, "!") == 0) return NOT;
    }
    
    /* PUNCTUATORS */
    if (strcmp(current_token_type, "PUNCTUATOR") == 0) {
        if (strcmp(current_token_value, "(") == 0) return LPAREN;
        if (strcmp(current_token_value, ")") == 0) return RPAREN;
        if (strcmp(current_token_value, "{") == 0) return LBRACE;
        if (strcmp(current_token_value, "}") == 0) return RBRACE;
        if (strcmp(current_token_value, "[") == 0) return LBRACKET;
        if (strcmp(current_token_value, "]") == 0) return RBRACKET;
        if (strcmp(current_token_value, ";") == 0) return SEMICOLON;
        if (strcmp(current_token_value, ",") == 0) return COMMA;
        if (strcmp(current_token_value, ":") == 0) return COLON;
    }
    
    fprintf(stderr, "Unknown token: %s '%s' at line %d\n",
            current_token_type, current_token_value, current_token_line);
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error at line %d, col %d: %s\n",
            line_counter, column_counter, s);
    fprintf(stderr, "  Current token: %s '%s'\n", 
            current_token_type, current_token_value);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <tokens_file>\n", argv[0]);
        return 1;
    }
    
    token_file = fopen(argv[1], "r");
    if (!token_file) {
        fprintf(stderr, "Cannot open token file: %s\n", argv[1]);
        return 1;
    }
    
    printf("Parsing tokens from: %s\n", argv[1]);
    
    int result = yyparse();
    
    fclose(token_file);
    
    if (result == 0) {
        printf("Parsing successful!\n");
    } else {
        printf("Parsing failed!\n");
    }
    
    return result;
}