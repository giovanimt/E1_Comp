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
extern void *arvore;
extern void descompila (void *arvore);
extern void libera (void *arvore);

%}

%code requires {
#include "arvore.h"
}


%union {
	struct valor_lexico valor_lexico;
	NodoArvore* NodoArvore;
}

%token <valor_lexico> TK_PR_INT
%token <valor_lexico> TK_PR_FLOAT
%token <valor_lexico> TK_PR_BOOL
%token <valor_lexico> TK_PR_CHAR
%token <valor_lexico> TK_PR_STRING
%token <valor_lexico> TK_PR_IF
%token <valor_lexico> TK_PR_THEN
%token <valor_lexico> TK_PR_ELSE
%token <valor_lexico> TK_PR_WHILE
%token <valor_lexico> TK_PR_DO
%token <valor_lexico> TK_PR_INPUT
%token <valor_lexico> TK_PR_OUTPUT
%token <valor_lexico> TK_PR_RETURN
%token <valor_lexico> TK_PR_CONST
%token <valor_lexico> TK_PR_STATIC
%token <valor_lexico> TK_PR_FOREACH
%token <valor_lexico> TK_PR_FOR
%token <valor_lexico> TK_PR_SWITCH
%token <valor_lexico> TK_PR_CASE
%token <valor_lexico> TK_PR_BREAK
%token <valor_lexico> TK_PR_CONTINUE
%token <valor_lexico> TK_PR_CLASS
%token <valor_lexico> TK_PR_PRIVATE
%token <valor_lexico> TK_PR_PUBLIC
%token <valor_lexico> TK_PR_PROTECTED
%token <valor_lexico> TK_OC_LE
%token <valor_lexico> TK_OC_GE
%token <valor_lexico> TK_OC_EQ
%token <valor_lexico> TK_OC_NE
%token <valor_lexico> TK_OC_AND
%token <valor_lexico> TK_OC_OR
%token <valor_lexico> TK_OC_SL
%token <valor_lexico> TK_OC_SR
%token <valor_lexico> TK_OC_FORWARD_PIPE
%token <valor_lexico> TK_OC_BASH_PIPE
%token <valor_lexico> TK_LIT_INT
%token <valor_lexico> TK_LIT_FLOAT
%token <valor_lexico> TK_LIT_FALSE
%token <valor_lexico> TK_LIT_TRUE
%token <valor_lexico> TK_LIT_CHAR
%token <valor_lexico> TK_LIT_STRING
%token <valor_lexico> TK_IDENTIFICADOR
%token TOKEN_ERRO

%type <valor_lexico> tipo_primario
%type <valor_lexico> encapsulamento
%type <NodoArvore> programa
%type <NodoArvore> var_global
%type <NodoArvore> novo_tipo
%type <NodoArvore> novo_tipo_campo
%type <NodoArvore> novo_tipo_lista_campos

%type <NodoArvore> funcao
%type <NodoArvore> cabecalho
%type <NodoArvore> parametros
%type <NodoArvore> lista_parametros
%type <NodoArvore> parametro
%type <NodoArvore> bloco_comandos
%type <NodoArvore> sequencia_comandos_simples
%type <NodoArvore> comando_simples


%left '-' '+'
%left '*' '/' '%'
%precedence NEG   /* negation--unary minus */
%right '^'        /* exponentiation */

%start programa

%%

programa:   
  %empty				{ $$ = cria_nodo(programa,0); arvore = $$; }
| programa novo_tipo	{ arvore = $$; adiciona_filho($1,$2); }
| programa var_global	{ arvore = $$; adiciona_filho($1,$2); }
| programa funcao
;

tipo_primario:   
  TK_PR_INT		 
| TK_PR_FLOAT	
| TK_PR_BOOL	
| TK_PR_CHAR	
| TK_PR_STRING
;

encapsulamento:
  TK_PR_PRIVATE 
| TK_PR_PUBLIC 
| TK_PR_PROTECTED
;

literal:
  TK_LIT_INT
| TK_LIT_FLOAT
| TK_LIT_FALSE
| TK_LIT_TRUE
| TK_LIT_CHAR
| TK_LIT_STRING
;


pipes:
  TK_OC_FORWARD_PIPE
| TK_OC_BASH_PIPE
;


