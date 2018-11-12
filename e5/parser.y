/*
Giovani Tirello 252741
Vinicius Castro 193026
*/

%{
#include <stdio.h>
#include "lex.yy.h"
#include "tabela.h"
#include "arvore.h"
#include "codigo.h"
int i;
int yylex(void);
void yyerror (char const *s);
void erro_semantico (int erro, struct valor_lexico token);
extern int get_line_number();
extern int get_col_number();
extern void *arvore;
extern void descompila (void *arvore);
extern void libera (void *arvore);
Pilha_Tabelas *pilha = NULL;

/* Verificação de declarações */
#define ERR_UNDECLARED  10 //identificador não declarado
#define ERR_DECLARED    11 //identificador já declarado

/* Uso correto de identificadores */
#define ERR_VARIABLE    20 //identificador deve ser utilizado como variável
#define ERR_VECTOR      21 //identificador deve ser utilizado como vetor
#define ERR_FUNCTION    22 //identificador deve ser utilizado como função
#define ERR_USER        23 //identificador deve ser utilizado como de usuário

/* Tipos e tamanho de dados */
#define ERR_WRONG_TYPE  30 //tipos incompatíveis
#define ERR_STRING_TO_X 31 //coerção impossível de var do tipo string
#define ERR_CHAR_TO_X   32 //coerção impossível de var do tipo char
#define ERR_USER_TO_X   33 //coerção impossível de var do tipo de usuário

/* Argumentos e parâmetros */
#define ERR_MISSING_ARGS    40 //faltam argumentos 
#define ERR_EXCESS_ARGS     41 //sobram argumentos 
#define ERR_WRONG_TYPE_ARGS 42 //argumentos incompatíveis

/* Verificação de tipos em comandos */
#define ERR_WRONG_PAR_INPUT  50 //parâmetro não é identificador
#define ERR_WRONG_PAR_OUTPUT 51 //parâmetro não é literal string ou expressão
#define ERR_WRONG_PAR_RETURN 52 //parâmetro não é expressão compatível com tipo do retorno

%}

%code requires {
#include "arvore.h"
#include "tabela.h"
#include "codigo.h"
}

%union {
	struct valor_lexico valor_lexico;
	NodoArvore* NodoArvore;
}

%token <valor_lexico> '&'
%token <valor_lexico> '|'
%token <valor_lexico> '<'
%token <valor_lexico> '>'
%token <valor_lexico> '+'
%token <valor_lexico> '-'
%token <valor_lexico> '*'
%token <valor_lexico> '/'
%token <valor_lexico> '%'
%token <valor_lexico> '^'
%token <valor_lexico> '!'
%token <valor_lexico> '?'
%token <valor_lexico> ':'
%token <valor_lexico> '#'
%token <valor_lexico> '.'
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

%type <valor_lexico> literal
%type <valor_lexico> pipes
%type <valor_lexico> tipo_primario
%type <valor_lexico> encapsulamento
%type <valor_lexico> point

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
%type <NodoArvore> var_local_inic
%type <NodoArvore> atribuicao
%type <NodoArvore> expressao
%type <NodoArvore> exp_literal
%type <NodoArvore> exp_identificador
%type <NodoArvore> contr_fluxo
%type <NodoArvore> constr_sel
%type <NodoArvore> constr_cond
%type <NodoArvore> constr_cond_else
%type <NodoArvore> lista_foreach
%type <NodoArvore> lista_for
%type <NodoArvore> lista_for_comando_valido
%type <NodoArvore> constr_iter
%type <NodoArvore> entrada
%type <NodoArvore> saida
%type <NodoArvore> saida2
%type <NodoArvore> retorno
%type <NodoArvore> break_t
%type <NodoArvore> continue_t
%type <NodoArvore> case_t
%type <NodoArvore> cham_func
%type <NodoArvore> cham_func_arg
%type <NodoArvore> cham_func_fim
%type <NodoArvore> com_pipes
%type <NodoArvore> com_shift
%type <NodoArvore> com_shift_opcoes
%type <NodoArvore> com_shift_dados
%type <NodoArvore> com_shift_dados2
%type <NodoArvore> com_shift_dir

%right '?' ':' 
%left TK_OC_AND TK_OC_OR
%left '&' '|' 
%left TK_OC_LE TK_OC_GE TK_OC_EQ TK_OC_NE '<' '>'
%left '+' '-'
%left '*' '/' '%'
%right '^'
%right ENDERECO
%right PONTEIRO
%right NEG_LOGICA
%right PLUS_NEG_UNARIO

%token TOKEN_ERRO
%start programa


%%

