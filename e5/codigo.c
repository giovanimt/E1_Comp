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
/*    if(n->filhos[5]){
        switch(n->filhos[5]->nodo.valor_lexico.type) {

        // Vinicius: Comentando, pois não compila (não pode ter declaração dentro dos case)
		//se for inteiro
		case(INTEIRO):
			int des_vl = 0; //TODO:descobrir deslocamento da variavel declarada em relacao a rfp
			char* reg_temp = gera_registrador();
			printf("loadI %d => %s\n",n->filho[5]->nodo.valor_lexico.val.int_val, reg_temp);
			printf("storeAI %s => rfp, %d\n", reg_temp, des_vl);
			break;

		//se for TK_IDENTIFICADOR
		default:
		    // Vinicius: Comentando, pois não compila e não entendi (não pode ter declaração dentro dos case)
			//int des_ident = 0; //TODO:descobrir deslocamento da variavel de TK_IDENTIFICADOR em relacao a rfp
			//int des_vl = 0; //TODO:descobrir deslocamento da variavel declarada em relacao a rfp

            // Vinicius: Comentando, pois não compila e não entendi o if(true)
			if(true){//TODO: fazer if para descobrir se TK_IDENTIFICADOR eh vl ou vg, se for vg:
				char* reg_temp2 = gera_registrador();
				printf("loadAI rbss,%d => %s\n", des_ident, reg_temp2);
				printf("storeAI %s => rfp, %d\n", reg_temp2, des_vl);
			}else{//se TK_IDENT for vl:
				char* reg_temp2 = gera_registrador();
				printf("loadAI rfp,%d => %s\n", des_ident, reg_temp2);
				printf("storeAI %s => rfp, %d\n", reg_temp2, des_vl);
			break; 
        }
    }*/
}


//Gera codigo de atribuicao TK_IDENTIFICADOR '=' expressao
void gera_codigo_atr(Pilha_Tabelas *pilha, NodoArvore *n){
	printf("Atribuicao\n");
	char *reg_var = gera_registrador();
	char *reg_aux_e1 = gera_registrador();
	char *reg_aux_e2 = gera_registrador();
	char *op_bin;

	//ATE O MOMENTO: CASO IDENT1(VG) = e1(VG) op_bin e2(VG):

	//Pega o nome da variavel que sera atribuida
	char *nome_var = n->filhos[0]->nodo.valor_lexico.val.string_val;
	//E procura o simbolo na pilha
	Simbolo *s = search_sim_stack(pilha, nome_var);
	if(s){	//se o simbolo estava na pilha
		//salva o local da variavel na no reg_var
		printf("addI rbss, %d => %s\n", s->deslocamento, reg_var);
	}


	//e1:
	if(n->filhos[3]->filhos[0]->filhos[0]->nodo.valor_lexico.type == IDENT){	//se o primeiro filho de expressao for IDENT
		//Pega o nome
		char *nome_e1 = n->filhos[3]->filhos[0]->filhos[0]->nodo.valor_lexico.val.string_val;
		//E procura o simbolo na pilha
		Simbolo *s_e1 = search_sim_stack(pilha, nome_e1);
		if(s_e1){//se o simbolo estava na pilha
			//carrega seu conteudo em reg_aux_e1
			printf("loadAI rbss, %d => %s\n", s_e1->deslocamento, reg_aux_e1);
		}
	}else{//se o primeiro filho de expressao for INT
		//Pega seu valor
		int val_e1 = n->filhos[3]->filhos[0]->filhos[0]->nodo.valor_lexico.val.int_val;
		//salva no registrador reg_aux_e1
		printf("loadI %d => %s\n", val_e1, reg_aux_e1);
	}


	//operador binario
	if(!strcmp(n->filhos[3]->filhos[1]->nodo.valor_lexico.val.string_val, "+")){
		op_bin = "add";
	}else if(!strcmp(n->filhos[3]->filhos[1]->nodo.valor_lexico.val.string_val, "-")){
		op_bin = "sub";
	}else if(!strcmp(n->filhos[3]->filhos[1]->nodo.valor_lexico.val.string_val, "/")){
		op_bin = "div";
	}else if(!strcmp(n->filhos[3]->filhos[1]->nodo.valor_lexico.val.string_val, "-")){
		op_bin = "mult";
	}


	//e2:
	if(n->filhos[3]->filhos[2]->filhos[0]->nodo.valor_lexico.type == IDENT){	//se o terceiro filho (e2) de expressao for IDENT
		//Pega o nome
		char *nome_e2 = n->filhos[3]->filhos[2]->filhos[0]->nodo.valor_lexico.val.string_val;
		//E procura o simbolo na pilha
		Simbolo *s_e2 = search_sim_stack(pilha, nome_e2);
		if(s_e2){//se o simbolo estava na pilha
			//carrega seu conteudo em reg_aux_e2
			printf("loadAI rbss, %d => %s\n", s_e2->deslocamento, reg_aux_e2);
			//faz a op_bin com reg_aux_e1 e coloca em reg_aux_e1
			printf("%s %s, %s => %s\n", op_bin, reg_aux_e1, reg_aux_e2, reg_aux_e1);
		}
	}else{//se o terceiro filho (e2) de expressao for INT
		//Pega seu valor
		int val_e2 = n->filhos[3]->filhos[2]->filhos[0]->nodo.valor_lexico.val.int_val;
		//faz a op_bin com reg_aux_e1 e coloca em reg_aux_e1
		printf("%sI %s, %d => %s\n", op_bin, reg_aux_e1, val_e2, reg_aux_e1);
	}



	//salva na variavel atribuida
	printf("store %s => %s\n", reg_aux_e1, reg_var);




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
