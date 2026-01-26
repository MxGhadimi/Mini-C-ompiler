%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

/* Global variables */
FILE *token_file = NULL;
int line_counter = 1;
int column_counter = 1;
int error_count = 0;
int token_count = 0;

char string_buffer[4096];
int string_ptr;
int string_start_line;
int string_start_col;

char char_buffer[16];
int char_length;
int char_start_line;
int char_start_col;

/* Functions */
void storeToken(const char* type, const char* value);
void updateColumnPos();
void initTokenFile(const char* filename);
void closeTokenFile();
void lexicalError(const char* errorType, const char* lexeme);
char process_escape(char escape_char);
bool is_valid_escape(char c);
%}

%option noyywrap
%option noinput
%option nounput

%x STRING_STATE
%x CHAR_STATE
%x COMMENT_STATE

/* Regular definitions */
DIGIT       [0-9]
LETTER      [a-zA-Z_]
IDENTIFIER  {LETTER}({LETTER}|{DIGIT})*
WHITESPACE  [ \t]+
NEWLINE     \n
INT         {DIGIT}+
FLOAT       ({DIGIT}+\.{DIGIT}*|{DIGIT}*\.{DIGIT}+)([eE][+-]?{DIGIT}+)?|{DIGIT}+[eE][+-]?{DIGIT}+


%%
    /* KEYWORDS */
"main"      { storeToken("KEYWORD", yytext); updateColumnPos(); }
"for"       { storeToken("KEYWORD", yytext); updateColumnPos(); }
"while"     { storeToken("KEYWORD", yytext); updateColumnPos(); }
"do"        { storeToken("KEYWORD", yytext); updateColumnPos(); }
"if"        { storeToken("KEYWORD", yytext); updateColumnPos(); }
"else"      { storeToken("KEYWORD", yytext); updateColumnPos(); }
"switch"    { storeToken("KEYWORD", yytext); updateColumnPos(); }
"case"      { storeToken("KEYWORD", yytext); updateColumnPos(); }
"break"     { storeToken("KEYWORD", yytext); updateColumnPos(); }
"continue"  { storeToken("KEYWORD", yytext); updateColumnPos(); }
"default"   { storeToken("KEYWORD", yytext); updateColumnPos(); }
"return"    { storeToken("KEYWORD", yytext); updateColumnPos(); }
"void"      { storeToken("KEYWORD", yytext); updateColumnPos(); }
"int"       { storeToken("KEYWORD", yytext); updateColumnPos(); }
"float"     { storeToken("KEYWORD", yytext); updateColumnPos(); }
"char"      { storeToken("KEYWORD", yytext); updateColumnPos(); }

    /* NUMBERS */
{INT}       { storeToken("INTEGER", yytext); updateColumnPos(); }
{FLOAT}     { storeToken("FLOAT", yytext); updateColumnPos(); }

    /* Ill formed numbers */
{DIGIT}+{LETTER}+({LETTER}|{DIGIT})* { lexicalError("Invalid number/identifier", yytext); updateColumnPos(); }
{DIGIT}*\.{DIGIT}*\.({DIGIT}|\.)*    { lexicalError("Too many decimal points", yytext); updateColumnPos(); }

    /* OPERATORS */
