#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include "codigo.h"

int num_rotulos = 0;
int num_regs = 0;

//Função que gera o nome de um rótulo
char* gera_rotulo(){
	char *nome_rotulo = (char*)malloc(20);
	sprintf(nome_rotulo, "L%i", num_rotulos);
	num_rotulos++;		
	return nome_rotulo;
}

//Função que gera o nome de um registrador
char* gera_registrador(){
	char *nome_reg = (char*)malloc(20);
	sprintf(nome_reg, "r%i", num_regs);
	num_regs++;		
	return nome_reg;
}

//Gera codigo de declaracao de var_global
void gera_codigo_vg(NodoArvore *n){
    gera_codigo_init(n);


}

//Inicializa atributo code de no da AST
void gera_codigo_init(NodoArvore *n){
    n->code.prev = NULL;
    n->code.iloc.opcode = NULL;
    n->code.iloc.op1 = NULL;
    n->code.iloc.op2 = NULL;
    n->code.iloc.op3 = NULL;
}
