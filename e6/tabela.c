/*
Giovani Tirello 252741
Vinicius Castro 193026
*/

#include "tabela.h"
#include "codigo.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

#define NATUREZA_LITERAL_INT        1
#define NATUREZA_LITERAL_FLOAT      2
#define NATUREZA_LITERAL_CHAR       3
#define NATUREZA_LITERAL_STRING     4
#define NATUREZA_LITERAL_BOOL       5
#define NATUREZA_IDENTIFICADOR      6

char *rotulo_main = "L0";


//Funcoes tabela
Tabela* cria_tabela(){
	Tabela *t = (Tabela*)malloc(sizeof(Tabela));
	t->simbolos = NULL;
	t->num_simbolos = 0;
	return t;
}

void add_simbolo_tabela(Simbolo *s, Tabela *t){
	t->simbolos = (Simbolo**) realloc(t->simbolos, (t->num_simbolos + 1) * sizeof(Simbolo**));
	t->simbolos[t->num_simbolos]= s;
	t->num_simbolos++;
}


//Funcoes Pilha
void inicializa_pilha(Pilha_Tabelas** pilha){
	if(*pilha == NULL){
	    *pilha = (Pilha_Tabelas*)malloc(sizeof(Pilha_Tabelas));
	    (*pilha)->tabelas = NULL;
	    (*pilha)->num_tabelas = 0;
	    empilha(*pilha);
    }
}

void empilha(Pilha_Tabelas *pilha){
	Tabela *t = cria_tabela();
	pilha->tabelas = (Tabela**) realloc(pilha->tabelas, (pilha->num_tabelas + 1) * sizeof(Tabela**));
	pilha->tabelas[pilha->num_tabelas] = t;
	pilha->num_tabelas++;
}

void desempilha(Pilha_Tabelas *pilha){
	if(pilha->num_tabelas !=0){
		free(pilha->tabelas[pilha->num_tabelas - 1]);
		pilha->tabelas = (Tabela**) realloc(pilha->tabelas, (pilha->num_tabelas - 1) * sizeof(Tabela**));
		pilha->num_tabelas--;
	}
}


//Funcoes simbolos
// declarado: avalia se o simbolo ja foi declarado 0 nao 1 sim, recebe a pilha, o nodo com o nome e o nodo com o tipo
int declarado(Pilha_Tabelas *pilha, char *chave){
	for(int i=0; i < pilha->num_tabelas; i++){
		for(int j =0; j < pilha->tabelas[i]->num_simbolos; j++){
			if(!strcmp(chave, pilha->tabelas[i]->simbolos[j]->chave)){
				return 1;
			}
		}
	}
	return 0;
}

// declarado_tabela: avalia se o simbolo ja foi declarado APENAS NA ULTIMA TABELA 0 nao 1 sim, recebe a pilha, o nodo com o nome e o nodo com o tipo
int declarado_tabela(Pilha_Tabelas *pilha, NodoArvore *n1, NodoArvore *n2){
	char *chave = n1->nodo.valor_lexico.val.string_val;
	int tipo = TIPO_USR;
	if(n2){
		tipo = n2->tipo;
	}
	int tabela_atual = pilha->num_tabelas -1;
	for(int j =0; j < pilha->tabelas[tabela_atual]->num_simbolos; j++){
		if(!strcmp(chave, pilha->tabelas[tabela_atual]->simbolos[j]->chave) && tipo == pilha->tabelas[tabela_atual]->simbolos[j]->tipo){
			return 1;
		}
	}
	return 0;
}



//Funcao Variavel Global
void add_vg(Pilha_Tabelas *pilha, NodoArvore *n){
	//inicializa simbolo
	Simbolo *vg = (Simbolo*)malloc(sizeof(Simbolo));

	//nao eh cons nem funcao
	vg->Argumentos = NULL;
	vg->num_argumentos = 0;


	//pega o primeiro filho do nodo...
	NodoArvore *f1 = (NodoArvore*)n->filhos[0];
	//...para definir a *chave...
	vg->chave = f1->nodo.valor_lexico.val.string_val;
	//... e para definir a linha/col
	vg->line = f1->nodo.valor_lexico.line;
	vg->col = f1->nodo.valor_lexico.col;
	

	//E5: considerar somente INT
	vg->valor = 0;
	vg->tipo = TIPO_INT;
	vg->tamanho = 4;
	vg->deslocamento = vg->tamanho*pilha->tabelas[0]->num_simbolos;
	
	//adiciona simbolo na tabela do escopo global
	add_simbolo_tabela(vg, pilha->tabelas[0]);
}