programa:   
  %empty
    { 
        $$ = cria_nodo(programa,0); arvore = $$; 
   	    iloc_list_init($$);
	}
| programa novo_tipo	{ $$ = $1; arvore = $$; adiciona_filho($$,$2); }
| programa var_global	{ $$ = $1; arvore = $$; adiciona_filho($$,$2); }
| programa funcao       
    { 
        $$ = $1; arvore = $$; adiciona_filho($$,$2);
	    iloc_list_init($$);
        iloc_list_append_code($1,$$);                	    
        iloc_list_append_code($2,$$);

    }
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

point:
  '.'
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
	{ $$ = cria_nodo(var_global,4,cria_folha($1),NULL,NULL,cria_folha($2)); 
        
        //E4: pilha
        inicializa_pilha(&pilha);

        //E5: entradas estarao semanticamente corretas
    	//if(declarado(pilha,$1.val.string_val) == 1)
		//    erro_semantico(ERR_DECLARED,$1);
    	add_vg(pilha, $$);
	}

| TK_IDENTIFICADOR TK_IDENTIFICADOR ';'	
	{   /* E5: nao necessario
	    $$ = cria_nodo(var_global,4,cria_folha($1),NULL,NULL,cria_folha($2)); 
        if(pilha == NULL){
            pilha = inicializa_pilha();
            empilha(pilha);
        }
    	if(declarado(pilha,$1.val.string_val) == 1)
		    erro_semantico(ERR_DECLARED,$1);
    	if(declarado(pilha,$2.val.string_val) == 0)
		    erro_semantico(ERR_UNDECLARED,$1);
		*/
	}

| TK_IDENTIFICADOR TK_PR_STATIC tipo_primario ';'
	{ 
	    $$ = cria_nodo(var_global,4,cria_folha($1),NULL,cria_folha($2),cria_folha($3)); 
        inicializa_pilha(&pilha);    
    
        /* E5: nao necessario
    	if(declarado(pilha,$1.val.string_val) == 1)
		    erro_semantico(ERR_DECLARED,$1);
        */
        
        add_vg(pilha, $$);
	
}

| TK_IDENTIFICADOR TK_PR_STATIC TK_IDENTIFICADOR ';' 
	{   /* E5: nao necessario
	    $$ = cria_nodo(var_global,4,cria_folha($1),NULL,cria_folha($2),cria_folha($3));
        if(pilha == NULL){
            pilha = inicializa_pilha();
            empilha(pilha);
        }
    	if(declarado(pilha,$1.val.string_val) == 1)
		    erro_semantico(ERR_DECLARED,$1);
    	if(declarado(pilha,$3.val.string_val) == 0)
		    erro_semantico(ERR_UNDECLARED,$1);
		*/	
	}

| TK_IDENTIFICADOR '[' TK_LIT_INT ']' tipo_primario ';' 
	{   /* E5: nao necessario
	    $$ = cria_nodo(var_global,4,cria_folha($1),cria_folha($3),NULL,cria_folha($5));
        if(pilha == NULL){
            pilha = inicializa_pilha();
            empilha(pilha);
        }
    	if(declarado(pilha,$1.val.string_val) == 1)
		    erro_semantico(ERR_DECLARED,$1);
		    
		*/	
	}

| TK_IDENTIFICADOR '[' TK_LIT_INT ']' TK_IDENTIFICADOR ';' 
	{   /* E5: nao necessario
	    $$ = cria_nodo(var_global,4,cria_folha($1),cria_folha($3),NULL,cria_folha($5));
        if(pilha == NULL){
            pilha = inicializa_pilha();
            empilha(pilha);
        }
    	if(declarado(pilha,$1.val.string_val) == 1)
		    erro_semantico(ERR_DECLARED,$1);
    	if(declarado(pilha,$5.val.string_val) == 0)
		    erro_semantico(ERR_UNDECLARED,$1);
		*/	
	}

| TK_IDENTIFICADOR '[' TK_LIT_INT ']' TK_PR_STATIC tipo_primario ';' 
	{   /* E5: nao necessario
	    $$ = cria_nodo(var_global,4,cria_folha($1),cria_folha($3),cria_folha($5),cria_folha($6));
        if(pilha == NULL){
            pilha = inicializa_pilha();
            empilha(pilha);
        }
    	if(declarado(pilha,$1.val.string_val) == 1)
		    erro_semantico(ERR_DECLARED,$1);
		    
		*/
	}