/* Declarações de Novos Tipos */
novo_tipo:
  TK_PR_CLASS TK_IDENTIFICADOR '[' novo_tipo_lista_campos ']' ';'
	{ $$ = cria_nodo(novo_tipo,3,cria_folha($1),cria_folha($2),$4); }
;

novo_tipo_campo:
  tipo_primario TK_IDENTIFICADOR
	{ $$ = cria_nodo(novo_tipo_campo,3,NULL,cria_folha($1),cria_folha($2)); }

| encapsulamento tipo_primario TK_IDENTIFICADOR
	{ $$ = cria_nodo(novo_tipo_campo,3,cria_folha($1),cria_folha($2),cria_folha($3)); }
;

novo_tipo_lista_campos:
  novo_tipo_campo
	{ $$ = cria_nodo(novo_tipo_lista_campos,1,$1); }
| novo_tipo_lista_campos ':' novo_tipo_campo 
	{ $$ = $1; adiciona_filho($$,$3); }
;	

/* Declarações de Variáveis Globais */
var_global:
  TK_IDENTIFICADOR tipo_primario ';' 
	{ $$ = cria_nodo(var_global,4,cria_folha($1),NULL,NULL,cria_folha($2)); }

| TK_IDENTIFICADOR TK_IDENTIFICADOR ';'	
	{ $$ = cria_nodo(var_global,4,cria_folha($1),NULL,NULL,cria_folha($2)); }

| TK_IDENTIFICADOR TK_PR_STATIC tipo_primario ';'
	{ $$ = cria_nodo(var_global,4,cria_folha($1),NULL,cria_folha($2),cria_folha($3)); }

| TK_IDENTIFICADOR TK_PR_STATIC TK_IDENTIFICADOR ';' 
	{ $$ = cria_nodo(var_global,4,cria_folha($1),NULL,cria_folha($2),cria_folha($3)); }

| TK_IDENTIFICADOR '[' TK_LIT_INT ']' tipo_primario ';' 
	{ $$ = cria_nodo(var_global,4,cria_folha($1),cria_folha($3),NULL,cria_folha($5)); }

| TK_IDENTIFICADOR '[' TK_LIT_INT ']' TK_IDENTIFICADOR ';' 
	{ $$ = cria_nodo(var_global,4,cria_folha($1),cria_folha($3),NULL,cria_folha($5)); }

| TK_IDENTIFICADOR '[' TK_LIT_INT ']' TK_PR_STATIC tipo_primario ';' 
	{ $$ = cria_nodo(var_global,4,cria_folha($1),cria_folha($3),cria_folha($5),cria_folha($6)); }

| TK_IDENTIFICADOR '[' TK_LIT_INT ']' TK_PR_STATIC TK_IDENTIFICADOR ';'
	{ $$ = cria_nodo(var_global,4,cria_folha($1),cria_folha($3),cria_folha($5),cria_folha($6)); }

;

/* Definição de Funções */
funcao:
  cabecalho bloco_comandos
	{ $$ = cria_nodo(funcao,2,$1,$2); }
;

cabecalho:
  tipo_primario TK_IDENTIFICADOR parametros
	{ $$ = cria_nodo(cabecalho,4,NULL,cria_folha($1),cria_folha($2),$3); }	
	
| TK_IDENTIFICADOR TK_IDENTIFICADOR parametros
	{ $$ = cria_nodo(cabecalho,4,NULL,cria_folha($1),cria_folha($2),$3); }	

| TK_PR_STATIC tipo_primario TK_IDENTIFICADOR parametros
	{ $$ = cria_nodo(cabecalho,4,cria_folha($1),cria_folha($2),cria_folha($3),$4); }		

| TK_PR_STATIC TK_IDENTIFICADOR TK_IDENTIFICADOR parametros
	{ $$ = cria_nodo(cabecalho,4,cria_folha($1),cria_folha($2),cria_folha($3),$4); }
;

parametros:
  '(' ')'
	{ $$ = cria_nodo(lista_parametros,0); }

| '(' lista_parametros ')'
	{ $$ = $2; }
;

lista_parametros:
  parametro
	{ $$ = cria_nodo(lista_parametros,1,$1); }

| lista_parametros ',' parametro
	{ $$ = $1; adiciona_filho($$,$3); }
