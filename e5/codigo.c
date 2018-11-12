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

//Gera codigo de declaracao de var_local
void gera_codigo_vl(Pilha_Tabelas *pilha, NodoArvore *n){
    printf("\nvl\n");
    char *desl_vl = gera_registrador();
    char *vg_ou_vl;

    //Salva deslocamento da vl em des_vl
    printf("load rsp => %s\n", desl_vl);
    //Altera o topo da pilha
    printf("addI rsp, 4 => rsp\n");

    //Se existe atribuicao juntamente com a declaracao:
    if(n->filhos[4]){
	//se a atribuicao for um INT
        if(n->filhos[5]->nodo.valor_lexico.type == INTEIRO) {
		char* reg_temp = gera_registrador();
		//Carrega o valor de INT no reg_temp
		printf("loadI %d => %s\n",n->filhos[5]->nodo.valor_lexico.val.int_val, reg_temp);
		//Salva na vl
		printf("store %s => %s\n", reg_temp, desl_vl);
	}else{ //se for TK_IDENTIFICADOR
		//pega seu nome
		char *nome_var = n->filhos[5]->nodo.valor_lexico.val.string_val;
		//procura o simbolo na ultima tabela
		Simbolo *s = search_sim_table(pilha, nome_var);
		vg_ou_vl = "rfp";
		//se nao achou eh VG
		if(s==NULL){
			s = search_sim_stack(pilha, nome_var);
			vg_ou_vl = "rbss";
		}
		char* reg_temp2 = gera_registrador();
		//carrega o valor do IDENT
		printf("loadAI %s, %d => %s\n", vg_ou_vl, s->deslocamento, reg_temp2);
		//salva na VL
		printf("store %s => %s\n", reg_temp2, desl_vl);
	}
    }
}


//Gera codigo de atribuicao TK_IDENTIFICADOR '=' expressao
void gera_codigo_atr(Pilha_Tabelas *pilha, NodoArvore *n){
    // Inicializa atributo code da AST
    //iloc_list_init(n);

    // Apendar o codigo da expressao ao codigo da atribuicao (nova funcao para apendar o codigo)
	//printf("%d\n", n->filhos[3]->filhos[0]->valor);
	//printf("%d", n->filhos[3]->filhos[0]->valor);
	//iloc_list_append_code(NodoArvore *origem, NodoArvore *destino);
    
    // Recupera simbolo da pilha e calcula deslocamentos
	char *reg_var = gera_registrador();
	char *nome_var = n->filhos[0]->nodo.valor_lexico.val.string_val;
	Simbolo *s = search_sim_table(pilha, nome_var);
	char* vg_ou_vl = "rfp";
	//se nao achou eh VG
	if(s == NULL){
		s = search_sim_stack(pilha, nome_var);
		vg_ou_vl = "rbss";
	}
	if(s){	//se o simbolo estava na pilha
		//salva o local da variavel na no reg_var
		printf("addI %s, %d => %s\n", vg_ou_vl, s->deslocamento, reg_var);
	}
	s->valor = n->valor;
	

    
    // Gera código pro store e apenda no atributo code da AST
	printf("store reg_expressao_foi_carregada => %s\n", reg_var);


    /* Vinicius: a geracao de codigo da atribuicao assume que o código e o valor da expressao estão disponiveis no no da AST; é necessário apendar o código da  expressao no codigo da atribuicao e por ultimo gerar um store usando o valor ja disponivel no nodo da AST da  expressao (novo campo valor)
	//TODO: conferir se a equacao para achar o deslocamento em vg e vl no tabela.c estao corretos
	printf("\nAtribuicao\n");
	char *reg_var = gera_registrador();
	char *reg_aux_e1 = gera_registrador();
	char *reg_aux_e2 = gera_registrador();
	char *op_bin;
	char *vg_ou_vl;

	//ATE O MOMENTO: CASO IDENT1 = e1 op_bin e2:

	//Pega o nome da variavel que sera atribuida
	char *nome_var = n->filhos[0]->nodo.valor_lexico.val.string_val;
	//E procura o simbolo na ultima tabela
	Simbolo *s = search_sim_table(pilha, nome_var);
	vg_ou_vl = "rfp";
	//se nao achou eh VG
	if(s == NULL){
		s = search_sim_stack(pilha, nome_var);
		vg_ou_vl = "rbss";
	}
	if(s){	//se o simbolo estava na pilha
		//salva o local da variavel na no reg_var
		printf("addI %s, %d => %s\n", vg_ou_vl, s->deslocamento, reg_var);
	}


	//e1:
	if(n->filhos[3]->filhos[0]->filhos[0]->nodo.valor_lexico.type == IDENT){	//se o primeiro filho de expressao for IDENT
		//Pega o nome
		char *nome_e1 = n->filhos[3]->filhos[0]->filhos[0]->nodo.valor_lexico.val.string_val;
		//E procura o simbolo na tabela
		Simbolo *s_e1 = search_sim_table(pilha, nome_e1);
		vg_ou_vl = "rfp";
		//se nao achou eh VG
		if(!s_e1){
			s_e1 = search_sim_stack(pilha, nome_e1);
			vg_ou_vl = "rbss";
		}
		if(s_e1){//se o simbolo estava na pilha
			//carrega seu conteudo em reg_aux_e1
			printf("loadAI %s, %d => %s\n", vg_ou_vl, s_e1->deslocamento, reg_aux_e1);
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
		//E procura o simbolo na tabela
		Simbolo *s_e2 = search_sim_table(pilha, nome_e2);
		vg_ou_vl = "rfp";
		//se nao achou eh VG
		if(!s_e2){
			s_e2 = search_sim_stack(pilha, nome_e2);
			vg_ou_vl = "rbss";
		}
		if(s_e2){//se o simbolo estava na pilha
			//carrega seu conteudo em reg_aux_e2
			printf("loadAI %s, %d => %s\n", vg_ou_vl, s_e2->deslocamento, reg_aux_e2);
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
void iloc_list_init(NodoArvore *n){
    n->code->iloc = NULL;
    n->code->size = 0;
}

void iloc_list_append_op(struct iloc_list *code, ILOC *op){
    op->prev = code->iloc;
    code->iloc = op;
    code->size = code->size+1;
}

void iloc_list_append_code(NodoArvore *origem, NodoArvore *destino){
    ILOC **code = (ILOC**)malloc(sizeof(ILOC*)*origem->code->size);

    ILOC *op = origem->code->iloc;
    for(int i=origem->code->size-1; i>=0; i--)
    {
        code[i] = op;
        op = origem->code->iloc->prev;    
    }
    
    for(int i=0; i<origem->code->size; i++)
        iloc_list_append_op(destino->code,code[i]);    
        
    free(code);   
}
