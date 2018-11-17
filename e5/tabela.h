/*
Giovani Tirello 252741
Vinicius Castro 193026
*/

/*
E4:
1: Ver TODOs de Novo tipo, var globais e var locais e Funcoes
   Ver onde colocar certo os empilha() e desempilha()
   OBS: ja foi colocado um empilha em add_func
2: Falta ver se foi declarado quando usado
3 a 7 nao implementados
*/

#ifndef __tabela__
#define __tabela__

#ifndef __arvore__
#include "arvore.h"
#endif
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

//Arg_Func = *chave tipo eh_cons
//Cmp_Usr = *chave tipo encapsulamento

typedef struct Simbolo {
	char *chave;
	int line;
	int col;
	int natureza;
	int tipo;
	int tamanho;
	int eh_static; /// 0 nao 1 sim
	int eh_cons; /// 0 nao 1 sim
	int var_ou_vet; /// 0 n/a 1 variavel 2 vetor
	int encapsulamento; //0 n/a 1 protected 2 private 3 public
	struct Simbolo **Argumentos; //argumentos caso for uma funcao
	int num_argumentos;
	struct Simbolo **Campos; //campos do tipo usuario caso tipo==USR
	int num_campos;
	///TODO:demais informações do valor do token pelo yylval (veja E3)
	int deslocamento; // E5: deslocamento em bytes em relaçãõ ao endereço base da pilha/seg dados
	int valor;
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
void inicializa_pilha(Pilha_Tabelas** pilha);
void empilha(Pilha_Tabelas *pilha);
void desempilha(Pilha_Tabelas *pilha);

//Funcoes simbolos
int declarado(Pilha_Tabelas *pilha, char *chave);
int declarado_tabela(Pilha_Tabelas *pilha, NodoArvore *n1, NodoArvore *n2);
void define_tipo(Simbolo *s, NodoArvore*n);
void tamanho_usr(Pilha_Tabelas *pilha, Simbolo *s, NodoArvore*n);
void tamanho_vetor(Simbolo *s, NodoArvore*n);

//Funcao Novo Tipo
void add_nt(Pilha_Tabelas *pilha, NodoArvore *n);

//Funcao Variavel Global
void add_vg(Pilha_Tabelas *pilha, NodoArvore *n);

//Funcao Funcao
void add_func(Pilha_Tabelas *pilha, NodoArvore *n);

//Funcao Var Local
void add_vl(Pilha_Tabelas *pilha, NodoArvore *n);

//Outros
int declarado_atr(Pilha_Tabelas *pilha, NodoArvore *n);
int eh_vetor(Pilha_Tabelas *pilha, NodoArvore *n);
int existe_campo(Pilha_Tabelas *pilha, NodoArvore *n1, NodoArvore *n2);
//analisa se eh usr
int eh_usr(Pilha_Tabelas *pilha, NodoArvore *n);
//analisa se foram passados argumentos suficientes
int analisa_args(Pilha_Tabelas *pilha, NodoArvore *n);

//E5: procura simbolos e os retorna
Simbolo* busca_simbolo_local(Pilha_Tabelas *pilha, char *chave);
Simbolo* busca_simbolo_global(Pilha_Tabelas *pilha, char *chave);


#endif