| TK_IDENTIFICADOR '[' TK_LIT_INT ']' TK_PR_STATIC TK_IDENTIFICADOR ';'
	{   /* E5: nao necessario
	    $$ = cria_nodo(var_global,4,cria_folha($1),cria_folha($3),cria_folha($5),cria_folha($6)); 
        if(pilha == NULL){
            pilha = inicializa_pilha();
            empilha(pilha);
        }
    	if(declarado(pilha,$1.val.string_val) == 1)
		    erro_semantico(ERR_DECLARED,$1);
    	if(declarado(pilha,$6.val.string_val) == 0)
		    erro_semantico(ERR_UNDECLARED,$1);
		*/
	}

;

/* Definição de Funções */
funcao:
  cabecalho bloco_comandos
	{ 
	    $$ = cria_nodo(funcao,2,$1,$2); 
	    iloc_list_init($$);
        iloc_list_append_code($2,$$);	    	    
	}
;

cabecalho:
  tipo_primario TK_IDENTIFICADOR parametros
	{ $$ = cria_nodo(cabecalho,4,NULL,cria_folha($1),cria_folha($2),$3); 
	
//	if(declarado(pilha, cria_folha($2), cria_folha($1)) == 1)
//		;//erro_semantico(ERR_DECLARED);
	        add_func(pilha, $$);
	}	
	
| TK_IDENTIFICADOR TK_IDENTIFICADOR parametros
	{ $$ = cria_nodo(cabecalho,4,NULL,cria_folha($1),cria_folha($2),$3); 
	
//	if(declarado(pilha,cria_folha($1),NULL) == 0)
//		;//erro_semantico(ERR_UNDECLARED);
//	if(declarado(pilha,cria_folha($2),NULL) == 1)
//		;//erro_semantico(ERR_DECLARED);
	
	}	

| TK_PR_STATIC tipo_primario TK_IDENTIFICADOR parametros
	{ $$ = cria_nodo(cabecalho,4,cria_folha($1),cria_folha($2),cria_folha($3),$4); 
	
//	if(declarado(pilha, cria_folha($3), cria_folha($2)) == 1)
//		;//erro_semantico(ERR_DECLARED);
	}		

| TK_PR_STATIC TK_IDENTIFICADOR TK_IDENTIFICADOR parametros
	{ $$ = cria_nodo(cabecalho,4,cria_folha($1),cria_folha($2),cria_folha($3),$4); 
	
//	if(declarado(pilha,cria_folha($2),NULL) == 0)
//		;//erro_semantico(ERR_UNDECLARED);
//	if(declarado(pilha,cria_folha($3),NULL) == 1)
//		;//erro_semantico(ERR_DECLARED);
	
	}
;

parametros:
  '(' ')'
	{ $$ = cria_nodo(parametros,0); 
	empilha(pilha);
	}

| '(' lista_parametros ')'
	{ $$ = cria_nodo(parametros,0); adiciona_netos($$,$2); 
	empilha(pilha);
	}
;

lista_parametros:
  parametro
	{ $$ = cria_nodo(parametros,1,$1); }

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
	{ 
	    $$ = cria_nodo(bloco_comandos,0); 
	    iloc_list_init($$);
	}

| '{' sequencia_comandos_simples '}'
	{ 
	    $$ = cria_nodo(bloco_comandos,0); adiciona_netos($$,$2);
	    iloc_list_init($$);
        iloc_list_append_code($2,$$);
	}
;

sequencia_comandos_simples:
  comando_simples
	{ 
	    $$ = cria_nodo(sequencia_comandos_simples,1,$1); 
	    iloc_list_init($$);
        iloc_list_append_code($1,$$);
	}

| sequencia_comandos_simples comando_simples
	{ 
	    $$ = $1; adiciona_filho($$,$2); 
        iloc_list_init($$);
        iloc_list_append_code($2,$1);
        iloc_list_append_code($1,$$);	    
	}
;

comando_simples:
  bloco_comandos ';'	{ $$ = cria_nodo(comando_simples,1,$1); }
| var_local ';'		{ $$ = cria_nodo(comando_simples,1,$1); }
| atribuicao ';'    
    { 
        $$ = cria_nodo(comando_simples,1,$1); 
        iloc_list_init($$);
        iloc_list_append_code($1,$$);
    }
| contr_fluxo ';'  	{ $$ = cria_nodo(comando_simples,1,$1); }	
| entrada ';'		{ $$ = cria_nodo(comando_simples,1,$1); }	
| saida			{ $$ = cria_nodo(comando_simples,1,$1); }		
| retorno ';'		{ $$ = cria_nodo(comando_simples,1,$1); }	
| break_t ';'		{ $$ = cria_nodo(comando_simples,1,$1); }	
| continue_t ';'	{ $$ = cria_nodo(comando_simples,1,$1); }	
| case_t		{ $$ = cria_nodo(comando_simples,1,$1); }		
| cham_func ';'		{ $$ = cria_nodo(comando_simples,1,$1); }	
| com_shift ';'		{ $$ = cria_nodo(comando_simples,1,$1); }	
| com_pipes ';'		{ $$ = cria_nodo(comando_simples,1,$1); }	
;