;

parametro:
  tipo_primario TK_IDENTIFICADOR
	{ $$ = cria_nodo(parametro,3,NULL,cria_folha($1),cria_folha($2)); }

| TK_IDENTIFICADOR TK_IDENTIFICADOR
	{ $$ = cria_nodo(parametro,3,NULL,cria_folha($1),cria_folha($2)); }

| TK_PR_CONST tipo_primario TK_IDENTIFICADOR
	{ $$ = cria_nodo(parametro,3,cria_folha($1),cria_folha($2),cria_folha($3)); }

| TK_PR_CONST TK_IDENTIFICADOR TK_IDENTIFICADOR
	{ $$ = cria_nodo(parametro,3,cria_folha($1),cria_folha($2),cria_folha($3)); }
;

/* Bloco de Comandos */
bloco_comandos:
  '{' '}'
| '{' sequencia_comandos_simples '}'
;

sequencia_comandos_simples:
  comando_simples
| sequencia_comandos_simples comando_simples
;

comando_simples:
  bloco_comandos ';'
| var_local ';'
| atribuicao ';'
| contr_fluxo ';'
| entrada ';'
| saida
| retorno ';'
| break ';'
| continue ';'
| case
| cham_func ';'
| com_shift ';'
| com_pipes ';'
;

///comando_for usado em lista_for
comando_for:
  bloco_comandos
| var_local
| atribuicao
| contr_fluxo
| entrada
| retorno
| break
| continue
| cham_func
| com_shift 
| com_pipes


/*Variavel Local*/

var_local:
  var_local_tipo
| TK_PR_CONST var_local_tipo
| TK_PR_STATIC var_local_tipo
| TK_PR_STATIC TK_PR_CONST var_local_tipo
;

var_local_tipo:
  tipo_primario TK_IDENTIFICADOR var_local_inic
| TK_IDENTIFICADOR TK_IDENTIFICADOR
;

var_local_inic:
  %empty
| TK_OC_LE var_local_inic2
;

var_local_inic2:
  literal
| TK_IDENTIFICADOR
;


///Atribuicao
atribuicao:
  TK_IDENTIFICADOR '=' expressao
| TK_IDENTIFICADOR '[' expressao ']' '=' expressao 
| TK_IDENTIFICADOR '$' TK_IDENTIFICADOR '=' expressao
| TK_IDENTIFICADOR '[' expressao ']' '$' TK_IDENTIFICADOR '=' expressao
;


///Entrada e Saida
entrada:		TK_PR_INPUT expressao
;

saida:			TK_PR_OUTPUT expressao saida2
;

saida2:			',' expressao saida2 | ';'
;


/// Retorno, Break, Continue, Case
retorno:		TK_PR_RETURN expressao
;

break:			TK_PR_BREAK
;

continue:		TK_PR_CONTINUE
;

case:			TK_PR_CASE TK_LIT_INT ':'
;


/// Chamada de Funcao
cham_func:
  TK_IDENTIFICADOR '(' cham_func_arg
;

cham_func_arg:
  expressao cham_func_fim
| '.' cham_func_fim
| cham_func_fim
;

cham_func_fim:
  ',' cham_func_arg
  | ')'
;


///Comando Shift
com_shift:
TK_IDENTIFICADOR com_shift_opcoes
;

com_shift_opcoes:
  TK_OC_SL com_shift_dados
| TK_OC_SR com_shift_dados
| '$' TK_IDENTIFICADOR com_shift_dir
| '[' expressao ']' com_shift_dados2
;

com_shift_dados2:
  '$' TK_IDENTIFICADOR com_shift_dir
| com_shift_dir
;

com_shift_dir:
  TK_OC_SL com_shift_dados 
| TK_OC_SR com_shift_dados
;

com_shift_dados:
  expressao
;


///Controle de Fluxo
contr_fluxo:
  constr_cond
| constr_iter
| constr_sel
;

constr_cond:
  TK_PR_IF '(' expressao ')' TK_PR_THEN bloco_comandos constr_cond_else
;

constr_cond_else:
  TK_PR_ELSE bloco_comandos
| %empty
;

constr_iter:
  TK_PR_FOREACH '(' TK_IDENTIFICADOR ':' lista_foreach ')' bloco_comandos
