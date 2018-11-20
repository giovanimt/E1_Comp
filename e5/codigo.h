/*
Giovani Tirello 252741
Vinicius Castro 193026
*/

#ifndef __codigo__
#define __codigo__
#include "arvore.h"
#include "tabela.h"


void imprime_codigo(NodoArvore *arvore);
//Função que gera o nome de um rótulo
char* gera_rotulo();
//Função que gera o nome de um registrador
char* gera_registrador();
//Gera codigo para incrementar topo da pilha
void gera_codigo_rsp(NodoArvore *n);
//Gera codigo de declaracao de var_local
void gera_codigo_vl(Pilha_Tabelas *pilha, NodoArvore *n);
//Gera codigo para atribuicao
void gera_codigo_atr(Pilha_Tabelas *pilha, NodoArvore *n);
//Gera codigo para exp aritmeticas
void gera_codigo_arit(NodoArvore *n, char *op);
//
void gera_codigo_cmp(NodoArvore *n,char *op);
//
void gera_codigo_literal(NodoArvore *n);
//
void gera_codigo_identificador(Pilha_Tabelas *pilha, NodoArvore *n);

void gera_codigo_if(Pilha_Tabelas *pilha, NodoArvore *n);

void gera_codigo_while(Pilha_Tabelas *pilha, NodoArvore *n);

void gera_codigo_do(Pilha_Tabelas *pilha, NodoArvore *n);
//Inicializa atributo code de no da AST
void iloc_list_init(NodoArvore *n);
//Apenda operacao iloc em uma codigo (iloc_list)
void iloc_list_append_op(struct iloc_list *code, ILOC *op);
//Apenda o codigo do no origem da AST no codigo do no destino
void iloc_list_append_code(NodoArvore *origem, NodoArvore *destino);
//Cria uma ILOC op
ILOC* iloc_create_op(char *label, char *opcode, char *op1, char *op2, char *op3, char *op4);
//
void patch(struct patch_list *plist, char *label);
//
void patch_list_append(struct patch_list *plist, char **label);

#endif