//Funcao Funcao
void add_func(Pilha_Tabelas *pilha, NodoArvore *f1){

	//inicializa simbolo
	Simbolo *func = (Simbolo*)malloc(sizeof(Simbolo));

	//pega o terceiro filho do cabecalho...
	NodoArvore *fc3 = (NodoArvore*)f1->filhos[2];
	//...para definir a *chave...
	func->chave = fc3->nodo.valor_lexico.val.string_val;
	//... e para definir a linha/col
	func->line = fc3->nodo.valor_lexico.line;
	func->col = fc3->nodo.valor_lexico.col;

	//E5: sempre tipo int
	func->tipo = TIPO_INT;
	func->tamanho = 4;

	//adiciona simbolo na tabela
	add_simbolo_tabela(func, pilha->tabelas[pilha->num_tabelas - 1]);


	// pega o quarto filho do cabecalho que sao os parametros(= argumentos)...
	NodoArvore *fc4 = (NodoArvore*)f1->filhos[3];
	//printf("No Parametros: %d\n", fc4->num_filhos);
	
	//testa se existem...
	if(fc4->num_filhos == 0){
		func->Argumentos = NULL;
		func->num_argumentos = 0;
	}else{
		//Se existem aloca argumentos na Lista de Simbolos e os empilha
		func->num_argumentos = fc4->num_filhos;
		func->Argumentos = (Lista_Argumentos*)malloc(sizeof(Lista_Argumentos));
		Lista_Argumentos *arg = func->Argumentos;
		NodoArvore *param;
		NodoArvore *fp3;
		int desloc = 16;
		//para cada parametro...
		for(int i = 0; i < func->num_argumentos; i++){
			//Anula ou zera componentes de simbolo que nao sao necessarios para um argumento
			arg->Argumento = (Simbolo*)malloc(sizeof(Simbolo));
			arg->next = (Lista_Argumentos*)malloc(sizeof(Lista_Argumentos));

			arg->Argumento->line = 0;
			arg->Argumento->col = 0;
			arg->Argumento->Argumentos = NULL;
			arg->Argumento->num_argumentos = 0;
			arg->Argumento->tipo = TIPO_INT;
			arg->Argumento->tamanho = 4;
			arg->Argumento->valor = 0;

			
			arg->Argumento->deslocamento = desloc;
			
			param = fc4->filhos[i];


			//pega o terceiro filho do parametro...
			NodoArvore *fp3 = (NodoArvore*)param->filhos[2];
			//...para definir a *chave...
			arg->Argumento->chave = fp3->nodo.valor_lexico.val.string_val;

			//adiciona parametro na tabela
			add_simbolo_tabela(arg->Argumento, pilha->tabelas[pilha->num_tabelas - 1]);
			arg = arg->next;
			desloc = desloc + 4;
		}
	
	}
	
}


//Funcao Var Local
void add_vl(Pilha_Tabelas *pilha, NodoArvore *n){
	//inicializa simbolo
	Simbolo *vl = (Simbolo*)malloc(sizeof(Simbolo));

	//nao eh funcao
	vl->Argumentos = NULL;
	vl->num_argumentos = 0;

	//pega o quarto filho do nodo...
	NodoArvore *f4 = (NodoArvore*)n->filhos[3];
	//...para definir a *chave...
	vl->chave = f4->nodo.valor_lexico.val.string_val;
	//... e para definir a linha/col
	vl->line = f4->nodo.valor_lexico.line;
	vl->col = f4->nodo.valor_lexico.col;

	//E5: considerar somente INT
	vl->tipo = TIPO_INT;
	vl->tamanho = 4;
	
	//printf("Num Simbolos %d\n", vl->tamanho*pilha->tabelas[pilha->num_tabelas - 1]->num_simbolos);
	vl->deslocamento = 16 - 4 + vl->tamanho*pilha->tabelas[pilha->num_tabelas - 1]->num_simbolos;
	//printf("Deslocamento %d\n", vl->deslocamento);
	
	//Definir valor
    	//Se existe atribuicao juntamente com a declaracao:
   	 if(n->filhos[4]){
		vl->valor = n->filhos[5]->nodo.valor_lexico.val.int_val;
	}else{
		vl->valor = 0;
	}
	//adiciona simbolo na tabela
	add_simbolo_tabela(vl, pilha->tabelas[pilha->num_tabelas - 1]);
}




//E5: procura simbolos e os retorna
Simbolo* busca_simbolo_global(Pilha_Tabelas *pilha, char *chave){
	for(int i=pilha->num_tabelas - 1; i >= 0; i--){//alterado para pegar sempre a tabela mais em cima da pilha
		for(int j =0; j < pilha->tabelas[i]->num_simbolos; j++){
			if(!strcmp(chave, pilha->tabelas[i]->simbolos[j]->chave)){
				return pilha->tabelas[i]->simbolos[j];
			}
		}
	}
	return NULL;
}

