#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define BOOL		1
#define INTEIRO		2
#define FLOAT		3
#define CHAR		4
#define STRING		5
#define ESPECIAL	6
#define RESERVADA	7
#define OPERADOR_COMP	8
#define IDENT		9

union Literal {
	int bool_val;
	int int_val;
	float float_val;
	char char_val;
	char* string_val;
};

struct inf_nodo {
	union Literal valor_lit;
	int tipo_token;
	int coluna;
	int linha;
	char* valor_nlit
};

typedef struct nodo_arvore {
	struct inf_nodo* token;
	int numero_filhos;
	struct nodo_arvore **filhos;
} Nodo_arvore;

Nodo_arvore* novo_nodo(struct inf_nodo* token);

void adiciona_filho(Nodo_arvore *pai, Nodo_arvore *filho);

void imprime(struct inf_nodo* token);

void descompila (void *nodo_arvore);

void libera (void *nodo_arvore);
