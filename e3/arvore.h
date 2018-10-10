#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

union Literal {
	int bool_val;
	int int_val;
	float float_val;
	char char_val;
	char* string_val;
};

enum ValorLexicoType {
	BOOL,
	INTEIRO,
	FLOAT,
	CHAR,
	STRING,
	ESPECIAL,
	RESERVADA,
	OPERADOR_COMP,
	IDENT,
	TIPO_PRIMARIO,
	ENCAPSULAMENTO,
	MODIFICADOR
};

struct valor_lexico {
	int line,col;
	enum ValorLexicoType type;
	union Literal val;
};

enum NaoTerminalType {
	programa,
	var_global,
	novo_tipo,
	novo_tipo_campo,
	novo_tipo_lista_campos,
	funcao,
	cabecalho,
	lista_parametros,
	parametros,
	parametro,
	bloco_comandos,
	sequencia_comandos_simples,
	comando_simples,
	var_local,
	var_local_inic,    
    	atribuicao,
	constr_sel,
	constr_cond,
	constr_cond_else,
	constr_foreach,	
	lista_foreach,
	constr_for,
	lista_for,
	lista_for_comando_valido,

	constr_while,
	constr_do,
	contr_fluxo,
	lista,
	entrada,
	saida,
	retorno,
	break_t,
	continue_t,
	case_t,
	cham_func,
	com_shift,
	com_pipes,	
	expressao,
	exp_identificador,
	exp_literal,
	exp_parenteses
};

union Nodo {
	struct valor_lexico valor_lexico;
	enum NaoTerminalType type;    
};

typedef struct NodoArvore {
	union Nodo nodo;
	int type; // 0 valor_lexico, 1 nao_terminal
	int num_filhos;
	struct NodoArvore **filhos;
} NodoArvore;

NodoArvore* cria_nodo(enum NaoTerminalType type, int num_filhos, ...);
NodoArvore* cria_folha(struct valor_lexico valor_lexico);
void adiciona_filho(NodoArvore *pai, NodoArvore *filho);
void adiciona_netos(NodoArvore *avo, NodoArvore *pai);