/*Variavel Local*/
var_local:
  tipo_primario TK_IDENTIFICADOR
    { $$ = cria_nodo(var_local,5,NULL,NULL,cria_folha($1),cria_folha($2),NULL); 
	
	/*if(declarado_tabela(pilha, cria_folha($2), cria_folha($1)) == 1)
		;//erro_semantico(ERR_DECLARED);*/
	add_vl(pilha, $$);
	
	gera_codigo_vl(pilha, $$);
	}

| tipo_primario TK_IDENTIFICADOR var_local_inic
    { $$ = cria_nodo(var_local,4,NULL,NULL,cria_folha($1),cria_folha($2)); adiciona_netos($$,$3); 
	
	/*if(declarado_tabela(pilha, cria_folha($2), cria_folha($1)) == 1)
		;//erro_semantico(ERR_DECLARED);*/
	add_vl(pilha, $$);
	
	gera_codigo_vl(pilha, $$);
	}

| TK_IDENTIFICADOR TK_IDENTIFICADOR
    { $$ = cria_nodo(var_local,5,NULL,NULL,cria_folha($1),cria_folha($2),NULL); }

| TK_PR_STATIC tipo_primario TK_IDENTIFICADOR
    { $$ = cria_nodo(var_local,5,cria_folha($1),NULL,cria_folha($2),cria_folha($3),NULL); 
	
	if(declarado_tabela(pilha, cria_folha($3), cria_folha($2)) == 1)
		;//erro_semantico(ERR_DECLARED);
	add_vl(pilha, $$);
	
	}

| TK_PR_STATIC tipo_primario TK_IDENTIFICADOR var_local_inic
    { $$ = cria_nodo(var_local,4,cria_folha($1),NULL,cria_folha($2),cria_folha($3)); adiciona_netos($$,$4); 
	
	if(declarado_tabela(pilha, cria_folha($3), cria_folha($2)) == 1)
		;//erro_semantico(ERR_DECLARED);
	add_vl(pilha, $$);
	
	}

| TK_PR_STATIC TK_IDENTIFICADOR TK_IDENTIFICADOR
    { $$ = cria_nodo(var_local,5,cria_folha($1),NULL,cria_folha($2),cria_folha($3),NULL); }

| TK_PR_CONST tipo_primario TK_IDENTIFICADOR
    { $$ = cria_nodo(var_local,5,NULL,cria_folha($1),cria_folha($2),cria_folha($3),NULL); 
	
	if(declarado_tabela(pilha, cria_folha($3), cria_folha($2)) == 1)
		;//erro_semantico(ERR_DECLARED);
	add_vl(pilha, $$);
	
	}

| TK_PR_CONST tipo_primario TK_IDENTIFICADOR var_local_inic
    { $$ = cria_nodo(var_local,4,NULL,cria_folha($1),cria_folha($2),cria_folha($3)); adiciona_netos($$,$4); 
	
	if(declarado_tabela(pilha, cria_folha($3), cria_folha($2)) == 1)
		;//erro_semantico(ERR_DECLARED);
	add_vl(pilha, $$);
	
	}

| TK_PR_CONST TK_IDENTIFICADOR TK_IDENTIFICADOR
    { $$ = cria_nodo(var_local,5,NULL,cria_folha($1),cria_folha($2),cria_folha($3),NULL); }

| TK_PR_STATIC TK_PR_CONST tipo_primario TK_IDENTIFICADOR
    { $$ = cria_nodo(var_local,5,cria_folha($1),cria_folha($2),cria_folha($3),cria_folha($4),NULL); 
	
	if(declarado_tabela(pilha, cria_folha($4), cria_folha($3)) == 1)
		;//erro_semantico(ERR_DECLARED);
	add_vl(pilha, $$);
	
	}

| TK_PR_STATIC TK_PR_CONST tipo_primario TK_IDENTIFICADOR var_local_inic
    { $$ = cria_nodo(var_local,4,cria_folha($1),cria_folha($2),cria_folha($3),cria_folha($4)); adiciona_netos($$,$5); 
	
	if(declarado_tabela(pilha, cria_folha($4), cria_folha($3)) == 1)
		;//erro_semantico(ERR_DECLARED);
	add_vl(pilha, $$);
	
	}

| TK_PR_STATIC TK_PR_CONST TK_IDENTIFICADOR TK_IDENTIFICADOR
    { $$ = cria_nodo(var_local,5,cria_folha($1),cria_folha($2),cria_folha($3),cria_folha($4),NULL); }