Simbolo* busca_simbolo_local(Pilha_Tabelas *pilha, char *chave){
	for(int j =0; j < pilha->tabelas[pilha->num_tabelas - 1]->num_simbolos; j++){
		if(!strcmp(chave, pilha->tabelas[pilha->num_tabelas - 1]->simbolos[j]->chave)){
			return pilha->tabelas[pilha->num_tabelas - 1]->simbolos[j];
		}
	}
	return NULL;
}




void imprime_pilha(Pilha_Tabelas *pilha){
	printf("%d tabelas\n", pilha->num_tabelas);
	for(int i=pilha->num_tabelas - 1; i >= 0; i--){//alterado para pegar sempre a tabela mais em cima da pilha
		printf("tabela %d: %d simbolos\n", i, pilha->tabelas[i]->num_simbolos);
		for(int j =0; j < pilha->tabelas[i]->num_simbolos; j++){
			printf("nome simbolo: %s\n", pilha->tabelas[i]->simbolos[j]->chave);
		}
	}
}

void inicializa_pilha_RA(Pilha_RA* pilha, NodoArvore *n){
	if(pilha == NULL){
		pilha = malloc(sizeof(RAtivacao));
		pilha->RAs = NULL;
		char *op_loadI = "loadI";
		char *op_jumpI = "jumpI";
		iloc_list_append_op(n->code, iloc_create_op(NULL,op_loadI,"1024",NULL,"rfp",NULL));
		iloc_list_append_op(n->code, iloc_create_op(NULL,op_loadI,"1024",NULL,"rsp",NULL));
		iloc_list_append_op(n->code, iloc_create_op(NULL,op_loadI,"512",NULL,"rbss",NULL));
		iloc_list_append_op(n->code, iloc_create_op(NULL,op_jumpI,NULL,NULL,"L0",NULL));
	}
}


void inicio_funcao(NodoArvore *n, Pilha_Tabelas *pilha){

	int i = 1;
	NodoArvore *f1 = n->filhos[0];

	Simbolo *s;

	if(!strcmp(f1->filhos[2]->nodo.valor_lexico.val.string_val, "main")){
		s = busca_simbolo_local(pilha, "main");
		s->label = rotulo_main;

		char *op_loadI = "loadI";
		char *op_store = "store";
		char *op_storeAI = "storeAI";
		char *op_addI = "addI";
		char *reg_zerado = gera_registrador();

		iloc_list_append_op(n->code, iloc_create_op(rotulo_main,op_loadI,"0",NULL,reg_zerado,NULL));
		iloc_list_append_op(n->code, iloc_create_op(NULL,op_store,reg_zerado,NULL,"rsp",NULL));
		iloc_list_append_op(n->code, iloc_create_op(NULL,op_storeAI,reg_zerado,NULL,"rsp","4"));
		iloc_list_append_op(n->code, iloc_create_op(NULL,op_storeAI,reg_zerado,NULL,"rsp","8"));
		iloc_list_append_op(n->code, iloc_create_op(NULL,op_storeAI,reg_zerado,NULL,"rsp","12"));
		iloc_list_append_op(n->code, iloc_create_op(NULL,op_addI,"rsp","16","rsp",NULL));




	}else{

		NodoArvore *f2 = n->filhos[1];
	
		ILOC* op = f2->code->iloc;
		while( i < f2->code->size){
			op = op->prev;
			i++;
		}


		s = busca_simbolo_local(pilha, f1->filhos[2]->nodo.valor_lexico.val.string_val);
		op->label = gera_rotulo();
		s->label = op->label;


		//TODO: Precisa Fazer?
		//Aloca parametros por valor
		//loadAI rfp, 12 => r0   // Obtém o parâmetro
		//storeAI r0 => rfp, 20  // Salva o parâmetro na variável y
		//loop

		/*

		//printf("Num params %d\n", s->num_argumentos);

		int desloc = 16;
		char *des;
		char *reg_temp = gera_registrador();

		for(int i = 0; i < s->num_argumentos; i++){
			sprintf(des, "%d", desloc);   
			if(i==0){
				iloc_list_append_op(n->code, iloc_create_op(s->label,"loadAI","rfp",des,reg_temp,NULL));
			}else{
				iloc_list_append_op(n->code, iloc_create_op(NULL,"loadAI","rfp",des,reg_temp,NULL));
			}

			iloc_list_append_op(n->code, iloc_create_op(s->label,"storeAI",reg_temp,NULL,"rfp",NULL));


			desloc = desloc+4;
			i++;
		}*/

	}
	
}	



