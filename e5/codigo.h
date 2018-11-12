/*
Giovani Tirello 252741
Vinicius Castro 193026
*/

#ifndef __codigo__
#define __codigo__
#include "arvore.h"
#include "tabela.h"

//Função que gera o nome de um rótulo
char* gera_rotulo();
//Função que gera o nome de um registrador
char* gera_registrador();
//Inicializa registradores iniciais e pula para L0
void gera_codigo_inicio_programa(int rfp, int rsp, int rbss);
//Gera codigo de declaracao de var_global
void gera_codigo_vg(NodoArvore *n);
//Gera codigo de declaracao de var_local
void gera_codigo_vl(Pilha_Tabelas *pilha, NodoArvore *n);
//Gera codigo para atribuicao
void gera_codigo_atr(Pilha_Tabelas *pilha, NodoArvore *n);
//Inicializa atributo code de no da AST
void gera_codigo_init(NodoArvore *n);

#endif
