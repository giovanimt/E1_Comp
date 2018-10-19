/*
Giovani Tirello 252741
Vinicius Castro 193026
*/

/*
E4: 1 e 2 parcialmente implementados
	Ver TODOs de Novo tipo e var globais
	Falta Funcoes e var locais inteiras
3 a 7 nao implementados
*/

#include "arvore.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

typedef struct Arg_Func {
	char *chave;
	int tipo;
} Arg_Func;

typedef struct Cmp_Usr {
	char *chave;
	int tipo;
	int encapsulamento;
} Cmp_Usr;

typedef struct Simbolo {
	char *chave;
	int line;
	int col;
	int natureza;
	int tipo;
	int tamanho;
	int eh_static; /// 0 nao 1 sim
	int eh_cons; /// 0 nao 1 sim
	Arg_Func **Argumentos; //argumentos caso for uma funcao
	Cmp_Usr **Campos; //campos do tipo usuario caso tipo==USR
	///TODO:demais informações do valor do token pelo yylval (veja E3)
} Simbolo;

typedef struct Tabela {
	int num_simbolos;
	Simbolo **simbolos;
} Tabela;

///Várias tabelas de símbolos podem co-existir, uma para cada escopo:
typedef struct Pilha_Tabelas {
	int num_tabelas;
	Tabela **tabelas;
} Pilha_Tabelas;

//Funcoes tabela
Tabela* cria_tabela();
void add_simbolo_tabela(Simbolo *s, Tabela *t);

//Funcoes Pilha
Pilha_Tabelas* inicializa_pilha();
void empilha(Pilha_Tabelas *pilha);
void desempilha(Pilha_Tabelas *pilha);

//Funcoes simbolos
int declarado(NodoArvore *n);
void define_tipo(Simbolo *s, NodoArvore*n);
void tamanho_usr(Simbolo *s, NodoArvore*n);
void tamanho_vetor(Simbolo *s, NodoArvore*n);

//Funcao Novo Tipo
void add_nt(Pilha_Tabelas *pilha, NodoArvore *n);

//Funcao Variavel Global
void add_vg(Pilha_Tabelas *pilha, NodoArvore *n);

//Funcao Funcao (hahaha)
//void add_func(Pilha_Tabelas *pilha, NodoArvore *n);

