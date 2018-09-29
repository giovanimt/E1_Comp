#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define LITERAL		10
#define BOOL		11
#define INTEIRO		12
#define FLOAT		13
#define CHAR		14
#define STRING		15

#define NAO_LITERAL	20
#define ESPECIAL	21
#define P_RESERVADA	22
#define OPERADOR	23
#define IDENT		24

union Literal {
	int tipo_bool;
	int tipo_int;
	float tipo_float;
	char tipo_char;
	char* tipo_string;
}

struct nodo_basico {
	union Literal valor
	int tipo_token
	int tipo_lit
	int coluna
	int linha
}

typedef struct nodo_arvore {
	struct nodo_basico* token;
	int numero_filhos
	struct nodo_arvore **filhos
} Nodo_arvore;

Nodo_arvore* novo_nodo(struct nodo_basico* token);

void adiciona_filho(Nodo_arvore *pai, Nodo_arvore *filho);

void descompila (void *nodo_arvore);

void libera (void *nodo_arvore);