| TK_PR_FOR '(' lista_for ':' expressao ':' lista_for ')' bloco_comandos
| TK_PR_WHILE '(' expressao ')' TK_PR_DO bloco_comandos
| TK_PR_DO bloco_comandos TK_PR_WHILE '(' expressao ')'
;

lista_foreach:
  expressao lista_foreach2
;

lista_foreach2:
  ',' expressao lista_foreach2
| %empty
;

lista_for:
  comando_for lista_for2
;

lista_for2:
  ',' comando_for lista_for2
| %empty
;

constr_sel:
  TK_PR_SWITCH '(' expressao ')' bloco_comandos
;



/// Comandos com Pipes
com_pipes:
  cham_func pipes cham_func
| com_pipes pipes cham_func
;


/* Expr. Aritméticas */
val_expr:
  TK_LIT_INT
| TK_LIT_FLOAT
| TK_LIT_CHAR
| TK_LIT_STRING
| TK_LIT_FALSE
| TK_LIT_TRUE
|'(' expressao ')'
| com_pipes
| cham_func
| TK_IDENTIFICADOR expr_vet
;

expr_vet:
  '[' expressao ']' expr_cif
|  expr_cif
;

expr_cif:
  '$' TK_IDENTIFICADOR
| %empty
;

op_bin:
  '+'
| '-'
| '*'
| '/'
| '%'
| '|'
| '&'
| '^'
| TK_OC_LE
| TK_OC_GE
| TK_OC_EQ
| TK_OC_NE
| TK_OC_AND
| TK_OC_OR
| TK_OC_SL
| TK_OC_SR
;

op_un:
  '+'
| '-'
| '!'
| '&'
| '*'
| '?'
| '#'
| %empty
;

expressao:
  op_un val_expr expressao_cont
;

expressao_cont:
  op_bin expressao
| '?' expressao ':' expressao
| %empty
;

%%

/* Called by yyparse on error.  */
void yyerror (char const *s)
{
  fprintf (stderr, "linha %d coluna %ld: %s: token invalido: %s\n", get_line_number(), get_col_number()-strlen(yytext)+1, s, yytext);
}

void descompila (void *arvore) {
	NodoArvore *a = (NodoArvore*)arvore;
	if(a == NULL)
		return;

	if(a->type == 0){
		switch(a->nodo.valor_lexico.type) {
			case(INTEIRO):
				printf(" %d ",a->nodo.valor_lexico.val.int_val);
				break;
			case(FLOAT):
				printf(" %f ",a->nodo.valor_lexico.val.float_val);
				break;			
			case(CHAR):
				printf(" %c ",a->nodo.valor_lexico.val.char_val);
				break;
			default:
				printf(" %s ",a->nodo.valor_lexico.val.string_val);
				break;
		return;
		}
	}

	int i;
	for(i=0 ; i < a->num_filhos; i++) {
		switch(a->nodo.type) {
			// var_global
			case(var_global):
				descompila(a->filhos[0]);
				if(a->filhos[1] != NULL) {
					printf("[");
					descompila(a->filhos[1]);
					printf("]");
				}
				if(a->filhos[2] != NULL)
					descompila(a->filhos[2]);
				descompila(a->filhos[3]);
				printf(";");				
				return;

			// novo_tipo
			// TK_PR_CLASS TK_IDENTIFICADOR '[' novo_tipo_lista_campos ']' ';'
			case(novo_tipo):
				descompila(a->filhos[0]);
				descompila(a->filhos[1]);
				printf("["); descompila(a->filhos[2]); printf("];");
				return;

			// novo_tipo_lista_campos
			// novo_tipo_campo ':' novo_tipo_lista_campos
			case(novo_tipo_lista_campos):
				descompila(a->filhos[0]);
				if(a->num_filhos > 1) {
					printf(":");
					descompila(a->filhos[1]);
				}
				return;

			// novo_tipo_campo
			// encapsulamento tipo_primario TK_IDENTIFICADOR
			case(novo_tipo_campo):
				if(a->filhos[0] != NULL)
					descompila(a->filhos[0]);
				descompila(a->filhos[1]); descompila(a->filhos[2]);
				return;
				
		}
		descompila(a->filhos[i]);
	}
};

void libera (void *arvore) {};
