/*
Giovani Tirello 252741
Vinicius Castro 193026
*/

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
    iloc_list_init(n);

    // Apendar o codigo da expressao ao codigo da atribuicao (nova funcao para apendar o codigo)
    // Do parser: $$ = cria_nodo(atribuicao,4,cria_folha($1), NULL, NULL,$3);
	iloc_list_append_code(n->filhos[3], n);
    
    // Recupera simbolo da pilha e calcula deslocamentos
	char *reg_var = gera_registrador();
	char *nome_var = n->filhos[0]->nodo.valor_lexico.val.string_val;
    char* vg_ou_vl;
	
	Simbolo *s = search_sim_table(pilha, nome_var);
	if(s == NULL){
	    //o simbolo esta no escopo global
		s = search_sim_stack(pilha, nome_var);
		vg_ou_vl = "rbss";
	}
	else{
		//o simbolo estava no escopo local
		vg_ou_vl = "rfp";
		
	}
	s->valor = n->valor;
    
    // Gera código pro store e apenda no atributo code da AST
	char *op_addI = "addI";
	char *op_store = "store";
	char desloc[50];
    sprintf(desloc, "%d", s->deslocamento); 
	iloc_list_append_op(n->code, iloc_create_op(op_addI,vg_ou_vl,desloc,reg_var,NULL));
	iloc_list_append_op(n->code, iloc_create_op(op_store,n->filhos[3]->reg,NULL,reg_var,NULL));
	n->reg = reg_var;   
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
    struct iloc_list *code = (struct iloc_list*)malloc(sizeof(struct iloc_list));
    n->code = code;
    n->code->iloc = NULL;
    n->code->size = 0;
}

void iloc_list_append_op(struct iloc_list *code, ILOC *op){
    op->prev = code->iloc;
    code->iloc = op;
    code->size = code->size+1;
}

ILOC* iloc_create_op(char *opcode, char *op1, char *op2, char *op3, char *op4){
    ILOC *op = (ILOC*)malloc(sizeof(ILOC));
    op->prev = NULL;
    op->opcode = strdup(opcode);
    op->op1 = NULL;
    op->op2 = NULL;
    op->op3 = NULL;
    op->op4 = NULL;
    if(op1 != NULL)
        op->op1 = strdup(op1);
    if(op2 != NULL)
        op->op2 = strdup(op2);
    if(op3 != NULL)
        op->op3 = strdup(op3);
    if(op4 != NULL)
        op->op4 = strdup(op4);
    
    return op;    
}

void iloc_list_append_code(NodoArvore *origem, NodoArvore *destino){
    ILOC **code = (ILOC**)malloc(sizeof(ILOC*)*origem->code->size);

    ILOC *op = origem->code->iloc;
    for(int i=origem->code->size-1; i>=0; i--)
    {
        code[i] = op;
        op = op->prev;    
    }
    
    for(int i=0; i<origem->code->size; i++)
        iloc_list_append_op(destino->code,code[i]);    
     
    free(code);
    
}

void gera_codigo_arit(Pilha_Tabelas *pilha, NodoArvore *n, char *op){
    iloc_list_init(n);
    
	iloc_list_append_code(n->filhos[2], n);
	iloc_list_append_code(n->filhos[0], n);
	
    char *reg = gera_registrador();	
    iloc_list_append_op(n->code, iloc_create_op(op,n->filhos[0]->reg,n->filhos[2]->reg,reg,NULL));    
    n->reg = reg;
    
}

void gera_codigo_exp_literal(NodoArvore *n){
    // Inicializa atributo code da AST
    iloc_list_init(n);
    
    char *op_loadI = "loadI";
	char valor[50];
    sprintf(valor, "%d", n->valor);     
    
    char *reg = gera_registrador();
	iloc_list_append_op(n->code, iloc_create_op(op_loadI,valor,NULL,reg,NULL));
	n->reg = reg;
}

void imprime_codigo(NodoArvore *arvore){
    ILOC **code = (ILOC**)malloc(sizeof(ILOC*)*arvore->code->size);

    ILOC *op = arvore->code->iloc;
    for(int i=arvore->code->size-1; i>=0; i--)
    {
        code[i] = op;
        op = op->prev;    
    }

    for(int i=0; i<arvore->code->size; i++){
        op = code[i];
        printf("%s ",op->opcode);
        if(op->op1 != NULL)
            printf("%s",op->op1);
        if(op->op2 != NULL)
            printf(", %s",op->op2);
        printf(" => ");
        if(op->op3 != NULL)
            printf("%s ",op->op3);
        if(op->op4 != NULL)
            printf(", %s",op->op4);        
        printf("\n");
    }
    
    free(code);
}