;

var_local_inic:
  TK_OC_LE TK_IDENTIFICADOR
    { $$ = cria_nodo(var_local_inic,2,cria_folha($1),cria_folha($2)); 
	
	/*if(declarado_atr(pilha,cria_folha($2)) == 0)
		;//erro_semantico(ERR_UNDECLARED);*/
	
	}

| TK_OC_LE literal
    { $$ = cria_nodo(var_local_inic,2,cria_folha($1),cria_folha($2)); }
;

/*Atribuicao*/
atribuicao:
  TK_IDENTIFICADOR '=' expressao
    {
        $$ = cria_nodo(atribuicao,4,cria_folha($1), NULL, NULL,$3);
        inicializa_pilha(&pilha);
        //Escopo local não inicializado na pilha
        if(pilha->num_tabelas == 1)
            empilha(pilha);  
            
        /* E5: nao necessario       
    	if(declarado(pilha,$1.val.string_val) == 0)
    	    erro_semantico(ERR_UNDECLARED,$1);

        if(eh_vetor(pilha,cria_folha($1)) == 1)
		;//erro_semantico(ERR_VARIABLE);
	    if(eh_usr(pilha,cria_folha($1)) == 1)
		;//erro_semantico(ERR_USER);
        */

        // Copia o valor do nodo expressao para o valor do nodo atribuicao          
        $$->valor = $3->valor;
	    gera_codigo_atr(pilha, $$);
	
	}

| TK_IDENTIFICADOR '[' expressao ']' '=' expressao 
    { $$ = cria_nodo(atribuicao,4,cria_folha($1), $3, NULL,$6); }
| TK_IDENTIFICADOR '$' TK_IDENTIFICADOR '=' expressao
    { $$ = cria_nodo(atribuicao,4,cria_folha($1), NULL, cria_folha($3), $5); }
| TK_IDENTIFICADOR '[' expressao ']' '$' TK_IDENTIFICADOR '=' expressao
    { $$ = cria_nodo(atribuicao,4,cria_folha($1), $3, cria_folha($6), $8); }
;


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
	
	if(declarado_atr(pilha,cria_folha($1)) == 0)
		;//erro_semantico(ERR_UNDECLARED);
	if(analisa_args(pilha,$$) == 0)
		;//erro_semantico(ERR_FUNCTION);
	

}
;

