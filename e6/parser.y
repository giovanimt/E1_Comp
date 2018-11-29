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
Pilha_RA *pilhaRA = NULL;
Lista_Padroes_RA *listaRA = NULL;

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
	    //E6:
	    inicializa_pilha_RA(pilhaRA, $$);
	}
| programa novo_tipo	{ $$ = $1; arvore = $$; adiciona_filho($$,$2); }
| programa var_global	{ $$ = $1; arvore = $$; adiciona_filho($$,$2); }
| programa funcao       
    { 
        $$ = $1; arvore = $$; adiciona_filho($$,$2);
	    iloc_list_init($$);
        //iloc_list_append_code($1,$$);                	    
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
  TK_PR_CLASS TK_IDENTIFICADOR '[' novo_tipo_lista_campos ']' ';' {;}
;

novo_tipo_campo:
  tipo_primario TK_IDENTIFICADOR {;}
| encapsulamento tipo_primario TK_IDENTIFICADOR {;}
;

novo_tipo_lista_campos:
  novo_tipo_campo {;}
| novo_tipo_lista_campos ':' novo_tipo_campo {;}
;	



/* Declarações de Variáveis Globais */
var_global:
  TK_IDENTIFICADOR tipo_primario ';' 
	{ $$ = cria_nodo(var_global,4,cria_folha($1),NULL,NULL,cria_folha($2)); 
        
        //E4: pilha
        inicializa_pilha(&pilha);
    	add_vg(pilha, $$);
	}

| TK_IDENTIFICADOR TK_IDENTIFICADOR ';' {;}

| TK_IDENTIFICADOR TK_PR_STATIC tipo_primario ';' {;}

| TK_IDENTIFICADOR TK_PR_STATIC TK_IDENTIFICADOR ';' {;}

| TK_IDENTIFICADOR '[' TK_LIT_INT ']' tipo_primario ';' {;}

| TK_IDENTIFICADOR '[' TK_LIT_INT ']' TK_IDENTIFICADOR ';' {;}

| TK_IDENTIFICADOR '[' TK_LIT_INT ']' TK_PR_STATIC tipo_primario ';' {;}

| TK_IDENTIFICADOR '[' TK_LIT_INT ']' TK_PR_STATIC TK_IDENTIFICADOR ';'{;}
;



/* Definição de Funções */
funcao:
  cabecalho bloco_comandos
	{ 
	$$ = cria_nodo(funcao,2,$1,$2); 

	iloc_list_init($$);

	//E6:
	inicio_funcao($$, pilha);
	
        iloc_list_append_code($2,$$);
	}
;

cabecalho:
  tipo_primario TK_IDENTIFICADOR parametros
	{ 
	$$ = cria_nodo(cabecalho,4,NULL,cria_folha($1),cria_folha($2),$3); 

	add_func(pilha, $$); 
	}	
	
| TK_IDENTIFICADOR TK_IDENTIFICADOR parametros {;}	

| TK_PR_STATIC tipo_primario TK_IDENTIFICADOR parametros {;}		

| TK_PR_STATIC TK_IDENTIFICADOR TK_IDENTIFICADOR parametros{;}
;

parametros:
  '(' ')'
	{ 
	$$ = cria_nodo(parametros,0); 
	inicializa_pilha(&pilha);
	empilha(pilha);
	}

| '(' lista_parametros ')'
	{
	$$ = cria_nodo(parametros,0); adiciona_netos($$,$2); 
	inicializa_pilha(&pilha);
	empilha(pilha);
	}
;

lista_parametros:
  parametro
	{
	$$ = cria_nodo(parametros,1,$1);
	}

| lista_parametros ',' parametro
	{
	$$ = $1; adiciona_filho($$,$3);
	}
;

parametro:
  tipo_primario TK_IDENTIFICADOR
	{
	$$ = cria_nodo(parametro,3,NULL,cria_folha($1),cria_folha($2));
	}

| TK_IDENTIFICADOR TK_IDENTIFICADOR {;}

| TK_PR_CONST tipo_primario TK_IDENTIFICADOR {;}

| TK_PR_CONST TK_IDENTIFICADOR TK_IDENTIFICADOR {;}
;


/* Bloco de Comandos */
bloco_comandos:
  '{' '}'
	{ 
	$$ = cria_nodo(bloco_comandos,0); 

	iloc_list_init($$);

	//FUNCAO VAZIA
	iloc_list_append_op($$->code, iloc_create_op(NULL,"addI","rsp","0","rsp",NULL));
	}

| '{' sequencia_comandos_simples '}'
	{ 
	$$ = cria_nodo(bloco_comandos,0); adiciona_netos($$,$2);

	iloc_list_init($$);
        $$->code = $2->code;
	//imprime_pilha(pilha);
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

        iloc_list_append_code($2,$$);	    
	}
;

comando_simples:
  bloco_comandos ';'	{ $$ = cria_nodo(comando_simples,1,$1); }
| var_local ';' 
	{
	$$ = cria_nodo(comando_simples,1,$1); 

        iloc_list_init($$);
        iloc_list_append_code($1,$$);        
	}

| atribuicao ';'    
	{ 
        $$ = cria_nodo(comando_simples,1,$1); 
        iloc_list_init($$);
        iloc_list_append_code($1,$$);
	}

| contr_fluxo ';'  	
	{ 
        $$ = cria_nodo(comando_simples,1,$1); 
        iloc_list_init($$);
        iloc_list_append_code($1,$$);        
	}
	
| entrada ';'		{;}	
| saida			{;}		
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
	{ 
	$$ = cria_nodo(var_local,5,NULL,NULL,cria_folha($1),cria_folha($2),NULL);	

	inicializa_pilha(&pilha);
        //Escopo local não inicializado na pilha
        if(pilha->num_tabelas == 1){
            empilha(pilha);
	    printf ("oi");	 
	}
	add_vl(pilha, $$);

        iloc_list_init($$);
	gera_codigo_rsp($$);
	}

| tipo_primario TK_IDENTIFICADOR var_local_inic
	{ 
        $$ = cria_nodo(var_local,4,NULL,NULL,cria_folha($1),cria_folha($2)); adiciona_netos($$,$3); 
	
        inicializa_pilha(&pilha);
        //Escopo local não inicializado na pilha
        if(pilha->num_tabelas == 1){
            empilha(pilha);
	    printf("oi");	 
	}		    
		    
	add_vl(pilha, $$);
	
        iloc_list_init($$);
	gera_codigo_rsp($$);
	gera_codigo_vl(pilha, $$);
	}

| TK_IDENTIFICADOR TK_IDENTIFICADOR {;}

| TK_PR_STATIC tipo_primario TK_IDENTIFICADOR {;}

| TK_PR_STATIC tipo_primario TK_IDENTIFICADOR var_local_inic {;}

| TK_PR_STATIC TK_IDENTIFICADOR TK_IDENTIFICADOR {;}

| TK_PR_CONST tipo_primario TK_IDENTIFICADOR {;}

| TK_PR_CONST tipo_primario TK_IDENTIFICADOR var_local_inic {;}

| TK_PR_CONST TK_IDENTIFICADOR TK_IDENTIFICADOR {;}

| TK_PR_STATIC TK_PR_CONST tipo_primario TK_IDENTIFICADOR {;}

| TK_PR_STATIC TK_PR_CONST tipo_primario TK_IDENTIFICADOR var_local_inic {;}

| TK_PR_STATIC TK_PR_CONST TK_IDENTIFICADOR TK_IDENTIFICADOR {;}
;

var_local_inic:
  TK_OC_LE TK_IDENTIFICADOR
	{ 
        $$ = cria_nodo(var_local_inic,2,cria_folha($1),cria_folha($2)); 
		
        gera_codigo_identificador(pilha,$$->filhos[1]);
	}

| TK_OC_LE literal
	{ 
        $$ = cria_nodo(var_local_inic,2,cria_folha($1),cria_folha($2));
 
        gera_codigo_literal($$->filhos[1]);
	}
;


/*Atribuicao*/
atribuicao:
  TK_IDENTIFICADOR '=' expressao
	{
        $$ = cria_nodo(atribuicao,4,cria_folha($1), NULL, NULL,$3);

        inicializa_pilha(&pilha);
        //Escopo local não inicializado na pilha
        if(pilha->num_tabelas == 1){
            empilha(pilha);
	    printf("oi");	 
	}

        // Copia o valor do nodo expressao para o valor do nodo atribuicao          
        $$->valor = $3->valor;
	gera_codigo_atr(pilha, $$);
	}

| TK_IDENTIFICADOR '[' expressao ']' '=' expressao {;}
| TK_IDENTIFICADOR '$' TK_IDENTIFICADOR '=' expressao {;}
| TK_IDENTIFICADOR '[' expressao ']' '$' TK_IDENTIFICADOR '=' expressao {;}
;


///Entrada e Saida
entrada:
 TK_PR_INPUT expressao {;}
;

saida:
 TK_PR_OUTPUT expressao saida2 {;}
;

saida2:
 ',' expressao saida2 {;}

| ';' {;}
;


/// Retorno, Break, Continue, Case
retorno:
  TK_PR_RETURN expressao
	{
	$$ = cria_nodo(retorno,2,cria_folha($1), $2);
	}
;

break_t:	TK_PR_BREAK {;}
;

continue_t:	TK_PR_CONTINUE {;}
;

case_t:		TK_PR_CASE TK_LIT_INT ':' {;}
;


/// Chamada de Funcao
cham_func:
  TK_IDENTIFICADOR '(' cham_func_arg
	{
	$$ = cria_nodo(cham_func,1,cria_folha($1));
	adiciona_netos($$,$3);
	}
;

cham_func_arg:
  expressao cham_func_fim
	{
	$$ = cria_nodo(cham_func,1,$1);
	adiciona_netos($$,$2);
	}

| point cham_func_fim
	{
	$$ = cria_nodo(cham_func,1, cria_folha($1));
	adiciona_netos($$,$2);
	}

| cham_func_fim
	{
	$$ = cria_nodo(cham_func,0);
	adiciona_netos($$,$1);
	}
;

cham_func_fim:
  ',' cham_func_arg
	{
	$$ = cria_nodo(cham_func,0);
	adiciona_netos($$,$2);
	}

| ')'
	{
	$$ = cria_nodo(cham_func,0);
	}
;


///Comando Shift
com_shift:
TK_IDENTIFICADOR com_shift_opcoes {;}
;

com_shift_opcoes:
  TK_OC_SL com_shift_dados {;}
| TK_OC_SR com_shift_dados {;}
| '$' TK_IDENTIFICADOR com_shift_dir {;}
| '[' expressao ']' com_shift_dados2 {;}
;

com_shift_dados2:
  '$' TK_IDENTIFICADOR com_shift_dir {;}
| com_shift_dir {;}
;

com_shift_dir:
  TK_OC_SL com_shift_dados {;}
| TK_OC_SR com_shift_dados {;}
;

com_shift_dados:
  expressao {;}
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
	{ 
        $$ = cria_nodo(constr_cond,4,cria_folha($1),$3,cria_folha($5),$6); 
        adiciona_netos($$,$7);

	//E5:
        inicializa_pilha(&pilha);
        //Escopo local não inicializado na pilha
        if(pilha->num_tabelas == 1){
            empilha(pilha);
	    printf("oi");	 
	}
              
	gera_codigo_if($$);
	}
;

constr_cond_else:
  TK_PR_ELSE bloco_comandos
	{ 
        $$ = cria_nodo(constr_cond_else,2,cria_folha($1),$2);
        $$->code = $2->code;
	}

| %empty
	{ $$ = cria_nodo(constr_cond_else,0); }
;

constr_iter:
  TK_PR_FOREACH '(' TK_IDENTIFICADOR ':' lista_foreach ')' bloco_comandos {;}
| TK_PR_FOR '(' lista_for ':' expressao ':' lista_for ')' bloco_comandos {;}
| TK_PR_WHILE '(' expressao ')' TK_PR_DO bloco_comandos
	{
	$$ = cria_nodo(constr_while,4,cria_folha($1),$3,cria_folha($5),$6); 

	//E5:
        inicializa_pilha(&pilha);
        //Escopo local não inicializado na pilha
        if(pilha->num_tabelas == 1){
            empilha(pilha);
	    printf("oi");	 
	}

	gera_codigo_while($$);
	}

| TK_PR_DO bloco_comandos TK_PR_WHILE '(' expressao ')'
	{ 
        $$ = cria_nodo(constr_do,4,cria_folha($1),$2,cria_folha($3),$5); 

    	//E5:
        inicializa_pilha(&pilha);
        //Escopo local não inicializado na pilha
        if(pilha->num_tabelas == 1){
            empilha(pilha);
	    printf("oi");	 
	} 

	gera_codigo_do($$);
	}
;

lista_foreach:
  expressao {;}
| expressao ',' lista_foreach {;}
;

lista_for_comando_valido:
  var_local  {;}
| atribuicao {;} 
| break_t {;} 
| continue_t  {;}
;

lista_for:
  lista_for_comando_valido {;}
| lista_for ',' lista_for_comando_valido {;}
;

constr_sel:
  TK_PR_SWITCH '(' expressao ')' bloco_comandos {;}
;



/// Comandos com Pipes
com_pipes:
  cham_func pipes cham_func {;}
| com_pipes pipes cham_func {;}
;



/* Expressoes */

expressao:
  exp_literal	
    {       
        $$ = cria_nodo(exp_literal,0); adiciona_netos($$,$1); 
        $$->valor = $1->valor;
        $$->code = $1->code;
        $$->reg = $1->reg;
    }
  
| exp_identificador
    { 
        $$ = cria_nodo(exp_identificador,0); adiciona_netos($$,$1);
        $$->valor = $1->valor;
        $$->code = $1->code;
        $$->reg = $1->reg;
    }
    
| '(' expressao ')' 
    { 
        $$ = cria_nodo(exp_parenteses,0); adiciona_filho($$,$2);
        $$->valor = $2->valor;
        $$->code = $2->code;
        $$->reg = $2->reg;        
    }

| com_pipes {;}
| cham_func
    {
	$$ = $1;
    }

| expressao '?' expressao ':' expressao {;}
| expressao TK_OC_OR expressao
    { 
        $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3);  
        gera_codigo_or($$);          
    }

