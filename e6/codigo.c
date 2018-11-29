/*
Giovani Tirello 252741
Vinicius Castro 193026
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include "codigo.h"

int num_rotulos = 1;
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

//Gera codigo para incrementar topo da pilha
void gera_codigo_rsp(NodoArvore *n){
    char *op_addI = "addI";
    char add_topo[2];
    sprintf(add_topo, "%d", 4);
    iloc_list_append_op(n->code, iloc_create_op(NULL, op_addI,"rsp",add_topo,"rsp",NULL));
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
    iloc_list_append_op(n->code, iloc_create_op(NULL,op_addI,reg_base,desloc,reg_end,NULL));
    iloc_list_append_op(n->code, iloc_create_op(NULL,op_store,n->filhos[5]->reg,NULL,reg_end,NULL));
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
	iloc_list_append_op(n->code, iloc_create_op(NULL,op_addI,reg_base,desloc,reg_end,NULL));
	iloc_list_append_op(n->code, iloc_create_op(NULL,op_store,n->filhos[3]->reg,NULL,reg_end,NULL));
	n->reg = n->filhos[3]->reg;   
}

void gera_codigo_if(NodoArvore *n){
    iloc_list_init(n);

    // Gera labels true e false para o while
    char *label_true = gera_rotulo();
    char *label_false = gera_rotulo();
    char *label_end = gera_rotulo();    

    // Preenche os labels pendentes das operacoes de comparacao    
    patch(&(n->filhos[1]->patch_list_true),label_true);
    patch(&(n->filhos[1]->patch_list_false),label_false);    
    
    // Codigo da expressao booleana do if    
   	iloc_list_append_code(n->filhos[1], n);
   	// Label se true
   	char *nop = "nop";
	iloc_list_append_op(n->code, iloc_create_op(label_true,nop,NULL,NULL,NULL,NULL));
	// Codigo se true (bloco_comandos)
   	iloc_list_append_code(n->filhos[3], n);
   	char *jumpI = "jumpI";
   	iloc_list_append_op(n->code, iloc_create_op(NULL,jumpI,NULL,NULL,label_end,NULL));
   	// Label se false
	iloc_list_append_op(n->code, iloc_create_op(label_false,nop,NULL,NULL,NULL,NULL));   		
	// Codigo se false (caso exista else)
	if(n->num_filhos > 4)
   	    iloc_list_append_code(n->filhos[5], n);
   	// Label endif
	iloc_list_append_op(n->code, iloc_create_op(label_end,nop,NULL,NULL,NULL,NULL));  		
}

void gera_codigo_while(NodoArvore *n){
    iloc_list_init(n);

    // Gera labels true e false para o if
    char *label_true = gera_rotulo();
    char *label_false = gera_rotulo();
    char *label_start = gera_rotulo();    

    // Preenche os labels pendentes das operacoes de comparacao    
    patch(&(n->filhos[1]->patch_list_true),label_true);
    patch(&(n->filhos[1]->patch_list_false),label_false);
    
   	// Label inicio do while (start)
   	char *nop = "nop";
	iloc_list_append_op(n->code, iloc_create_op(label_start,nop,NULL,NULL,NULL,NULL));    
    // Codigo da expressao booleana do while    
   	iloc_list_append_code(n->filhos[1], n);         
   	// Label se true
	iloc_list_append_op(n->code, iloc_create_op(label_true,nop,NULL,NULL,NULL,NULL));
	// Codigo while (bloco_comandos)
   	iloc_list_append_code(n->filhos[3], n);
   	char *jumpI = "jumpI";
   	iloc_list_append_op(n->code, iloc_create_op(NULL,jumpI,NULL,NULL,label_start,NULL));   	  	
   	// Label se false
	iloc_list_append_op(n->code, iloc_create_op(label_false,nop,NULL,NULL,NULL,NULL));   
}

void gera_codigo_do(NodoArvore *n){
    iloc_list_init(n);

    // Gera labels true e false para o if
    char *label_true = gera_rotulo();
    char *label_false = gera_rotulo();

    // Preenche os labels pendentes das operacoes de comparacao    
    patch(&(n->filhos[3]->patch_list_true),label_true);
    patch(&(n->filhos[3]->patch_list_false),label_false);    
    
   	// Label se true
   	char *nop = "nop";
	iloc_list_append_op(n->code, iloc_create_op(label_true,nop,NULL,NULL,NULL,NULL));
	// Codigo "do" (bloco_comandos)
   	iloc_list_append_code(n->filhos[1], n);
    // Codigo da expressao booleana do while    
   	iloc_list_append_code(n->filhos[3], n);   	
   	// Label se false
	iloc_list_append_op(n->code, iloc_create_op(label_false,nop,NULL,NULL,NULL,NULL));   
}

void  gera_codigo_or(NodoArvore *n){
    iloc_list_init(n);

    // Gera label se exp1 false (nao ocorreu curto-circuito)
    char *label_false = gera_rotulo();
    // Preenche os labels false pendentes da exp1
    patch(&(n->filhos[0]->patch_list_false),label_false);
    // Codigo da exp1
   	iloc_list_append_code(n->filhos[0], n);
   	// Label se exp1 false
   	char *nop = "nop";
	iloc_list_append_op(n->code, iloc_create_op(label_false,nop,NULL,NULL,NULL,NULL));
    // Codigo da exp2
   	iloc_list_append_code(n->filhos[2], n);	  

    patch_list_concat(&(n->patch_list_true),&(n->filhos[0]->patch_list_true),&(n->filhos[2]->patch_list_true));
 	n->patch_list_false.list = n->filhos[2]->patch_list_false.list;
 	n->patch_list_false.size = n->filhos[2]->patch_list_false.size;
}

void  gera_codigo_and(NodoArvore *n){
    iloc_list_init(n);

    // Gera label se exp1 true (nao ocorreu curto-circuito)
    char *label_true = gera_rotulo();
    // Preenche os labels true pendentes da exp1
    patch(&(n->filhos[0]->patch_list_true),label_true);
    // Codigo da exp1
   	iloc_list_append_code(n->filhos[0], n);
   	// Label se exp1 true
   	char *nop = "nop";
	iloc_list_append_op(n->code, iloc_create_op(label_true,nop,NULL,NULL,NULL,NULL));
    // Codigo da exp2
   	iloc_list_append_code(n->filhos[2], n);	  

    patch_list_concat(&(n->patch_list_false),&(n->filhos[0]->patch_list_false),&(n->filhos[2]->patch_list_false));
 	n->patch_list_true.list = n->filhos[2]->patch_list_true.list;
 	n->patch_list_true.size = n->filhos[2]->patch_list_true.size;
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

ILOC* iloc_create_op(char *label, char *opcode, char *op1, char *op2, char *op3, char *op4){
    ILOC *op = (ILOC*)malloc(sizeof(ILOC));
    op->prev = NULL;
    op->label = NULL;
    op->opcode = NULL;
    op->op1 = NULL;
    op->op2 = NULL;
    op->op3 = NULL;
    op->op4 = NULL;
    if(label != NULL)
        op->label = strdup(label);
    if(opcode != NULL)
        op->opcode = strdup(opcode);
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
    //code = tamanho codigo a ser apendado
    ILOC **code = (ILOC**)malloc(sizeof(ILOC*)*origem->code->size);
    //
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

void gera_codigo_arit(NodoArvore *n, char *op){
    iloc_list_init(n);
    
	iloc_list_append_code(n->filhos[0], n);
	iloc_list_append_code(n->filhos[2], n);
	
    char *reg = gera_registrador();	
    iloc_list_append_op(n->code, iloc_create_op(NULL,strdup(op),n->filhos[0]->reg,n->filhos[2]->reg,reg,NULL));    
    n->reg = reg; 
}

void patch(struct patch_list *plist, char *label){
    for(int i = 0; i < plist->size; i++)
        *(plist->list[i]) = label;
        
    free(plist->list);
    plist->list = NULL;
    plist->size = 0;
}

void patch_list_append(struct patch_list *plist, char **label){
    plist->list = (char***)realloc(plist->list,sizeof(char**)*plist->size+1);
    plist->list[plist->size] = label;
    plist->size++;
}

void patch_list_concat(struct patch_list *plist_dest, struct patch_list *plist1, struct patch_list *plist2){
    plist_dest->list = (char***)realloc(plist_dest->list,sizeof(char**)*(plist_dest->size + plist1->size + plist2->size));

    for(int i = plist_dest->size; i < plist1->size; i++)
        plist_dest->list[i] = plist1->list[(plist1->size-1)*i];        
    plist_dest->size = plist_dest->size + plist1->size;
    
    for(int i = plist_dest->size; i < plist1->size+plist2->size; i++)
        plist_dest->list[i] = plist2->list[(plist2->size-1)*i];    
    plist_dest->size = plist_dest->size + plist2->size;

    plist1->size = 0;    
    free(plist1->list);

    plist2->size = 0;    
    free(plist2->list);    
}

void gera_codigo_cmp(NodoArvore *n,char *op){
    iloc_list_init(n);
    
	iloc_list_append_code(n->filhos[0], n);
	iloc_list_append_code(n->filhos[2], n);
	
    char *reg = gera_registrador();	
    iloc_list_append_op(n->code, iloc_create_op(NULL,strdup(op),n->filhos[0]->reg,n->filhos[2]->reg,reg,NULL));    
    n->reg = reg; 
    
    char *cbr = "cbr";
    iloc_list_append_op(n->code, iloc_create_op(NULL,cbr,reg,NULL,NULL,NULL));
    patch_list_append(&(n->patch_list_true),&(n->code->iloc->op3));
    patch_list_append(&(n->patch_list_false),&(n->code->iloc->op4));
}

void gera_codigo_literal(NodoArvore *n){
    iloc_list_init(n);
   	n->valor = n->nodo.valor_lexico.val.int_val;
    
    char *op_loadI = "loadI";
	char valor[50];
    sprintf(valor, "%d", n->valor);     
    
    char *reg = gera_registrador();
	iloc_list_append_op(n->code, iloc_create_op(NULL,op_loadI,valor,NULL,reg,NULL));
	n->reg = reg;

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

	n->valor = s->valor;
    
    // Gera código pro load e apenda no atributo code da AST
	char *op_addI = "addI";
	char *op_load = "load";
    char *reg_end = gera_registrador();
    char *reg_val = gera_registrador();

   	char desloc[50];
    sprintf(desloc, "%d", s->deslocamento); 
	iloc_list_append_op(n->code, iloc_create_op(NULL,op_addI,reg_base,desloc,reg_end,NULL));
	iloc_list_append_op(n->code, iloc_create_op(NULL,op_load,reg_end,NULL,reg_val,NULL));
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
        if(op->label != NULL)
            printf("%s: ",op->label);
        printf("%s",op->opcode);
        if(!strcmp(op->opcode,"nop")){
            printf("\n");
            continue;
        }
        if(op->op1 != NULL)
            printf(" %s",op->op1);
        if(op->op2 != NULL)
            printf(", %s",op->op2);
        printf(" => ");
        if(op->op3 != NULL)
            printf("%s",op->op3);
        if(op->op4 != NULL)
            printf(", %s",op->op4);        
        printf("\n");
    }
    
    free(code);
}

