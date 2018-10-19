/*
Giovani Tirello 252741
Vinicius Castro 193026
*/

#include "tabela.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

#define NATUREZA_LITERAL_INT        1
#define NATUREZA_LITERAL_FLOAT      2
#define NATUREZA_LITERAL_CHAR       3
#define NATUREZA_LITERAL_STRING     4
#define NATUREZA_LITERAL_BOOL       5
#define NATUREZA_IDENTIFICADOR      6


//Funcoes tabela
Tabela* cria_tabela(){
	Tabela *t;
	t->simbolos = NULL;
	t->num_simbolos = 0;
	return t;
}

void add_simbolo_tabela(Simbolo *s, Tabela *t){
	t->simbolos = (Simbolo**) realloc(t->simbolos, (t->num_simbolos + 1) * sizeof(Simbolo**));
	t->simbolos[t->num_simbolos]= s;
	t->num_simbolos++;
}


//Funcoes Pilha
Pilha_Tabelas* inicializa_pilha(){
	Pilha_Tabelas *pilha = (Pilha_Tabelas*)malloc(sizeof(Pilha_Tabelas));
	pilha->tabelas = NULL;
	pilha->num_tabelas = 0;
	//Inicializa ja com a tabela "global":
	empilha(pilha);
	return pilha;
}

void empilha(Pilha_Tabelas *pilha){
	Tabela *t = cria_tabela();
	pilha->tabelas = (Tabela**) realloc(pilha->tabelas, (pilha->num_tabelas + 1) * sizeof(Tabela**));
	pilha->tabelas[pilha->num_tabelas] = t;
	pilha->num_tabelas++;
}

void desempilha(Pilha_Tabelas *pilha){
	if(pilha->num_tabelas !=0){
		free(pilha->tabelas[pilha->num_tabelas - 1]);
		pilha->tabelas = (Tabela**) realloc(pilha->tabelas, (pilha->num_tabelas - 1) * sizeof(Tabela**));
		pilha->num_tabelas--;
	}
}


//Funcoes simbolos
int declarado(NodoArvore *n){
	//TODO: avalia se o simbolo ja foi declarado 0 nao 1 sim
	return -1;
}

void define_tipo(Simbolo *s, NodoArvore*n){
	switch(n->tipo) {
		case(TIPO_INT):
			s->tipo = TIPO_INT;
			s->tamanho = 4;
			break;

		case(TIPO_FLOAT):
			s->tipo = TIPO_FLOAT;
			s->tamanho = 8;
			break;

		case(TIPO_CHAR):
			s->tipo = TIPO_CHAR;
			s->tamanho = 1;
			break;

		case(TIPO_BOOL):
			s->tipo = TIPO_BOOL;
			s->tamanho = 1;
			break;

		case(TIPO_STRING):
			s->tipo = TIPO_STRING;
			s->tamanho = strlen(n->nodo.valor_lexico.val.string_val);
			break;

		case(TIPO_USR):
			s->tipo = TIPO_USR;
			break;
	}
}

void tamanho_usr(Simbolo *s, NodoArvore*n){
//TODO: soma o tamanho dos campos e coloca os em **Campos
}

void tamanho_vetor(Simbolo *s, NodoArvore*n){
	s->tamanho = s->tamanho * n->nodo.valor_lexico.val.int_val;
}


//Funcao Novo Tipo
void add_nt(Pilha_Tabelas *pilha, NodoArvore *n){
	//inicializa simbolo
	Simbolo *nt = (Simbolo*)malloc(sizeof(Simbolo));

	//nao eh cons nem funcao nem static
	nt->eh_cons = 0;
	nt->Argumentos = NULL;
	nt->eh_static = 0;

	//eh tipo usuario
	nt->tipo = TIPO_USR;

	//define natureza TODO:nao entendi muito o sentido da natureza entao nao tenho certeza
	nt->natureza = NATUREZA_IDENTIFICADOR;

	//pega o segundo filho do nodo...
	NodoArvore *f2 = (NodoArvore*)n->filhos[0];
	//...para definir a *chave...
	nt->chave = f2->nodo.valor_lexico.val.string_val; //TODO:pode causar ponteiro pendente?
	//... e para definir a linha/col TODO:foi passado pros nodos folhas as linhas e colunas na E3?
	nt->line = f2->nodo.valor_lexico.line;
	nt->col = f2->nodo.valor_lexico.col;
	
	//adiciona o novo tipo na tabela
	add_simbolo_tabela(nt, pilha->tabelas[pilha->num_tabelas - 1]);

	//pega o terceiro filho do nodo onde estao os campos
	NodoArvore *f3 = (NodoArvore*)n->filhos[0];
		///TODO: para cada campo... (defenir *chave, tipo encapsulamento, e colocar no **Campos e na tabela) (ir somando o tamanho de cada tipo para definir o tamanho total do tipo usuario)
		for(int i=0; i<f3->num_filhos; i++){
			f3->filhos[i];
		}
}


//Funcao Variavel Global
void add_vg(Pilha_Tabelas *pilha, NodoArvore *n){
	//inicializa simbolo
	Simbolo *vg = (Simbolo*)malloc(sizeof(Simbolo));

	//nao eh cons nem funcao
	vg->eh_cons = 0;
	vg->Argumentos = NULL;

	//define natureza TODO:nao entendi muito o sentido da natureza entao nao tenho certeza
	vg->natureza = NATUREZA_IDENTIFICADOR;

	//pega o primeiro filho do nodo...
	NodoArvore *f1 = (NodoArvore*)n->filhos[0];
	//...para definir a *chave...
	vg->chave = f1->nodo.valor_lexico.val.string_val; //TODO:pode causar ponteiro pendente?
	//... e para definir a linha/col TODO:foi passado pros nodos folhas as linhas e colunas na E3?
	vg->line = f1->nodo.valor_lexico.line;
	vg->col = f1->nodo.valor_lexico.col;
	
	//pega o segundo filho do nodo para definir se eh static
	if(n->filhos[1]==NULL){
		vg->eh_static = 0;
	}else{
		vg->eh_static = 1;
	}

	//pega o quarto filho do nodo...
	NodoArvore *f4 = (NodoArvore*)n->filhos[3];
	//...para definir o tipo e tamanho
	define_tipo(vg,f4);

	//se for tipo usuario eh necessario ajustar o tamanho e **Campos
	if(vg->tipo == TIPO_USR){
		tamanho_usr(vg,f4);
	}else{
		vg->Campos = NULL;
	}

	//pega o terceiro filho do nodo pra ver se eh vetor e ajustar o tamanho
	if(n->filhos[2]!=NULL){
		NodoArvore *f3 = (NodoArvore*)n->filhos[2];
		tamanho_vetor(vg,f3);
	}
	
	add_simbolo_tabela(vg, pilha->tabelas[pilha->num_tabelas - 1]);
}


//TODO: Funcao Funcao (hahaha)
//void add_func(Pilha_Tabelas *pilha, NodoArvore *n){}