| expressao TK_OC_AND expressao
    { 
        $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); 
        gera_codigo_and($$);          
    }

| expressao '&' expressao {;}
| expressao '|' expressao {;}
| expressao TK_OC_LE expressao
    { 
        $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); 
        gera_codigo_cmp($$,"cmp_LE");    
    }
| expressao TK_OC_GE expressao
    { 
        $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); 
        gera_codigo_cmp($$,"cmp_GE");           
    }
| expressao TK_OC_EQ expressao
    { 
        $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); 
        gera_codigo_cmp($$,"cmp_EQ");           
    }
| expressao TK_OC_NE expressao
    { 
        $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); 
        gera_codigo_cmp($$,"cmp_NE");            
    }
| expressao '<' expressao
    { 
        $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); 
        gera_codigo_cmp($$,"cmp_LT");           
    }
| expressao '>' expressao
    { 
        $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); 
        gera_codigo_cmp($$,"cmp_GT");          
    }
| expressao '+' expressao	
    { 
        $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3);
        $$->valor = $1->valor + $3->valor;
        gera_codigo_arit($$,"add");
    }
| expressao '-' expressao	
    { 
        $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); 
        $$->valor = $1->valor - $3->valor;        
        gera_codigo_arit($$,"sub");       
    }
| expressao '*' expressao	
    { 
        $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); 
        $$->valor = $1->valor * $3->valor;        
        gera_codigo_arit($$,"mult");          
    }
