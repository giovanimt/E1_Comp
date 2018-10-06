/*
Giovani Tirello 252741
Vinicius Castro 193026
*/

%{
#include <stdio.h>
#include "lex.yy.h"
int i;
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

%type <valor_lexico> literal
%type <valor_lexico> tipo_primario
%type <valor_lexico> encapsulamento
%type <valor_lexico> op_un
%type <valor_lexico> op_bin
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

%type <NodoArvore> var_local
%type <NodoArvore> var_local_tipo
%type <NodoArvore> var_local_inic
%type <NodoArvore> var_local_inic2
%type <NodoArvore> atribuicao
/*
%type <NodoArvore> contr_fluxo
%type <NodoArvore> lista_foreach
%type <NodoArvore> lista_for
%type <NodoArvore> entrada
%type <NodoArvore> saida
%type <NodoArvore> retorno
%type <NodoArvore> break_t
%type <NodoArvore> continue_t
%type <NodoArvore> case_t
%type <NodoArvore> cham_func
%type <NodoArvore> com_shift
%type <NodoArvore> com_pipes
*/
%type <NodoArvore> expressao
%type <NodoArvore> expressao_cont
%type <NodoArvore> val_expr
%type <NodoArvore> expr_vet
%type <NodoArvore> expr_cif


%left '-' '+'
%left '*' '/' '%'
%precedence NEG   /* negation--unary minus */
%right '^'        /* exponentiation */

%start programa

%%

programa:   
  %empty		        { $$ = cria_nodo(programa,0); arvore = $$; }
| programa novo_tipo	{ arvore = $$; adiciona_filho($1,$2); }
| programa var_global	{ arvore = $$; adiciona_filho($1,$2); }
| programa funcao       { $$ = $1; adiciona_filho($1,$2); arvore = $$; }
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
	{ $$ = cria_nodo(lista_parametros,0); adiciona_netos($$,$2); }
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
	{ $$ = cria_nodo(bloco_comandos,0); }

| '{' sequencia_comandos_simples '}'
	{ $$ = cria_nodo(bloco_comandos,0); 
		int i;
		for(i=0 ; i<$2->num_filhos ; i++)
			adiciona_filho($$,$2->filhos[i]);	
	}
;

sequencia_comandos_simples:
  comando_simples
	{ $$ = cria_nodo(sequencia_comandos_simples,1,$1); }

| sequencia_comandos_simples comando_simples
	{ $$ = $1; adiciona_filho($$,$2); }
;

comando_simples:
  bloco_comandos ';'	{ $$ = cria_nodo(bloco_comandos,1,$1); }
| var_local ';'		{ $$ = cria_nodo(comando_simples,1,$1); }
| atribuicao ';'		
/*
| contr_fluxo ';'		
| entrada ';'			
| saida					
| retorno ';'			
| break_t ';'			
| continue_t ';'		
| case_t				
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
| break_t
| continue_t
| cham_func
| com_shift 
| com_pipes
;
*/
/*Variavel Local*/
;
var_local:
  var_local_tipo
{ $$ = cria_nodo(var_local,2,NULL,NULL); 
	int i;
	for(i=0 ; i<$1->num_filhos ; i++)
		adiciona_filho($$,$1->filhos[i]);
}
| TK_PR_CONST var_local_tipo
{ $$ = cria_nodo(var_local,2,NULL,cria_folha($1));
	int i;
	for(i=0 ; i<$2->num_filhos ; i++)
		adiciona_filho($$,$2->filhos[i]);
}
| TK_PR_STATIC var_local_tipo
{ $$ = cria_nodo(var_local,2,cria_folha($1),NULL);
	int i;
	for(i=0 ; i<$2->num_filhos ; i++)
		adiciona_filho($$,$2->filhos[i]);
}
| TK_PR_STATIC TK_PR_CONST var_local_tipo
{ $$ = cria_nodo(var_local,2,cria_folha($1),cria_folha($2));
	int i;
	for(i=0 ; i<$3->num_filhos ; i++)
		adiciona_filho($$,$3->filhos[i]);
}
;

var_local_tipo:
  tipo_primario TK_IDENTIFICADOR var_local_inic
{ $$ = cria_nodo(var_local,2,cria_folha($1),cria_folha($2));
	int i;
	for(i=0 ; i<$3->num_filhos ; i++)
		adiciona_filho($$,$3->filhos[i]);
}
| TK_IDENTIFICADOR TK_IDENTIFICADOR
{ $$ = cria_nodo(var_local,2,cria_folha($1),cria_folha($2)); }
;

var_local_inic:
  %empty
{ $$ = cria_nodo(var_local,0); }
| TK_OC_LE var_local_inic2
{ $$ = cria_nodo(var_local,1,cria_folha($1)); 
	int i;
	for(i=0 ; i<$2->num_filhos ; i++)
		adiciona_filho($$,$2->filhos[i]);
}
;

var_local_inic2:
  TK_IDENTIFICADOR
{ $$ = cria_nodo(var_local,1,cria_folha($1)); }
| literal
{ $$ = cria_nodo(var_local,1,cria_folha($1)); }
;


///Atribuicao
atribuicao:
  TK_IDENTIFICADOR '=' expressao
{ $$ = cria_nodo(atribuicao,4,cria_folha($1), NULL, NULL,$3); }
| TK_IDENTIFICADOR '[' expressao ']' '=' expressao 
{ $$ = cria_nodo(atribuicao,4,cria_folha($1), $3, NULL,$6); }
| TK_IDENTIFICADOR '$' TK_IDENTIFICADOR '=' expressao
{ $$ = cria_nodo(atribuicao,4,cria_folha($1), NULL, cria_folha($3), $5); }
| TK_IDENTIFICADOR '[' expressao ']' '$' TK_IDENTIFICADOR '=' expressao
{ $$ = cria_nodo(atribuicao,4,cria_folha($1), $3, cria_folha($6), $8); }
;

/*
///Entrada e Saida
entrada:
 TK_PR_INPUT expressao
{ $$ = cria_nodo(entrada,2,cria_folha($1),$2); }
;

saida:
 TK_PR_OUTPUT expressao saida2
{ $$ = cria_nodo(saida,2,cria_folha($1),$2); 
	int i;
	for(i=0 ; i<$3->num_filhos ; i++)
		adiciona_filho($$,$3->filhos[i]);
}
;

saida2:
 ',' expressao saida2
{ $$ = cria_nodo(saida,1,$2);
	int i;
	for(i=0 ; i<$3->num_filhos ; i++)
		adiciona_filho($$,$3->filhos[i]);
}

| ';'
{ $$ = cria_nodo(saida,0);}
;


/// Retorno, Break, Continue, Case
retorno:		TK_PR_RETURN expressao
{ $$ = cria_nodo(retorno,2,cria_folha($1), $2);}
;

break_t:			TK_PR_BREAK
{ $$ = cria_nodo(break_t,1,cria_folha($1));}
;

continue_t:		TK_PR_CONTINUE
{ $$ = cria_nodo(continue_t,1,cria_folha($1));}
;

case_t:			TK_PR_CASE TK_LIT_INT ':'
{ $$ = cria_nodo(case_t,2,cria_folha($1), cria_folha($2));}
;


/// Chamada de Funcao
cham_func:
  TK_IDENTIFICADOR '(' cham_func_arg
{ $$ = cria_nodo(cham_func,1,cria_folha($1));
	int i;
	for(i=0 ; i<$3->num_filhos ; i++)
		adiciona_filho($$,$3->filhos[i]);
}
;

cham_func_arg:
  expressao cham_func_fim
{ $$ = cria_nodo(cham_func,1,$1);
	int i;
	for(i=0 ; i<$2->num_filhos ; i++)
		adiciona_filho($$,$2->filhos[i]);
}
| '.' cham_func_fim
{ $$ = cria_nodo(cham_func,0);
	int i;
	for(i=0 ; i<$2->num_filhos ; i++)
		adiciona_filho($$,$2->filhos[i]);
}
| cham_func_fim
{ $$ = cria_nodo(cham_func,0);
	int i;
	for(i=0 ; i<$1->num_filhos ; i++)
		adiciona_filho($$,$1->filhos[i]);
}
;

cham_func_fim:
  ',' cham_func_arg
{ $$ = cria_nodo(cham_func,0);
	int i;
	for(i=0 ; i<$2->num_filhos ; i++)
		adiciona_filho($$,$2->filhos[i]);
}
| ')'
{ $$ = cria_nodo(cham_func,0);}
;


///Comando Shift
com_shift:
TK_IDENTIFICADOR com_shift_opcoes
{ $$ = cria_nodo(com_shift,1,cria_folha($1)); 
	int i;
	for(i=0 ; i<$2->num_filhos ; i++)
		adiciona_filho($$,$2->filhos[i]);
}
;

com_shift_opcoes:
  TK_OC_SL com_shift_dados
{ $$ = cria_nodo(com_shift,1,cria_folha($1)); 
	int i;
	for(i=0 ; i<$2->num_filhos ; i++)
		adiciona_filho($$,$2->filhos[i]);
}
| TK_OC_SR com_shift_dados
{ $$ = cria_nodo(com_shift,1,cria_folha($1)); 
	int i;
	for(i=0 ; i<$2->num_filhos ; i++)
		adiciona_filho($$,$2->filhos[i]);
}
| '$' TK_IDENTIFICADOR com_shift_dir
{ $$ = cria_nodo(com_shift,1,cria_folha($2)); 
	int i;
	for(i=0 ; i<$3->num_filhos ; i++)
		adiciona_filho($$,$3->filhos[i]);
}
| '[' expressao ']' com_shift_dados2
{ $$ = cria_nodo(com_shift,1,$2); 
	int i;
	for(i=0 ; i<$4->num_filhos ; i++)
		adiciona_filho($$,$4->filhos[i]);
}
;

com_shift_dados2:
  '$' TK_IDENTIFICADOR com_shift_dir
{ $$ = cria_nodo(com_shift,1,cria_folha($2)); 
	int i;
	for(i=0 ; i<$3->num_filhos ; i++)
		adiciona_filho($$,$3->filhos[i]);
}
| com_shift_dir
{ $$ = cria_nodo(com_shift,0); 
	int i;
	for(i=0 ; i<$1->num_filhos ; i++)
		adiciona_filho($$,$1->filhos[i]);
}
;

com_shift_dir:
  TK_OC_SL com_shift_dados 
{ $$ = cria_nodo(com_shift,1,cria_folha($1)); 
	int i;
	for(i=0 ; i<$2->num_filhos ; i++)
		adiciona_filho($$,$2->filhos[i]);
}
| TK_OC_SR com_shift_dados
{ $$ = cria_nodo(com_shift,1,cria_folha($1)); 
	int i;
	for(i=0 ; i<$2->num_filhos ; i++)
		adiciona_filho($$,$2->filhos[i]);
}
;

com_shift_dados:
  expressao
{ $$ = cria_nodo(com_shift,1,$1);}
;


///Controle de Fluxo
contr_fluxo:
  constr_cond
{ $$ = $1; }
| constr_iter
{ $$ = $1; }
| constr_sel
{ $$ = $1; }
;

constr_cond:
  TK_PR_IF '(' expressao ')' TK_PR_THEN bloco_comandos constr_cond_else
{ $$ = cria_nodo(contr_fluxo,4,cria_folha($1),$3,cria_folha($5), $6); 
	int i;
	for(i=0 ; i<$7->num_filhos ; i++)
		adiciona_filho($$,$7->filhos[i]);
}
;

constr_cond_else:
  TK_PR_ELSE bloco_comandos
{ $$ = cria_nodo(contr_fluxo,2,cria_folha($1),$2); }
| %empty
{ $$ = cria_nodo(contr_fluxo,0); }
;

constr_iter:
  TK_PR_FOREACH '(' TK_IDENTIFICADOR ':' lista_foreach ')' bloco_comandos
{ $$ = cria_nodo(contr_fluxo,4,cria_folha($1),cria_folha($3),$5,$7); }
| TK_PR_FOR '(' lista_for ':' expressao ':' lista_for ')' bloco_comandos
{ $$ = cria_nodo(contr_fluxo,5,cria_folha($1),$3,$5,$7,$9); }
| TK_PR_WHILE '(' expressao ')' TK_PR_DO bloco_comandos
{ $$ = cria_nodo(contr_fluxo,4,cria_folha($1),$3,cria_folha($5),$6); }
| TK_PR_DO bloco_comandos TK_PR_WHILE '(' expressao ')'
{ $$ = cria_nodo(contr_fluxo,4,cria_folha($1),$2,cria_folha($3),$5); }
;

lista_foreach:
  expressao lista_foreach2
{ $$ = cria_nodo(lista_foreach,1,$1);
	int i;
	for(i=0 ; i<$2->num_filhos ; i++)
		adiciona_filho($$,$2->filhos[i]);
}
;

lista_foreach2:
  ',' expressao lista_foreach2
{ $$ = cria_nodo(lista_foreach,1,$2);
	int i;
	for(i=0 ; i<$3->num_filhos ; i++)
		adiciona_filho($$,$3->filhos[i]);
}
| %empty
{ $$ = cria_nodo(lista_foreach,0);}
;

lista_for:
  comando_for lista_for2
{ $$ = cria_nodo(lista_for,1,$1);
	int i;
	for(i=0 ; i<$2->num_filhos ; i++)
		adiciona_filho($$,$2->filhos[i]);
}
;

lista_for2:
  ',' comando_for lista_for2
{ $$ = cria_nodo(lista_for,1,$2);
	int i;
	for(i=0 ; i<$3->num_filhos ; i++)
		adiciona_filho($$,$3->filhos[i]);
}
| %empty
{ $$ = cria_nodo(lista_for,0);}
;

constr_sel:
  TK_PR_SWITCH '(' expressao ')' bloco_comandos
{ $$ = cria_nodo(contr_fluxo,3,cria_folha($1),$3,$5);}
;



/// Comandos com Pipes
com_pipes:
  cham_func pipes cham_func
{ $$ = cria_nodo(com_pipes,3,$1,cria_folha($2),$3);}
| com_pipes pipes cham_func
{ $$ = $1;
adiciona_filho($$,cria_folha($2));
adiciona_filho($$,$3);
}
;

*/
/* Expr. Aritméticas */

val_expr:
  literal
{ $$ = cria_nodo(expressao,1,cria_folha($1));}
| '(' expressao ')'
{ $$ = cria_nodo(expressao,1,$2);}
/*
| com_pipes
{ $$ = cria_nodo(expressao,1,$1);}
| cham_func
{ $$ = cria_nodo(expressao,1,$1);}
*/
| TK_IDENTIFICADOR expr_vet
{ $$ = cria_nodo(expressao,1,cria_folha($1));
	int i;
	for(i=0 ; i<$2->num_filhos ; i++)
		adiciona_filho($$,$2->filhos[i]);
}
;

expr_vet:
  '[' expressao ']' expr_cif
{ $$ = cria_nodo(expressao,1,$2);
	int i;
	for(i=0 ; i<$4->num_filhos ; i++)
		adiciona_filho($$,$4->filhos[i]);
}
|  expr_cif
{ $$ = cria_nodo(expressao,0);
	int i;
	for(i=0 ; i<$1->num_filhos ; i++)
		adiciona_filho($$,$1->filhos[i]);
}
;

expr_cif:
  '$' TK_IDENTIFICADOR
{ $$ = cria_nodo(expressao,1,cria_folha($2));}
| %empty
{ $$ = cria_nodo(expressao,0);}
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
;

expressao:
  op_un val_expr expressao_cont
{ $$ = cria_nodo(expressao,1,cria_folha($1));
	int i;
	for(i=0 ; i<$2->num_filhos ; i++)
		adiciona_filho($$,$2->filhos[i]);
	for(i=0 ; i<$3->num_filhos ; i++)
		adiciona_filho($$,$3->filhos[i]);
}
| val_expr expressao_cont
{ $$ = cria_nodo(expressao,1,NULL); 
	int i;
	for(i=0 ; i<$1->num_filhos ; i++)
		adiciona_filho($$,$1->filhos[i]);
	for(i=0 ; i<$2->num_filhos ; i++)
		adiciona_filho($$,$2->filhos[i]);
}
;

expressao_cont:
  op_bin expressao
{ $$ = cria_nodo(expressao,3,cria_folha($1),$2,NULL);}
| '?' expressao ':' expressao
{ $$ = cria_nodo(expressao,3,NULL,$2,$4);}
| %empty
{ $$ = cria_nodo(expressao,0);}
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
		}
        return;
	}

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
    	
    	// funcao
    	case(funcao):
    	    descompila(a->filhos[0]);
            descompila(a->filhos[1]);
    	    return;
    
        // funcao: cabecalho
        case(cabecalho):
            descompila(a->filhos[0]); 
            descompila(a->filhos[1]);
            descompila(a->filhos[2]); 
            descompila(a->filhos[3]);
            return;
    
        // funcao: lista_parametros
        case(lista_parametros):
            printf("(");
            if(a->num_filhos > 0)
                for(i=0; i<a->num_filhos; i++) {
                    descompila(a->filhos[i]);
                    if(i+1 < a->num_filhos)
                        printf(",");
                }
            printf(")");
            return;
    
        // funcao: lista_parametros: parametro
        case(parametro):
            if(a->filhos[0] != NULL)
                descompila(a->filhos[0]);
            descompila(a->filhos[1]); 
            descompila(a->filhos[2]);
            return;

        // bloco_comandos:
        case(bloco_comandos):
            printf("{");
            if(a->num_filhos > 0)
                for(i=0; i<a->num_filhos; i++) {
                    descompila(a->filhos[i]);
                }
            printf("}");
            return;

        //comando_simples:
        case(comando_simples):
            descompila(a->filhos[0]);
            printf(";");
            return;

        //var_local:
        case(var_local):
            // TK_PR_STATIC
            if(a->filhos[0] != NULL)
    		descompila(a->filhos[0]);
            //TK_PR_CONST
            if(a->filhos[1] != NULL)
    		descompila(a->filhos[1]);
            //var_local_tipo:
            descompila(a->filhos[2]);
            descompila(a->filhos[3]);
            //var_local_inic e inic2:
            if(a->filhos[4] != NULL){
    		descompila(a->filhos[4]);
    		descompila(a->filhos[5]);
		}
            return;

        //atribuicao
        case(atribuicao):
            //TK_IDENTIFICADOR
            descompila(a->filhos[0]);
            if(a->filhos[1] == NULL){
    		//'=' expressao
    		if(a->filhos[2] == NULL){
    			printf(" = ");
    			descompila(a->filhos[3]);
		}
    		//'$' TK_IDENTIFICADOR '=' expressao
    		else{
    			printf("$");
    			descompila(a->filhos[2]);
    			printf("=");
    			descompila(a->filhos[3]);
		}
            }
            else{
    		//'[' expressao ']' '=' expressao 
    		if(a->filhos[2] == NULL){
    			printf("[");
    			descompila(a->filhos[1]);
    			printf("] = ");
    			descompila(a->filhos[3]);
		}
    		//'[' expressao ']' '$' TK_IDENTIFICADOR '=' expressao
    		else{
    			printf("[");
    			descompila(a->filhos[1]);
    			printf("]$");
    			descompila(a->filhos[2]);
    			printf(" = ");
    			descompila(a->filhos[3]);
		}
            }
            return;

        //entrada:
        case(entrada):
            descompila(a->filhos[0]);
            descompila(a->filhos[1]);
            return;

        //saida
        case(saida):
            descompila(a->filhos[0]);
            descompila(a->filhos[1]);
            //saida2:
            if(a->filhos[2] != NULL){
            	for(i=2; i<a->num_filhos; i++) {
                    printf(",");
                    descompila(a->filhos[i]);
		}
             }
            printf(";");
            return;

        //retorno
        case(retorno):
            descompila(a->filhos[0]);
            descompila(a->filhos[1]);
            return;

        //break_t
        case(break_t):
            descompila(a->filhos[0]);
            return;

        //continue_t
        case(continue_t):
            descompila(a->filhos[0]);
            return;

        //case_t
        case(case_t):
            descompila(a->filhos[0]);
            descompila(a->filhos[1]);
            printf(":");
            return;

        //expressao:
        case(expressao):
            if(a->filhos[0] != NULL){
    		descompila(a->filhos[0]);
            }
    	    //val_expr:
    	    descompila(a->filhos[1]);
    	    //TODO: Caso especial '(' expressao ')'
    	    //TODO: Caso especial TK_IDENTIFICADOR expr_vet

    	    //expressao_cont:
    	    //op_bin expressao
            if(a->filhos[2] != NULL){
    		descompila(a->filhos[2]);
    		descompila(a->filhos[3]);
            }
    	    //'?' expressao ':' expressao
            else{
    		printf("?");
    		descompila(a->filhos[3]);
    		printf(":");
    		descompila(a->filhos[4]);
            }
            return;



    }
        
    for(i=0; i<a->num_filhos; i++)
        descompila(a->filhos[i]);
    

};

void libera (void *arvore) {};