cham_func_arg:
  expressao cham_func_fim
{ $$ = cria_nodo(cham_func,1,$1);
	int i;
	for(i=0 ; i<$2->num_filhos ; i++)
		adiciona_filho($$,$2->filhos[i]);
}
| point cham_func_fim
{ $$ = cria_nodo(cham_func,1, cria_folha($1));
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
{ $$ = cria_nodo(constr_cond,4,cria_folha($1),$3,cria_folha($5),$6,NULL); 
  if($7 != NULL)
    $$->filhos[4] = $7;

	//TODO E5: gera_codigo_if($$);
}
;

constr_cond_else:
  TK_PR_ELSE bloco_comandos
{ $$ = cria_nodo(constr_cond_else,2,cria_folha($1),$2); }
| %empty
{ $$ = cria_nodo(constr_cond_else,0); }
;

constr_iter:
  TK_PR_FOREACH '(' TK_IDENTIFICADOR ':' lista_foreach ')' bloco_comandos
{ $$ = cria_nodo(constr_foreach,4,cria_folha($1),cria_folha($3),$5,$7); }
| TK_PR_FOR '(' lista_for ':' expressao ':' lista_for ')' bloco_comandos
{ $$ = cria_nodo(constr_for,5,cria_folha($1),$3,$5,$7,$9); }
| TK_PR_WHILE '(' expressao ')' TK_PR_DO bloco_comandos
{ $$ = cria_nodo(constr_while,4,cria_folha($1),$3,cria_folha($5),$6); 
//TODO E5: gera_codigo_while($$);
}
| TK_PR_DO bloco_comandos TK_PR_WHILE '(' expressao ')'
{ $$ = cria_nodo(constr_do,4,cria_folha($1),$2,cria_folha($3),$5); 
//TODO E5: gera_codigo_do($$);
}
;

lista_foreach:
  expressao
    { $$ = cria_nodo(lista_foreach,1,$1); }
| expressao ',' lista_foreach
    { $$ = cria_nodo(lista_foreach,1,$1); adiciona_netos($$,$3); }
;

lista_for_comando_valido:
  var_local  {$$ = cria_nodo(lista_for_comando_valido,1,$1); }
| atribuicao {$$ = cria_nodo(lista_for_comando_valido,1,$1); } 
| break_t {$$ = cria_nodo(lista_for_comando_valido,1,$1); } 
| continue_t  {$$ = cria_nodo(lista_for_comando_valido,1,$1); }
;

lista_for:
  lista_for_comando_valido 
    { $$ = cria_nodo(lista_for,0); adiciona_netos($$,$1); }
| lista_for ',' lista_for_comando_valido
    { $$ = $1; adiciona_netos($$,$3);  }
;

constr_sel:
  TK_PR_SWITCH '(' expressao ')' bloco_comandos
    { $$ = cria_nodo(constr_sel,3,cria_folha($1),$3,$5); }
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


/* Expressoes */

expressao:
  exp_literal	
    { 
        $$ = cria_nodo(exp_literal,0); adiciona_netos($$,$1); 
        $$->valor = $1->valor;
        iloc_list_init($$);
        iloc_list_append_code($1,$$);
    }
  
| exp_identificador 
    { $$ = cria_nodo(exp_identificador,0); adiciona_netos($$,$1); 
        $$->valor = $1->valor;
	//TODO: iloc_list_append_code($1, $$);
    }
    
| '(' expressao ')' { $$ = cria_nodo(exp_parenteses,0); adiciona_filho($$,$2); }
| com_pipes { $$ = $1; }
| cham_func { $$ = $1; }
| expressao '?' expressao ':' expressao { $$ = cria_nodo(exp_ternaria,5, $1,cria_folha($2), $3,cria_folha($4), $5); }
| expressao TK_OC_OR expressao { $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); }
| expressao TK_OC_AND expressao { $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); }
| expressao '&' expressao { $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); }
| expressao '|' expressao { $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); }
| expressao TK_OC_LE expressao { $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); }
| expressao TK_OC_GE expressao { $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); }
| expressao TK_OC_EQ expressao { $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); }
| expressao TK_OC_NE expressao	{ $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); }
| expressao '<' expressao	{ $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); }
| expressao '>' expressao	{ $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); }
| expressao '+' expressao	{ $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3);
	$$->valor = $1->valor + $3->valor;
	//TODO: iloc_list_append_code($1, $$);
	//TODO: iloc_list_append_code($2, $$);
	/*$$->code->op1 = */ char *reg_aux_e = gera_registrador();
	/*$$->code->iloc->opcode = */ printf("addI %d, %d => %s\n",$1->valor, $3->valor, reg_aux_e); //TODO:não eh pra ser $1-> valor, $3->valor e sim os registradores carregados
}
| expressao '-' expressao	{ $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); }
| expressao '*' expressao	{ $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); }
| expressao '/' expressao	{ $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); }
| expressao '%' expressao	{ $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); }
| expressao '^' expressao	{ $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); }
| '&' expressao %prec ENDERECO	{ $$ = cria_nodo(exp_unaria,2, cria_folha($1), $2); }
| '*' expressao %prec PONTEIRO		{ $$ = cria_nodo(exp_unaria,2, cria_folha($1), $2); }
| '!' expressao %prec NEG_LOGICA	{ $$ = cria_nodo(exp_unaria,2, cria_folha($1), $2); }
| '+' expressao %prec PLUS_NEG_UNARIO	{ $$ = cria_nodo(exp_unaria,2, cria_folha($1), $2); }
| '-' expressao %prec PLUS_NEG_UNARIO	{ $$ = cria_nodo(exp_unaria,2, cria_folha($1), $2); }
;

exp_identificador:
  TK_IDENTIFICADOR  
    { 
        $$ = cria_nodo(exp_identificador,3,cria_folha($1),NULL,NULL); 

        inicializa_pilha(&pilha);
        //Escopo local não inicializado na pilha
        if(pilha->num_tabelas == 1)
            empilha(pilha);          

        /* E5: nao necessario	
	    if(declarado_atr(pilha,cria_folha($1)) == 0)
		    ;//erro_semantico(ERR_UNDECLARED);
	    if(eh_vetor(pilha,cria_folha($1)) == 1)
		    ;//erro_semantico(ERR_VECTOR);
	    if(eh_usr(pilha,cria_folha($1)) == 1)
		    ;//erro_semantico(ERR_USER);
	    */
	
	    //recupera simbolo pilha ou stack
	    Simbolo *s = search_sim_table(pilha, cria_folha($1)->nodo.valor_lexico.val.string_val);
	    char* vg_ou_vl = "rfp";
	    //se nao achou eh VG
	    if(s == NULL){
		    s = search_sim_stack(pilha, cria_folha($1)->nodo.valor_lexico.val.string_val);
		    vg_ou_vl = "rbss";
	    }
	    /*$$->code->op1 = */ char *reg_aux_e1 = gera_registrador();
	    /*$$->code->opcode = */ printf("loadAI %s, %d => %s\n", vg_ou_vl, s->deslocamento, reg_aux_e1);
	    $$->valor = s->valor;
	}