"++"        { storeToken("OPERATOR", yytext); updateColumnPos(); }
"--"        { storeToken("OPERATOR", yytext); updateColumnPos(); }
"+"         { storeToken("OPERATOR", yytext); updateColumnPos(); }
"-"         { storeToken("OPERATOR", yytext); updateColumnPos(); }
"*"         { storeToken("OPERATOR", yytext); updateColumnPos(); }
"/"         { storeToken("OPERATOR", yytext); updateColumnPos(); }
"%"         { storeToken("OPERATOR", yytext); updateColumnPos(); }
"<="        { storeToken("OPERATOR", yytext); updateColumnPos(); }
">="        { storeToken("OPERATOR", yytext); updateColumnPos(); }
"=="        { storeToken("OPERATOR", yytext); updateColumnPos(); }
"!="        { storeToken("OPERATOR", yytext); updateColumnPos(); }
"<"         { storeToken("OPERATOR", yytext); updateColumnPos(); }
">"         { storeToken("OPERATOR", yytext); updateColumnPos(); }
"="         { storeToken("OPERATOR", yytext); updateColumnPos(); }
"&&"        { storeToken("OPERATOR", yytext); updateColumnPos(); }
"||"        { storeToken("OPERATOR", yytext); updateColumnPos(); }
"!"         { storeToken("OPERATOR", yytext); updateColumnPos(); }

    /* PUNCTUATORS */
"("         { storeToken("PUNCTUATOR", yytext); updateColumnPos(); }
")"         { storeToken("PUNCTUATOR", yytext); updateColumnPos(); }
"{"         { storeToken("PUNCTUATOR", yytext); updateColumnPos(); }
"}"         { storeToken("PUNCTUATOR", yytext); updateColumnPos(); }
"["         { storeToken("PUNCTUATOR", yytext); updateColumnPos(); }
"]"         { storeToken("PUNCTUATOR", yytext); updateColumnPos(); }
";"         { storeToken("PUNCTUATOR", yytext); updateColumnPos(); }
","         { storeToken("PUNCTUATOR", yytext); updateColumnPos(); }
":"         { storeToken("PUNCTUATOR", yytext); updateColumnPos(); }

{IDENTIFIER}    { storeToken("IDENTIFIER", yytext); updateColumnPos(); }
{WHITESPACE}    { updateColumnPos(); }
{NEWLINE}       { line_counter++; column_counter = 1; }

    /* CHARACTER LITERALS */
' {
    char_length = 0;
    char_buffer[0] = '\0';
    char_start_line = line_counter;
    char_start_col = column_counter;
    column_counter++;
    BEGIN CHAR_STATE;
}

<CHAR_STATE>' {
    if (char_length == 0) lexicalError("Empty character constant", "''");
    else if (char_length == 1) storeToken("CHAR", char_buffer);
    else lexicalError("Multi-character constant", char_buffer);
    column_counter++;
    BEGIN INITIAL;
}

<CHAR_STATE>\\([nrt0abfv\\'\"]) {
    if (char_length < 15) {
        char_buffer[char_length++] = process_escape(yytext[1]);
        char_buffer[char_length] = '\0';
    }
    column_counter += 2;
}

<CHAR_STATE>\\[^\n] {
    lexicalError("Invalid escape sequence in character", yytext);
    column_counter += 2;
    if (char_length < 15) {
        char_buffer[char_length++] = yytext[1];
        char_buffer[char_length] = '\0';
    }
}

<CHAR_STATE>\n {
    lexicalError("Unterminated character constant (newline)", "'...");
    line_counter++;
    column_counter = 1;
    BEGIN INITIAL;
}

<CHAR_STATE><<EOF>> { lexicalError("Unterminated character constant (EOF)", "'..."); BEGIN INITIAL; }

<CHAR_STATE>. {
    if (char_length < 15) {
        char_buffer[char_length++] = yytext[0];
        char_buffer[char_length] = '\0';
    }
    column_counter++;
}

    /* STRING LITERALS */
\" {
    string_ptr = 0;
    string_buffer[0] = '\0';
    string_start_line = line_counter;
    string_start_col = column_counter;
    column_counter++;
    BEGIN STRING_STATE;
}

<STRING_STATE>\" {
    column_counter++;
    storeToken("STRING", string_buffer);
    BEGIN INITIAL;
}

<STRING_STATE>\\\n { line_counter++; column_counter = 1; }

