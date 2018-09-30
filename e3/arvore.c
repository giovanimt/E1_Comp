#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "arvore.h"

Nodo_arvore* novo_nodo(struct inf_nodo* token){
	Nodo_arvore* nodo = malloc(sizeof(Nodo_arvore));
	nodo->numero_filhos = 0;
	nodo->filhos = (Nodo_arvore**) malloc(sizeof(Nodo_arvore**));
	nodo->token = token;
	return nodo;
}

void adiciona_filho(Nodo_arvore *pai, Nodo_arvore *filho){
	pai->filhos = (Nodo_arvore**) realloc(pai->filhos, (pai->numero_filhos + 1) * sizeof(Nodo_arvore**));
	pai->filhos[pai->numero_filhos] = filho;
	pai->numero_filhos++;
}

void imprime(struct inf_nodo* token){
	switch(token->tipo_token){
		case BOOL:
			if(token->valor_lit.bool_val == 1){
				printf("%s ", "true");
			}
			else{
				printf("%s ", "false");
			}
			break;
		case INTEIRO:
			printf("%d ", token->valor_lit.int_val);
			break;
		case FLOAT:
			printf("%f ", token->valor_lit.float_val);
			break;
		case CHAR:
			printf("%c ", token->valor_lit.char_val);
			break;
		case STRING:
			printf("%s ", token->valor_lit.string_val);
			break;
		case ESPECIAL:
			if(token->valor_nlit == '{' || token->valor_nlit == '}' || token->valor_nlit == ';'){
				printf("%c \n", token->valor_nlit);
			}
			else{
				printf("%c ", token->valor_nlit);
			}
			break;
		case RESERVADA:
			printf("%s ", token->valor_nlit);
			break;
		case OPERADOR_COMP:
			printf("%s ", token->valor_nlit);
			break;
		case IDENT:
			printf("%s ", token->valor_nlit);
			break;
	}
}

void descompila (void *nodo_arvore);

void libera (void *nodo_arvore);