| TK_IDENTIFICADOR '[' expressao ']' 
    { $$ = cria_nodo(exp_identificador,3,cria_folha($1),$3,NULL); }
| TK_IDENTIFICADOR '$' TK_IDENTIFICADOR 
    { $$ = cria_nodo(exp_identificador,3,cria_folha($1),NULL,cria_folha($3)); }
| TK_IDENTIFICADOR '[' expressao ']' '$' TK_IDENTIFICADOR
    { $$ = cria_nodo(exp_identificador,3,cria_folha($1),$3,cria_folha($6));	}
;

exp_literal:
  literal 
    { 
        $$ = cria_nodo(exp_literal,1,cria_folha($1));
	    $$->valor =  $1.val.int_val;
	    iloc_list_init($$);
    }
;

%%

/* Called by yyparse on error.  */
void yyerror (char const *s)
{
  fprintf (stderr, "linha %d coluna %ld: %s: token invalido: %s\n", get_line_number(), get_col_number()-strlen(yytext)+1, s, yytext);
}

void erro_semantico (int erro, struct valor_lexico token)
{
    fprintf (stderr, "linha %d coluna %d: token '%s' ", token.line, token.col, token.val.string_val);
    switch(erro){
        case(ERR_UNDECLARED):
            fprintf (stderr,"ERR_UNDECLARED\n");
            
    }

    exit(erro);

}

