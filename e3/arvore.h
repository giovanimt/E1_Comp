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

struct var_global {
	struct valor_lexico *id;
	struct valor_lexico *tipo;
	struct valor_lexico *tam_vetor;
	struct valor_lexico *modificador;	
};

union NaoTerminal {
	struct var_global var_global;
};

union Nodo {
	struct valor_lexico valor_lexico;
	union NaoTerminal nao_terminal;    
};

typedef struct NodoArvore {
	union Nodo nodo;
	int type; // 0 valor_lexico, 1 nao_terminal
	int num_filhos;
	struct NodoArvore **filhos;
} NodoArvore;

NodoArvore* cria_nodo(union NaoTerminal nao_terminal, int num_filhos, ...);
NodoArvore* cria_folha(struct valor_lexico valor_lexico);

//NodoArvore* novo_nodo(struct inf_nodo* token);
//void adiciona_filho(NodoArvore *pai, NodoArvore *filho);
//void imprime(struct inf_nodo* token);

void descompila (void *NodoArvore);
void libera (void *NodoArvore);
