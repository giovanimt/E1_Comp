#include "arvore.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

typedef struct Arg_Func {
	char *chave;
	int tipo;
} Arg_func;

typedef struct Cmp_Usr {
	char *chave;
	int tipo;
	int encapsulamento;
} Cmp_Usr;

typedef struct Simbolo {
	char *chave;
	int linha;
	int coluna;
	int natureza;
	int tipo;
	int tamanho;
	int funcao; /// 0 nao 1 sim
	Arg_Func **Argumentos;
	int tipo_usuario; /// 0 nao 1 sim
	Cmp_Usr **Campos;
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

Tabela cria_tabela();
Pilha_Tabelas cria_pilha();
void add_simbolo(Tabela *t, NodoArvore *nodo);
void empilha(Pilha_Tabelas *pilha, Tabela *t);
void desempilha(Pilha_Tabelas *pilha);