<STRING_STATE>\\([nrt0abfv\\'\"]) {
    if (string_ptr < 4095) {
        string_buffer[string_ptr++] = process_escape(yytext[1]);
        string_buffer[string_ptr] = '\0';
    }
    column_counter += 2;
}

<STRING_STATE>\\[^\n] {
    lexicalError("Invalid escape sequence in string", yytext);
    column_counter += 2;
    if (string_ptr < 4095) {
        string_buffer[string_ptr++] = yytext[1];
        string_buffer[string_ptr] = '\0';
    }
}

<STRING_STATE>\n {
    lexicalError("Unterminated string constant (newline)", "\"...");
    line_counter++;
    column_counter = 1;
    BEGIN INITIAL;
}

<STRING_STATE><<EOF>> { lexicalError("Unterminated string constant (EOF)", "\"..."); BEGIN INITIAL;
}

<STRING_STATE>. {
    if (string_ptr < 4095) {
        string_buffer[string_ptr++] = yytext[0];
        string_buffer[string_ptr] = '\0';
    }
    column_counter++;
}

    /* COMMENTS */
"//".*              { updateColumnPos(); }
"/*"                { BEGIN(COMMENT_STATE); }
<COMMENT_STATE>"*/" { BEGIN(INITIAL); }
<COMMENT_STATE>\n   { line_counter++; column_counter = 1; }
<COMMENT_STATE><<EOF>> { lexicalError("Unterminated comment", "/* ..."); BEGIN(INITIAL); }
<COMMENT_STATE>.    { column_counter++; }

    /* ERROR HANDLING */
. { lexicalError("Unrecognized character", yytext); updateColumnPos(); }
%%

char process_escape(char escape_char) {
    switch(escape_char) {
        case 'n': return '\n';
        case 't': return '\t';
        case '0': return '\0';
        case '\\': return '\\';
        case '\'': return '\'';
        case '\"': return '\"';
        default: return escape_char;
    }
}

bool is_valid_escape(char c) {
    return (c == 'n' || c == 't' || c == '0' || c == '\\' || c == '\'' || c == '\"');
}

void storeToken(const char* type, const char* value) {
    if (token_file) {
        fprintf(token_file, "%-15s %-20s Line: %d, Col: %d\n", 
                type, value, line_counter, column_counter);
        token_count++;
    }
}

void updateColumnPos() {
    column_counter += yyleng;
}

void lexicalError(const char* errorType, const char* lexeme) {
    fprintf(stderr, "Lexical Error at line %d, col %d: %s -> \"%s\"\n", 
            line_counter, column_counter, errorType, lexeme);
    
    if (token_file) {
        fprintf(token_file, "%-15s %-20s Line: %d, Col: %d  [%s]\n", 
                "ERROR", lexeme, line_counter, column_counter, errorType);
    }
    error_count++;
}

void initTokenFile(const char* filename) {
    token_file = fopen(filename, "w");
    if (token_file) {
        fprintf(token_file, "                       TOKEN LIST\n");
        fprintf(token_file, "%-15s %-20s %s\n", "TOKEN TYPE", "VALUE", "POSITION");
        fprintf(token_file, "----------------------------------------------------------\n");
    } 
    else {
        fprintf(stderr, "Error: Cannot open token file '%s'\n", filename);
        exit(1);
    }
}

void closeTokenFile() {
    if (token_file) {
        fprintf(token_file, "----------------------------------------------------------\n");
        fprintf(token_file, "Total tokens: %d\n", token_count);
        fprintf(token_file, "Total errors: %d\n", error_count);
        fclose(token_file);
        token_file = NULL;
    }
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file.c>\n", argv[0]);
        return 1;
    }
    
    FILE *input = fopen(argv[1], "r");
    if (!input) {
        fprintf(stderr, "Error: Cannot open input file '%s'\n", argv[1]);
        return 1;
    }
    
    yyin = input;
    initTokenFile("tokens.txt");
    
    yylex();
    
    closeTokenFile();
    fclose(input);
    
    return error_count > 0 ? 1 : 0;
}