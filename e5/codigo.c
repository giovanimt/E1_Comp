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

//Inicializa registradores iniciais e pula para L0
void gera_codigo_inicio_programa(int rfp, int rsp, int rbss){
	printf("loadI %d => rfp\n", rfp);
	printf("loadI %d => rsp\n", rsp);
	printf("loadI %d => rbss\n", rbss);
}

//Gera codigo de declaracao de var_global
void gera_codigo_vg(NodoArvore *n){
    printf("nop\n");
}

//Gera codigo de declaracao de var_local
void gera_codigo_vl(NodoArvore *n){
    printf("addI rsp, 4 => rsp\n");
    //Se existe atribuicao juntamente com a declaracao:
    if(n->filhos[5]){
        switch(n->filhos[5]->nodo.valor_lexico.type) {

        // Vinicius: Comentando, pois não compila (não pode ter declaração dentro dos case)
		//se for inteiro
		/*case(INTEIRO):
			int des_vl = 0; //TODO:descobrir deslocamento da variavel declarada em relacao a rfp
			char* reg_temp = gera_registrador();
			printf("loadI %d => %s\n",n->filho[5]->nodo.valor_lexico.val.int_val, reg_temp);
			printf("storeAI %s => rfp, %d\n", reg_temp, des_vl);
			break; */

		//se for TK_IDENTIFICADOR
		default:
		    // Vinicius: Comentando, pois não compila e não entendi (não pode ter declaração dentro dos case)
			//int des_ident = 0; //TODO:descobrir deslocamento da variavel de TK_IDENTIFICADOR em relacao a rfp
			//int des_vl = 0; //TODO:descobrir deslocamento da variavel declarada em relacao a rfp

            // Vinicius: Comentando, pois não compila e não entendi o if(true)
			/*if(true){//TODO: fazer if para descobrir se TK_IDENTIFICADOR eh vl ou vg, se for vg:
				char* reg_temp2 = gera_registrador();
				printf("loadAI rbss,%d => %s\n", des_ident, reg_temp2);
				printf("storeAI %s => rfp, %d\n", reg_temp2, des_vl);
			}else{//se TK_IDENT for vl:
				char* reg_temp2 = gera_registrador();
				printf("loadAI rfp,%d => %s\n", des_ident, reg_temp2);
				printf("storeAI %s => rfp, %d\n", reg_temp2, des_vl); */
			break; 
        }
    }
}


//Gera codigo de atribuicao TK_IDENTIFICADOR '=' expressao
void gera_codigo_atr(NodoArvore *n){
	printf("nop\n");
	/*TODO: para os casos:
	exp_literal
	exp_identificador

	expressao TK_OC_OR expressao
	expressao TK_OC_AND expressao
	expressao TK_OC_LE expressao
	expressao TK_OC_GE expressao
	expressao TK_OC_EQ expressao
	expressao TK_OC_NE expressao
	expressao '<' expressao
	expressao '>' expressao

	expressao '+' expressao
	expressao '-' expressao
	expressao '*' expressao
	expressao '/' expressao
	*/
}

void gera_codigo_if(NodoArvore *n){
	printf("nop\n");
}

void gera_codigo_while(NodoArvore *n){
	printf("nop\n");
}

void gera_codigo_do(NodoArvore *n){
	printf("nop\n");
}


//Inicializa atributo code de no da AST
void gera_codigo_init(NodoArvore *n){
    n->code->prev = NULL;
    n->code->iloc.opcode = NULL;
    n->code->iloc.op1 = NULL;
    n->code->iloc.op2 = NULL;
    n->code->iloc.op3 = NULL;
}