void descompila (void *arvore) {
    int i;
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
				printf(" '%c' ",a->nodo.valor_lexico.val.char_val);
				break;
			case(STRING):
				printf(" %s ",a->nodo.valor_lexico.val.string_val);
				break;
			case(BOOL):
				if(a->nodo.valor_lexico.val.bool_val == 0)
					printf(" true ");
				else	
					printf(" false ");
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
            if(a->filhos[0] != NULL)
                descompila(a->filhos[0]); 
            descompila(a->filhos[1]);
            descompila(a->filhos[2]); 
            descompila(a->filhos[3]);
            return;
   
        // funcao: parametros
        case(parametros):
            printf("(");
            if(a->num_filhos > 0){
                descompila(a->filhos[0]);
                for(i=1; i<a->num_filhos; i++){
                    printf(",");
                    descompila(a->filhos[i]);
                }
            }
            printf(")");
            return;

        // funcao: parametros: parametro
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
                for(i=0; i<a->num_filhos; i++)
                    descompila(a->filhos[i]);
            printf("}"); 
            return;

        //comando_simples:
        case(comando_simples):
            descompila(a->filhos[0]);
		    if(a->filhos[0]->nodo.type != case_t && a->filhos[0]->nodo.type != saida)
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
            // tipo_primario ou TK_IDENTIFICADOR:
            descompila(a->filhos[2]);
            // TK_IDENTIFICADOR
            descompila(a->filhos[3]);
            //var_local_inic:
            if(a->filhos[4] != NULL) {
    		    descompila(a->filhos[4]);
    		    descompila(a->filhos[5]);
		    }
            return;

        //atribuicao
        case(atribuicao):
            //TK_IDENTIFICADOR
            descompila(a->filhos[0]);
            // [ expressao ]
            if(a->filhos[1] != NULL){
                printf("[");
                descompila(a->filhos[1]);
                printf("]");
            }
            // $ TK_IDENTIFICADOR
            if(a->filhos[2] != NULL){
                printf("$");
                descompila(a->filhos[2]);
            }                                    
            
            // = expressao
            printf("=");
            descompila(a->filhos[3]);
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


        //Chamada de Funcao:
        case(cham_func):
            descompila(a->filhos[0]);
            printf("(");
            descompila(a->filhos[1]);
            for(i=2; i<a->num_filhos; i++){
                    printf(",");
                    descompila(a->filhos[i]);
            }
            printf(")");
            return;


        //Comando shift:
        case(com_shift):
            descompila(a->filhos[0]);
            if(a->filhos[1]->type == 0){
		switch(a->filhos[1]->nodo.valor_lexico.type) {
			case(IDENT):
				printf("$");
				descompila(a->filhos[1]);
				for(i=2; i<a->num_filhos; i++)
					descompila(a->filhos[i]);
				break;
			default:
				descompila(a->filhos[1]);
				descompila(a->filhos[2]);
				break;
		}
            }
            else{
		printf("[");
		descompila(a->filhos[1]);
		printf("]$");
		for(i=2; i<a->num_filhos; i++)
			descompila(a->filhos[i]);
            }
            return;

        // constr_sel:
        // TK_PR_SWITCH '(' expressao ')' bloco_comandos 
        case(constr_sel):
            descompila(a->filhos[0]);
            printf("(");
            descompila(a->filhos[1]);
            printf(")");
            descompila(a->filhos[2]);
            return;
        
        // constr_cond
        // TK_PR_IF '(' expressao ')' TK_PR_THEN bloco_comandos constr_cond_else
        case(constr_cond):
            descompila(a->filhos[0]);
            printf("(");
            descompila(a->filhos[1]);
            printf(")");
            descompila(a->filhos[2]);
            descompila(a->filhos[3]);
            if(a->filhos[4]->num_filhos > 0)
                descompila(a->filhos[4]);
            return;

        // constr_cond_else
        // TK_PR_ELSE bloco_comandos 
        case(constr_cond_else):
            descompila(a->filhos[0]);
            descompila(a->filhos[1]);
            return;

        case(lista):
            descompila(a->filhos[0]);
            for(i=1; i<a->num_filhos; i++){
                    printf(",");
                    descompila(a->filhos[i]);
            }
            return;

        // constr_foreach
        // TK_PR_FOREACH '(' TK_IDENTIFICADOR ':' lista_foreach ')' bloco_comandos
        case(constr_foreach):
            descompila(a->filhos[0]);
            printf("(");
            descompila(a->filhos[1]);
            printf(":");
            descompila(a->filhos[2]);
            printf(")");
            descompila(a->filhos[3]);
            return;

        // lista_foreach
        case(lista_foreach):
            descompila(a->filhos[0]);
            for(i=1; i<a->num_filhos; i++){
                printf(",");
                descompila(a->filhos[i]);
            }
            return;

        // constr_for
        // TK_PR_FOR '(' lista_for ':' expressao ':' lista_for ')' bloco_comandos
        case(constr_for):
            descompila(a->filhos[0]);
            printf("(");
            descompila(a->filhos[1]);
            printf(":");
            descompila(a->filhos[2]);
            printf(":");
            descompila(a->filhos[3]);
            printf(")");
            descompila(a->filhos[4]);
            return;

        // lista_for
        case(lista_for):
            descompila(a->filhos[0]);
            for(i=1; i<a->num_filhos; i++){
                printf(",");
                descompila(a->filhos[i]);
            }
            return;

        case(constr_while):
            descompila(a->filhos[0]);
            printf("(");
            descompila(a->filhos[1]);
            printf(")");
            descompila(a->filhos[2]);
            descompila(a->filhos[3]);
            return;

        case(constr_do):
            descompila(a->filhos[0]);
            descompila(a->filhos[1]);
            descompila(a->filhos[2]);
            printf("(");
            descompila(a->filhos[3]);
            printf(")");
            return;
        

        //Comandos com Pipes:
        case(com_pipes):
            for(i=0; i<a->num_filhos; i++)
                    descompila(a->filhos[i]);
            return;

        // expressao: exp_identificador
        // TK_IDENTIFICADOR '[' expressao ']' '$' TK_IDENTIFICADOR
        case(exp_identificador):
            descompila(a->filhos[0]);
            if(a->filhos[1] != NULL){
                printf("["); 
                descompila(a->filhos[1]);
                printf("]");
            }
            if(a->filhos[2] != NULL){
                printf("$"); descompila(a->filhos[2]);                
            }
            return;
        
        //expressao: exp_literal
        case(exp_literal):
			descompila(a->filhos[0]);
			return;
        
        // ( expressao )
        case(exp_parenteses):
            printf("(");
            descompila(a->filhos[0]);
            printf(")");
            return;

        case(exp_ternaria):
            descompila(a->filhos[0]);
            descompila(a->filhos[1]);
            descompila(a->filhos[2]);
            descompila(a->filhos[3]);
            descompila(a->filhos[4]);
            return;
    
        case(exp_binaria):
            descompila(a->filhos[0]);
            descompila(a->filhos[1]);
            descompila(a->filhos[2]);
            return;

        case(exp_unaria):
            descompila(a->filhos[0]);
            descompila(a->filhos[1]);
            return;
    }
    for(i=0; i<a->num_filhos; i++){
        descompila(a->filhos[i]);
    }
    

};

void libera (void *arvore) {
	int i;
	NodoArvore *a = arvore;
	for(i=0; i<a->num_filhos; i++){
		if(a->filhos[i] != NULL){
			libera(a->filhos[i]);
			free(a->filhos[i]);	
		}
	}
};
