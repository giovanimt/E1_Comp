 %{
#include <stdio.h>
int yylex(void);
void yyerror (char const *s);
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

%%

programa: ///???




tipo: 			TK_PR_INT | TK_PR_FLOAT | TK_PR_BOOL | TK_PR_CHAR | TK_PR_STRING
encapsulamento:		TK_PR_PRIVATE | TK_PR_PUBLIC | TK_PR_PROTECTED
literal:		TK_LIT_INT | TK_LIT_FLOAT | TK_LIT_FALSE | TK_LIT_TRUE | TK_LIT_CHAR | TK_LIT_STRING



novo_tipo:		TK_PR_CLASS TK_IDENTIFICADOR '[' novo_campo_enc
novo_campo_enc:		encapsulamento novo_campo_tipo | novo_campo_tipo
novo_campo_tipo:	tipo TK_IDENTIFICADOR novo_campo
novo_campo:		':' novo_campo_enc | ']'';'

var_global:		TK_IDENTIFICADOR var_global_static
var_global_static:	TK_PR_STATIC var_global_tipo | var_global_tipo
var_global_tipo:	tipo var_global_fim | TK_IDENTIFICADOR var_global_fim
var_global_fim:		'[' TK_LIT_INT ']' ';' | ';'

funcao:			tipo funcao_static
funcao_static:		TK_PR_STATIC funcao_ident | funcao_ident
funcao_ident:		TK_IDENTIFICADOR '(' funcao_param
funcao_param:		')' bloco_comandos | tipo funcao_const
funcao_const:		TK_PR_CONST TK_IDENTIFICADOR funcao_novo_param | TK_IDENTIFICADOR funcao_novo_param
funcao_novo_param:	',' funcao_param | funcao_param

bloco_comandos:		'{' comandos
comandos:		'}' | comandos_simples novo_comando
novo_comando:		';' comandos

comandos_simples:	var_local | atribuicao | fluxo_contr | entrada | saida | retorno | bloco_comandos | chamadas_func

var_local:		TK_IDENTIFICADOR var_local_static
var_local_static:	TK_PR_STATIC var_local_const | var_local_const
var_local_const:	TK_PR_CONST var_local_tipo | var_local_tipo
var_local_tipo:		tipo var_local_inic | TK_IDENTIFICADOR ';'
var_local_inic:		';' | TK_OC_LE var_local_inic2
var_local_inic2:	literal ';' | TK_IDENTIFICADOR ';'

atribuicao:		

%%
