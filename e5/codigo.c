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

//Gera codigo de declaracao de var_local
void gera_codigo_vl(Pilha_Tabelas *pilha, NodoArvore *n){
    iloc_list_init(n);
	iloc_list_append_code(n->filhos[5], n);    

    // Recupera simbolo da pilha e calcula deslocamentos
    char *reg_end = gera_registrador();
    char *nome_var = n->filhos[3]->nodo.valor_lexico.val.string_val;
    char* reg_base = "rfp";

    Simbolo *s = busca_simbolo_local(pilha, nome_var);
    s->valor = n->filhos[5]->valor;
    
    // Gera código pro store e apenda no atributo code da AST
    char *op_addI = "addI";
    char *op_store = "store";
    char desloc[50];
    sprintf(desloc, "%d", s->deslocamento); 
    iloc_list_append_op(n->code, iloc_create_op(op_addI,reg_base,desloc,reg_end,NULL));
    iloc_list_append_op(n->code, iloc_create_op(op_store,n->filhos[5]->reg,NULL,reg_end,NULL));
    n->reg = n->filhos[3]->reg;
    n->valor = n->filhos[5]->valor;

}

//Gera codigo de atribuicao TK_IDENTIFICADOR '=' expressao
void gera_codigo_atr(Pilha_Tabelas *pilha, NodoArvore *n){
    iloc_list_init(n);
	iloc_list_append_code(n->filhos[3], n);
    
    // Recupera simbolo da pilha e calcula deslocamentos
	char *reg_end = gera_registrador();
	char *nome_var = n->filhos[0]->nodo.valor_lexico.val.string_val;
    char* reg_base;
	
	Simbolo *s = busca_simbolo_local(pilha, nome_var);
	if(s == NULL){
		s = busca_simbolo_global(pilha, nome_var);
		reg_base = "rbss";
	}
	else
	    reg_base = "rfp";

	s->valor = n->filhos[3]->valor;
    
    // Gera código pro store e apenda no atributo code da AST
	char *op_addI = "addI";
	char *op_store = "store";
	char desloc[50];
    sprintf(desloc, "%d", s->deslocamento); 
	iloc_list_append_op(n->code, iloc_create_op(op_addI,reg_base,desloc,reg_end,NULL));
	iloc_list_append_op(n->code, iloc_create_op(op_store,n->filhos[3]->reg,NULL,reg_end,NULL));
	n->reg = n->filhos[3]->reg;   
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
    if(n->code ==  NULL)
    {  
        struct iloc_list *code = (struct iloc_list*)malloc(sizeof(struct iloc_list));
        n->code = code;
        n->code->iloc = NULL;
        n->code->size = 0;
    }
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

void gera_codigo_literal(NodoArvore *n){
    iloc_list_init(n);
    
    char *op_loadI = "loadI";
	char valor[50];
    sprintf(valor, "%d", n->valor);     
    
    char *reg = gera_registrador();
	iloc_list_append_op(n->code, iloc_create_op(op_loadI,valor,NULL,reg,NULL));
	n->reg = reg;
	n->valor = n->nodo.valor_lexico.val.int_val;
}


void gera_codigo_identificador(Pilha_Tabelas *pilha, NodoArvore *n){
    iloc_list_init(n);
    
    // Recupera simbolo da pilha e calcula deslocamentos
	char *nome_var = n->nodo.valor_lexico.val.string_val;
	char* reg_base;
	Simbolo *s = busca_simbolo_local(pilha, nome_var);
	if(s == NULL){
		s = busca_simbolo_global(pilha, nome_var);
		reg_base = "rbss";
	}
	else
	    reg_base = "rfp";

	s->valor = n->valor;
    
    // Gera código pro load e apenda no atributo code da AST
	char *op_addI = "addI";
	char *op_load = "load";
    char *reg_end = gera_registrador();
    char *reg_val = gera_registrador();

   	char desloc[50];
    sprintf(desloc, "%d", s->deslocamento); 
	iloc_list_append_op(n->code, iloc_create_op(op_addI,reg_base,desloc,reg_end,NULL));
	iloc_list_append_op(n->code, iloc_create_op(op_load,reg_end,NULL,reg_val,NULL));
	n->reg = reg_val; 
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

