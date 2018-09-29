/*
Giovani Tirello 252741
Vinicius Castro 193026
*/


%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "parser.tab.h"
/*#include "arovre.h"

struct nodo_basico **token;
*/
int LineNumber = 1;
int ColNumber = 0;
int get_line_number(void) { return LineNumber; }
int get_col_number(void) { return ColNumber; }
void count_cols();
void nao_literal();
void literal();
void especiais();

%}

%x Comment

%%

[\t ]+      { count_cols(); } /* ignora tabs e espacos */

","|";"|":"|"("|")"|"["|"]"|"{"|"}"|"+"|"-"|"|"|"?"|"*"|"/"|"<"|">"|"="|"!"|"&"|"%"|"#"|"^"|"."|"$"        { count_cols(); especiais(); return yytext[0]; }

int         { count_cols(); nao_literal();yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_INT; }
float       { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_FLOAT; }
bool        { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_BOOL; }
char        { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_CHAR; }
string      { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_STRING; }
if          { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_IF; }
then        { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_THEN; }
else        { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_ELSE; }
while       { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_WHILE; }
do          { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_DO; }
input       { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_INPUT; }
output      { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_OUTPUT; }
return      { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_RETURN; }
const       { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_CONST; }
static      { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_STATIC; }
foreach     { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_FOREACH; }
for         { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_FOR; }
switch      { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_SWITCH; }
case        { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_CASE; }
break       { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_BREAK; }
continue    { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_CONTINUE; }
class       { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_CLASS; }
private     { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_PRIVATE; }
public      { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_PUBLIC; }
protected   { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = P_RESERVADA; return TK_PR_PROTECTED; }


true        { count_cols(); literal(); yylval.valor_lexico->tipo_lit = BOOL; yylval.valor_lexico->valor.tipo_bool = 1; return TK_LIT_TRUE; }
false       { count_cols(); literal(); yylval.valor_lexico->tipo_lit = BOOL; yylval.valor_lexico->valor.tipo_bool = 0;return TK_LIT_FALSE; }

"<="        { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = OPERADOR; return TK_OC_LE; }
">="        { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = OPERADOR; return TK_OC_GE; }
"=="        { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = OPERADOR; return TK_OC_EQ; }
"!="        { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = OPERADOR; return TK_OC_NE; }
"&&"        { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = OPERADOR; return TK_OC_AND; }
"||"        { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = OPERADOR; return TK_OC_OR; }
"<<"        { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = OPERADOR; return TK_OC_SL; }
">>"        { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = OPERADOR; return TK_OC_SR; }
"%>%"       { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = OPERADOR; return TK_OC_FORWARD_PIPE; }
"%|%"       { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = OPERADOR; return TK_OC_BASH_PIPE; }

[0-9]+                             { count_cols(); literal(); yylval.valor_lexico->tipo_lit = INTEIRO; yylval.valor_lexico->valor.tipo_int = atoi(yytext); return TK_LIT_INT; }
[0-9]+\.[0-9]+([eE][+-]?[0-9]+)?   { count_cols(); literal(); yylval.valor_lexico->tipo_lit = FLOAT; yylval.valor_lexico->valor.tipo_float = atoi(yytext); return TK_LIT_FLOAT; }

\'.\'                      { count_cols(); literal(); yylval.valor_lexico->tipo_lit = CHAR; yylval.valor_lexico->valor.tipo_char = atoi(yytext); return TK_LIT_CHAR; } 
\".*\"                     { count_cols(); literal(); yylval.valor_lexico->tipo_lit = STRING; yylval.valor_lexico->valor.tipo_string = atoi(yytext); return TK_LIT_STRING; } 
[a-zA-Z_][a-zA-Z_0-9]*     { count_cols(); nao_literal(); yylval.valor_lexico->tipo_token = IDENT; return TK_IDENTIFICADOR; }

"//".*   			     { count_cols(); }

"/*"          { count_cols();BEGIN(Comment); }
<Comment>\n   { count_cols();LineNumber++;}
<Comment>.	  { count_cols();}
<Comment>"*/" { count_cols();BEGIN(INITIAL); }

\n   { count_cols();LineNumber++; }
.    { count_cols();return TOKEN_ERRO; }

%%

void count_cols(){
  int i;
  for(i=0 ; yytext[i] != '\0' ; i++){
    if(yytext[i] != '\n')
      ColNumber++;
    else
      ColNumber=0;
  } 
}

void nao_literal(){
	yylval.valor_lexico = (struct nodo_basico*) malloc(sizeof(struct nodo_basico));
	yylval.valor_lexico->tipo_lit = NAO_LITERAL;
	yylval.valor_lexico->linha = get_line_number();
	yylval.valor_lexico->coluna = get_col_number();
	yylval.valor_lexico->valor.tipo_string = strdup(yytext);
	token = &yylval.valor_lexico;
}

void literal(){
	yylval.valor_lexico = (struct nodo_basico*) malloc(sizeof(struct nodo_basico));
	yylval.valor_lexico->tipo_token = LITERAL;
	yylval.valor_lexico->linha = get_line_number();
	yylval.valor_lexico->coluna = get_col_number();
	token = &yylval.valor_lexico;
}

void especiais(){
	yylval.valor_lexico = (struct nodo_basico*) malloc(sizeof(struct nodo_basico));
	yylval.valor_lexico->tipo_lit = NAO_LITERAL;
	yylval.valor_lexico->tipo_token = ESPECIAL;	
	yylval.valor_lexico->valor.tipo_char = yytext[0];
	yylval.valor_lexico->linha = get_line_number();
	yylval.valor_lexico->coluna = get_col_number();
	token = &yylval.valor_lexico;
}


