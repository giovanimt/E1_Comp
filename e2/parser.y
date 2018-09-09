/*
Giovani Tirello 252741
Vinicius Castro 193026
*/

%{
#include <stdio.h>
#include "lex.yy.h"
int yylex(void);
void yyerror (char const *s);
extern int get_line_number();
extern int get_col_number();
%}

%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_BOOL
%token TK_PR_CHAR
%token TK_PR_STRING
%token TK_PR_IF
%token TK_PR_THEN
%token TK_PR_ELSE
%token TK_PR_WHILE
%token TK_PR_DO
%token TK_PR_INPUT
%token TK_PR_OUTPUT
%token TK_PR_RETURN
%token TK_PR_CONST
%token TK_PR_STATIC
%token TK_PR_FOREACH
%token TK_PR_FOR
%token TK_PR_SWITCH
%token TK_PR_CASE
%token TK_PR_BREAK
%token TK_PR_CONTINUE
%token TK_PR_CLASS
%token TK_PR_PRIVATE
%token TK_PR_PUBLIC
%token TK_PR_PROTECTED
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_OC_AND
%token TK_OC_OR
%token TK_OC_SL
%token TK_OC_SR
%token TK_OC_FORWARD_PIPE
%token TK_OC_BASH_PIPE
%token TK_LIT_INT
%token TK_LIT_FLOAT
%token TK_LIT_FALSE
%token TK_LIT_TRUE
%token TK_LIT_CHAR
%token TK_LIT_STRING
%token TK_IDENTIFICADOR
%token TOKEN_ERRO
%start programa

%%

programa:   
  %empty
| programa novo_tipo
| programa var_global
| programa funcao 

tipo_primario:   
  TK_PR_INT 
| TK_PR_FLOAT 
| TK_PR_BOOL 
| TK_PR_CHAR 
| TK_PR_STRING

tipo_usuario:
  TK_IDENTIFICADOR

tipo:
  tipo_primario
| tipo_usuario

encapsulamento:
  TK_PR_PRIVATE 
| TK_PR_PUBLIC 
| TK_PR_PROTECTED

static_modifier:
  %empty
| TK_PR_STATIC

/* Declarações de Novos Tipos */
novo_tipo:
  TK_PR_CLASS TK_IDENTIFICADOR '[' novo_tipo_lista_campos ']' ';'

novo_tipo_campo:
  tipo_primario TK_IDENTIFICADOR
| encapsulamento tipo_primario TK_IDENTIFICADOR

novo_tipo_lista_campos:
  novo_tipo_campo
| novo_tipo_campo ':' novo_tipo_lista_campos

/* Declarações de Variáveis Globais */
var_global:
  TK_IDENTIFICADOR static_modifier tipo ';'
| TK_IDENTIFICADOR '[' TK_LIT_INT ']' static_modifier tipo ';'


/* Definição de Funções */
funcao:
  cabecalho corpo

cabecalho:
  tipo_retorno TK_IDENTIFICADOR '(' lista_parametros ')'

tipo_retorno:
  tipo

lista_parametros:
  %empty
| parametro ',' lista_parametros

parametro:
  tipo TK_IDENTIFICADOR

corpo:
  %empty

/*
bloco_comandos:		'{' comandos
comandos:		'}' | comandos_simples comandos

comandos_simples:	var_local | atribuicao | contr_fluxo | entrada | saida | retorno | break | continue | case | bloco_comandos | cham_func | com_shift | com_pipes

literal:		TK_LIT_INT | TK_LIT_FLOAT | TK_LIT_FALSE | TK_LIT_TRUE | TK_LIT_CHAR | TK_LIT_STRING
var_local:		TK_IDENTIFICADOR var_local_static
var_local_static:	TK_PR_STATIC var_local_const | var_local_const
var_local_const:	TK_PR_CONST var_local_tipo | var_local_tipo
var_local_tipo:		tipo var_local_inic | TK_IDENTIFICADOR ';'
var_local_inic:		';' | TK_OC_LE var_local_inic2
var_local_inic2:	literal ';' | TK_IDENTIFICADOR ';'


expressao:  expr_arit
            | expr_logica
            | expr_pipes

// TODO: criar as regras de expressoes
expr_arit:  %empty
expr_logica:  %empty
expr_pipes:  %empty


atribuicao:		tipo atribuicao_prim | TK_IDENTIFICADOR atribuicao_decl
atribuicao_decl:	'$' TK_IDENTIFICADOR '=' expressao ';' | '[' expressao ']' '$' TK_IDENTIFICADOR '=' expressao ';'
atribuicao_prim:	'=' expressao ';' | '[' expressao ']' '=' expressao ';'

entrada:		TK_PR_INPUT expressao ';'

saida:			TK_PR_OUTPUT expressao saida2
saida2:			',' expressao saida2 | ';'

retorno:		TK_PR_RETURN expressao ';'

break:			TK_PR_BREAK ';'

continue:		TK_PR_CONTINUE ';'

case:			TK_PR_CASE TK_LIT_INT ':'

cham_func:		TK_IDENTIFICADOR '(' cham_func_arg
cham_func_arg:		expressao cham_func_fim | '.' cham_func_fim
cham_func_fim:		',' cham_func_arg | ')' ';'
/// TO DO cham_func: ver comandos pipe para o '.'

com_shift:		TK_IDENTIFICADOR com_shift_opcoes
com_shift_opcoes:	TK_OC_SL com_shift_dados | TK_OC_SR com_shift_dados | '$' TK_IDENTIFICADOR com_shift_dir | '[' expressao ']' com_shift_dados2
com_shift_dados2:	'$' TK_IDENTIFICADOR com_shift_dir | com_shift_dir
com_shift_dir:		TK_OC_SL com_shift_dados | TK_OC_SR com_shift_dados
com_shift_dados:	expressao ';' | TK_LIT_INT ';'
///TO DO com_shift: TK_LIT_INT deve ser inteiro positivo

// TO DO
contr_fluxo:    %empty

// TO DO
com_pipes:  %empty
*/

%%

/* Called by yyparse on error.  */
void yyerror (char const *s)
{
  fprintf (stderr, "linha %d coluna %d: %s: token invalido: %s\n", get_line_number(), get_col_number()-strlen(yytext)+1, s, yytext);
}