| expressao '/' expressao	
    { 
        $$ = cria_nodo(exp_binaria,3, $1, cria_folha($2), $3); 
        $$->valor = $1->valor / $3->valor;                
        gera_codigo_arit($$,"div");          
    }
| expressao '%' expressao	{;}
| expressao '^' expressao	{;}
| '&' expressao %prec ENDERECO	{;}
| '*' expressao %prec PONTEIRO		{;}
| '!' expressao %prec NEG_LOGICA	{;}
| '+' expressao %prec PLUS_NEG_UNARIO	{;}
| '-' expressao %prec PLUS_NEG_UNARIO	{;}
;

exp_identificador:
  TK_IDENTIFICADOR  
	{ 
        $$ = cria_nodo(exp_identificador,3,cria_folha($1),NULL,NULL); 

        gera_codigo_identificador(pilha,$$->filhos[0]);
        $$->valor = $$->filhos[0]->valor;
        $$->code = $$->filhos[0]->code;
        $$->reg = $$->filhos[0]->reg;
	}

| TK_IDENTIFICADOR '[' expressao ']'  {;}
| TK_IDENTIFICADOR '$' TK_IDENTIFICADOR  {;}
| TK_IDENTIFICADOR '[' expressao ']' '$' TK_IDENTIFICADOR {;}
;

exp_literal:
  literal 
    { 
        $$ = cria_nodo(exp_literal,1,cria_folha($1));
        gera_codigo_literal($$->filhos[0]);
        $$->valor = $$->filhos[0]->valor;
        $$->code = $$->filhos[0]->code;        
        $$->reg = $$->filhos[0]->reg;        
    }
;

%%

/* Called by yyparse on error.  */
void yyerror (char const *s)
{
  fprintf (stderr, "linha %d coluna %ld: %s: token invalido: %s\n", get_line_number(), get_col_number()-strlen(yytext)+1, s, yytext);
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
