#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include "arvore.h"

NodoArvore* cria_folha(struct valor_lexico valor_lexico){
	NodoArvore *folha = (NodoArvore*)malloc(sizeof(NodoArvore));
	folha->nodo.valor_lexico = valor_lexico;
	folha->type = 0;
	folha->num_filhos = 0;
	folha->filhos = NULL;
	
	return folha;	
}

NodoArvore* cria_nodo(enum NaoTerminalType type, int num_filhos, ...){
	int i;
	va_list args;
	va_start(args, num_filhos);

	NodoArvore *nodo_arvore = (NodoArvore*)malloc(sizeof(NodoArvore));
	nodo_arvore->nodo.type = type;
	nodo_arvore->type = 1;
	nodo_arvore->num_filhos = num_filhos;
	nodo_arvore->filhos = NULL;

	if(num_filhos > 0) {
		nodo_arvore->filhos = (NodoArvore**)malloc(sizeof(NodoArvore*)*num_filhos);

		for(i=0;i<num_filhos;i++)
			nodo_arvore->filhos[i] = va_arg(args,NodoArvore*);
	}

	va_end(args);
	return nodo_arvore;
}

void adiciona_filho(NodoArvore *pai, NodoArvore *filho){
	pai->filhos = (NodoArvore**) realloc(pai->filhos, (pai->num_filhos + 1) * sizeof(NodoArvore**));
	pai->filhos[pai->num_filhos] = filho;
	pai->num_filhos++;
}

void adiciona_netos(NodoArvore *avo, NodoArvore *pai){
    int i;
    for(i=0; i<pai->num_filhos; i++)
        adiciona_filho(avo,pai->filhos[i]);
}
