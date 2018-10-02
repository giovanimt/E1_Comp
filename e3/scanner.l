/*
Giovani Tirello 252741
Vinicius Castro 193026
*/


%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "parser.tab.h"

int LineNumber = 1;
int ColNumber = 0;
int get_line_number(void) { return LineNumber; }
int get_col_number(void) { return ColNumber; }
void count_cols();
void add_valor_lexico(enum ValorLexicoType type);

%}

%x Comment

%%

[\t ]+      { count_cols(); } /* ignora tabs e espacos */

","|";"|":"|"("|")"|"["|"]"|"{"|"}"|"+"|"-"|"|"|"?"|"*"|"/"|"<"|">"|"="|"!"|"&"|"%"|"#"|"^"|"."|"$"        { count_cols(); add_valor_lexico(ESPECIAL); return yytext[0]; }

int         { count_cols(); add_valor_lexico(TIPO_PRIMARIO); return TK_PR_INT; }
float       { count_cols(); add_valor_lexico(TIPO_PRIMARIO); return TK_PR_FLOAT; }
bool        { count_cols(); add_valor_lexico(TIPO_PRIMARIO); return TK_PR_BOOL; }
char        { count_cols(); add_valor_lexico(TIPO_PRIMARIO); return TK_PR_CHAR; }
string      { count_cols(); add_valor_lexico(TIPO_PRIMARIO); return TK_PR_STRING; }
if          { count_cols(); add_valor_lexico(RESERVADA); return TK_PR_IF; }
then        { count_cols(); add_valor_lexico(RESERVADA); return TK_PR_THEN; }
else        { count_cols(); add_valor_lexico(RESERVADA); return TK_PR_ELSE; }
while       { count_cols(); add_valor_lexico(RESERVADA); return TK_PR_WHILE; }
do          { count_cols(); add_valor_lexico(RESERVADA); return TK_PR_DO; }
input       { count_cols(); add_valor_lexico(RESERVADA); return TK_PR_INPUT; }
output      { count_cols(); add_valor_lexico(RESERVADA); return TK_PR_OUTPUT; }
return      { count_cols(); add_valor_lexico(RESERVADA); return TK_PR_RETURN; }
const       { count_cols(); add_valor_lexico(MODIFICADOR); return TK_PR_CONST; }
static      { count_cols(); add_valor_lexico(MODIFICADOR); return TK_PR_STATIC; }
foreach     { count_cols(); add_valor_lexico(RESERVADA); return TK_PR_FOREACH; }
for         { count_cols(); add_valor_lexico(RESERVADA); return TK_PR_FOR; }
switch      { count_cols(); add_valor_lexico(RESERVADA); return TK_PR_SWITCH; }
case        { count_cols(); add_valor_lexico(RESERVADA); return TK_PR_CASE; }
break       { count_cols(); add_valor_lexico(RESERVADA); return TK_PR_BREAK; }
continue    { count_cols(); add_valor_lexico(RESERVADA); return TK_PR_CONTINUE; }
class       { count_cols(); add_valor_lexico(RESERVADA); return TK_PR_CLASS; }
private     { count_cols(); add_valor_lexico(ENCAPSULAMENTO); return TK_PR_PRIVATE; }
public      { count_cols(); add_valor_lexico(ENCAPSULAMENTO); return TK_PR_PUBLIC; }
protected   { count_cols(); add_valor_lexico(ENCAPSULAMENTO); return TK_PR_PROTECTED; }


true        { count_cols(); add_valor_lexico(BOOL); return TK_LIT_TRUE; }
false       { count_cols(); add_valor_lexico(BOOL); return TK_LIT_FALSE; }

"<="        { count_cols(); add_valor_lexico(OPERADOR_COMP); return TK_OC_LE; }
">="        { count_cols(); add_valor_lexico(OPERADOR_COMP); return TK_OC_GE; }
"=="        { count_cols(); add_valor_lexico(OPERADOR_COMP); return TK_OC_EQ; }
"!="        { count_cols(); add_valor_lexico(OPERADOR_COMP); return TK_OC_NE; }
"&&"        { count_cols(); add_valor_lexico(OPERADOR_COMP); return TK_OC_AND; }
"||"        { count_cols(); add_valor_lexico(OPERADOR_COMP); return TK_OC_OR; }
"<<"        { count_cols(); add_valor_lexico(OPERADOR_COMP); return TK_OC_SL; }
">>"        { count_cols(); add_valor_lexico(OPERADOR_COMP); return TK_OC_SR; }
"%>%"       { count_cols(); add_valor_lexico(OPERADOR_COMP); return TK_OC_FORWARD_PIPE; }
"%|%"       { count_cols(); add_valor_lexico(OPERADOR_COMP); return TK_OC_BASH_PIPE; }

[0-9]+                             { count_cols(); add_valor_lexico(INTEIRO); return TK_LIT_INT; }
[0-9]+\.[0-9]+([eE][+-]?[0-9]+)?   { count_cols(); add_valor_lexico(FLOAT); return TK_LIT_FLOAT; }

\'.\'                      { count_cols(); add_valor_lexico(CHAR); return TK_LIT_CHAR; } 
\".*\"                     { count_cols(); add_valor_lexico(STRING); return TK_LIT_STRING; } 
[a-zA-Z_][a-zA-Z_0-9]*     { count_cols(); add_valor_lexico(IDENT); return TK_IDENTIFICADOR; }

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


void add_valor_lexico(enum ValorLexicoType type){
	yylval.valor_lexico.line =  get_line_number();
	yylval.valor_lexico.col =  get_col_number();
	yylval.valor_lexico.type = type; 
	
	switch(type) {
		case BOOL:
			if(strcmp(yytext,"true"))
				yylval.valor_lexico.val.bool_val = 1;
			if(strcmp(yytext,"false"))
				yylval.valor_lexico.val.bool_val = 0;
			break;
		case INTEIRO:
			yylval.valor_lexico.val.int_val = atoi(yytext);
			break;
		case FLOAT:
			yylval.valor_lexico.val.float_val = atof(yytext);
			break;
		case CHAR:
			yylval.valor_lexico.val.char_val = yytext[0];
			break;
		case STRING:
			yylval.valor_lexico.val.string_val = strdup(yytext);
			break;
		default:
			yylval.valor_lexico.val.string_val = strdup(yytext);
			break;
	}
}