void chama_func(NodoArvore *n, Pilha_Tabelas *pilha){

//Salva o atual rfp na pilha (como vínculo dinâmico)	store rfp => rsp
	iloc_list_append_op(n->code, iloc_create_op(NULL,"store","rfp",NULL,"rsp",NULL));


//Calcula o vínculo estático				loadI 0 => reg1
//						storeAI reg1 => rsp, 4
	char *reg_zerado = gera_registrador();
	iloc_list_append_op(n->code, iloc_create_op(NULL,"loadI","0",NULL,reg_zerado,NULL));
	iloc_list_append_op(n->code, iloc_create_op(NULL,"storeAI",reg_zerado,NULL,"rsp","4"));



/* Passa os parâmetros (organizando-os na pilha)
loadAI  rfp, 0 => r0   // Carrega o valor da variável x em r0
storeAI r0 => rsp, 16+Y  // Empilha o parâmetro
loop*/
	//printf("Num filhos: %d", n->num_filhos);

	Simbolo *s, *s1;
	s = busca_simbolo_global(pilha, n->filhos[0]->nodo.valor_lexico.val.string_val);
	int desloc = 16;
	char var_des[50];
	char par_des[50];
	char *reg_temp = gera_registrador();
	sprintf(par_des,"%i", desloc); 
	for(int i = 0; i < s->num_argumentos; i++){
		s1 = busca_simbolo_global(pilha, n->filhos[i+1]->filhos[0]->nodo.valor_lexico.val.string_val);
		sprintf(var_des,"%i", s1->deslocamento); 
		//printf("Nome var: %s\n", n->filhos[i+1]->filhos[0]->nodo.valor_lexico.val.string_val);
		iloc_list_append_op(n->code, iloc_create_op(NULL,"loadAI","rfp",var_des,reg_temp,NULL));
		iloc_list_append_op(n->code, iloc_create_op(NULL,"storeAI",reg_temp,NULL,"rsp",par_des));
		desloc = desloc+4;

		sprintf(par_des,"%i", desloc); 
	}



// Passa o endereço de retorno para o chamado	addI rpc, X => reg2
//						storeAI reg2 => rsp, 12
	iloc_list_append_op(n->code, iloc_create_op(NULL,"addI","rpc","5",reg_temp,NULL));
	iloc_list_append_op(n->code, iloc_create_op(NULL,"storeAI",reg_temp,NULL,"rsp","12"));



//i2i rsp => rfp //Atualiza rfp
	iloc_list_append_op(n->code, iloc_create_op(NULL,"i2i","rsp",NULL,"rfp",NULL));


// addI rsp, Y_final => rsp    // Atualiza o rsp (SP)
	iloc_list_append_op(n->code, iloc_create_op(NULL,"addI","rsp",par_des,"rsp",NULL));



//Transfere o controle para o chamado rpc
//jumpI => Label            // Salta para o início da função chamada
	iloc_list_append_op(n->code, iloc_create_op(NULL,"jumpI",NULL,NULL,s->label,NULL));


/*Recebe o resultado
loadAI rsp, 8 => r0   // Retorno da função, carrega o valor de retorno
storeAI r0 => rfp, 0   // Salva o retorno na variável x*/
	n->reg = gera_registrador();
	iloc_list_append_op(n->code, iloc_create_op(NULL,"loadAI","rsp","8",n->reg,NULL));
}




void retorna_func(NodoArvore *n){

//Disponibiliza o valor de retorno para o chamador
//storeAI r0 => rfp, 8  // Registra o valor de retorno
	iloc_list_append_op(n->code, iloc_create_op(NULL,"storeAI",n->reg,NULL,"rfp","8"));


//loadAI rfp, 12 => reg_end_ret    // Obtém end. retorno
	char *reg_end_ret = gera_registrador();
	iloc_list_append_op(n->code, iloc_create_op(NULL,"loadAI","rfp","12",reg_end_ret,NULL));


/* Atualiza o rfp e o rsp
load rfp => r2    // Obtém rfp (RFP) salvo
i2i rfp => rsp        // Atualiza o rsp (SP)
i2i r2 => rfp        // Atualiza o rfp (RFP)*/
	char *reg_vin_din = gera_registrador();
	iloc_list_append_op(n->code, iloc_create_op(NULL,"load","rfp",NULL,reg_vin_din,NULL));
	iloc_list_append_op(n->code, iloc_create_op(NULL,"i2i","rfp",NULL,"rsp",NULL));
	iloc_list_append_op(n->code, iloc_create_op(NULL,"i2i",reg_vin_din,NULL,"rfp",NULL));


//Transfere o controle rpc
//jump => reg_end_ret             // Salta para o endereço de retorno
	iloc_list_append_op(n->code, iloc_create_op(NULL,"jump",NULL,NULL,reg_end_ret,NULL));
}

