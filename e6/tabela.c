/*
Giovani Tirello 252741
Vinicius Castro 193026
*/

#include "tabela.h"
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

/*
	//pega o quarto filho do cabecalho que sao os parametros(= argumentos)...
	NodoArvore *fc4 = (NodoArvore*)f1->filhos[2];
	//testa se existem...
	if(fc4->num_filhos == 0){
		func->Argumentos = NULL;
		func->num_argumentos = 0;
	}else{
		func->Argumentos = (Simbolo**)malloc(sizeof(Simbolo*));
		NodoArvore *param = (NodoArvore*)malloc(sizeof(NodoArvore));
		NodoArvore *fp2 = (NodoArvore*)malloc(sizeof(NodoArvore));
		NodoArvore *fp3 = (NodoArvore*)malloc(sizeof(NodoArvore));
		func->num_argumentos = fc4->num_filhos;
		//para cada parametro...
		for(int i = 0; i < fc4->num_filhos; i++){
			func->Argumentos = (Simbolo**) realloc(func->Argumentos, (i + 1) * sizeof(Simbolo*));
			
			//Anula ou zera componentes de simbolo que nao sao necessarios para um argumento
			func->Argumentos[i]->line = 0;
			func->Argumentos[i]->col = 0;
			func->Argumentos[i]->natureza = 0;
			func->Argumentos[i]->eh_static = 0;
			func->Argumentos[i]->encapsulamento = 0;
			func->Argumentos[i]->Argumentos = NULL;
			func->Argumentos[i]->Campos = NULL;

			param = fc4->filhos[i];
			//pega o primeiro filho do parametro para ver se eh cons
			if(param->filhos[0]==NULL){
				func->Argumentos[i]->eh_cons = 0;
			}else{
				func->Argumentos[i]->eh_cons = 1;
			}

			//pega o segundo filho do parametro...
			NodoArvore *fp2 = (NodoArvore*)param->filhos[1];
			//...para definir o tipo e tamanho
			define_tipo(func->Argumentos[i],fp2);

			//pega o terceiro filho do parametro...
			NodoArvore *fp3 = (NodoArvore*)param->filhos[2];
			//...para definir a *chave...
			func->Argumentos[i]->chave = fp3->nodo.valor_lexico.val.string_val; //TODO:pode causar ponteiro pendente?

			//adiciona parametro na tabela
			add_simbolo_tabela(func->Argumentos[i], pilha->tabelas[pilha->num_tabelas - 1]);
		}
	
	}
*/	
	
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
	vl->deslocamento = vl->tamanho*pilha->tabelas[pilha->num_tabelas - 1]->num_simbolos;
	
	//Definir valor
    	//Se existe atribuicao juntamente com a declaracao:
   	 if(n->filhos[4]){
		//se a atribuicao for um INT
        	if(n->filhos[5]->nodo.valor_lexico.type == INTEIRO) {
			vl->valor = n->filhos[5]->nodo.valor_lexico.val.int_val;
		}else{//se for um TK_IDENTIFICADOR
			char *nome_atr = n->filhos[5]->nodo.valor_lexico.val.string_val;
			//procura o simbolo na ultima tabela
			Simbolo *s = busca_simbolo_global(pilha, nome_atr);
			vl->valor = s->valor;
		}
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
