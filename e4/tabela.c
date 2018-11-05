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
Pilha_Tabelas* inicializa_pilha(){
	Pilha_Tabelas *pilha = (Pilha_Tabelas*)malloc(sizeof(Pilha_Tabelas));
	pilha->tabelas = NULL;
	pilha->num_tabelas = 0;
    return pilha;
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
			if(strcmp(chave, pilha->tabelas[i]->simbolos[j]->chave)){
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
		if(strcmp(chave, pilha->tabelas[tabela_atual]->simbolos[j]->chave) && tipo == pilha->tabelas[tabela_atual]->simbolos[j]->tipo){
			return 1;
		}
	}
	return 0;
}

//Define o tipo e o seu tamanho e coloca no simbolo
void define_tipo(Simbolo *s, NodoArvore*n){
	switch(n->tipo) {
		case(TIPO_INT):
			s->tipo = TIPO_INT;
			s->tamanho = 4;
			break;

		case(TIPO_FLOAT):
			s->tipo = TIPO_FLOAT;
			s->tamanho = 8;
			break;

		case(TIPO_CHAR):
			s->tipo = TIPO_CHAR;
			s->tamanho = 1;
			break;

		case(TIPO_BOOL):
			s->tipo = TIPO_BOOL;
			s->tamanho = 1;
			break;

		case(TIPO_STRING):
			s->tipo = TIPO_STRING;
			s->tamanho = strlen(n->nodo.valor_lexico.val.string_val);
			break;

		case(TIPO_USR):
			s->tipo = TIPO_USR;
			break;
	}
}

// busca o tamanho e os campos do tipo usuario
void tamanho_usr(Pilha_Tabelas *pilha, Simbolo *s, NodoArvore*n){
	char *chave = n->nodo.valor_lexico.val.string_val;
	int tipo = TIPO_USR;
	for(int i=0; i < pilha->num_tabelas; i++){
		for(int j =0; j < pilha->tabelas[i]->num_simbolos; j++){
			if(strcmp(chave, pilha->tabelas[i]->simbolos[j]->chave) && tipo == pilha->tabelas[i]->simbolos[j]->tipo){
				s->Campos = pilha->tabelas[i]->simbolos[j]->Campos;
				s->num_campos = pilha->tabelas[i]->simbolos[j]->num_campos;
				s->tamanho = pilha->tabelas[i]->simbolos[j]->tamanho;
			}
		}
	}
}

//ajusta tamanho do vetor
void tamanho_vetor(Simbolo *s, NodoArvore*n){
	s->tamanho = s->tamanho * n->nodo.valor_lexico.val.int_val;
}


//Funcao Novo Tipo
void add_nt(Pilha_Tabelas *pilha, NodoArvore *n){
	//inicializa simbolo
	Simbolo *nt = (Simbolo*)malloc(sizeof(Simbolo));

	//nao eh cons nem funcao nem static nem tem encapsulamento
	nt->eh_cons = 0;
	nt->Argumentos = NULL;
	nt->num_argumentos = 0;
	nt->eh_static = 0;
	nt->encapsulamento = 0;
	nt->var_ou_vet = 0;

	//eh tipo usuario
	nt->tipo = TIPO_USR;
	nt->tamanho = 0;

	//define natureza TODO:nao entendi muito o sentido da natureza entao nao tenho certeza
	nt->natureza = NATUREZA_IDENTIFICADOR;

	//pega o segundo filho do nodo...
	NodoArvore *f2 = (NodoArvore*)n->filhos[0];
	//...para definir a *chave...
	nt->chave = f2->nodo.valor_lexico.val.string_val; //TODO:pode causar ponteiro pendente?
	//... e para definir a linha/col TODO:foi passado pros nodos folhas as linhas e colunas na E3?
	nt->line = f2->nodo.valor_lexico.line;
	nt->col = f2->nodo.valor_lexico.col;
	
	//adiciona o novo tipo na tabela
	add_simbolo_tabela(nt, pilha->tabelas[pilha->num_tabelas - 1]);

	//pega o terceiro filho do nodo onde estao os campos
	NodoArvore *f3 = (NodoArvore*)n->filhos[0];

	nt->Campos = (Simbolo**)malloc(sizeof(Simbolo*));
	NodoArvore *cam = (NodoArvore*)malloc(sizeof(NodoArvore));
	NodoArvore *fc1 = (NodoArvore*)malloc(sizeof(NodoArvore));
	NodoArvore *fc2 = (NodoArvore*)malloc(sizeof(NodoArvore));
	NodoArvore *fc3 = (NodoArvore*)malloc(sizeof(NodoArvore));

	/// para cada campo...
	for(int i=0; i<f3->num_filhos; i++){
		nt->Campos = (Simbolo**) realloc(nt->Campos, (i + 1) * sizeof(Simbolo*));
		nt->num_campos = f3->num_filhos;

		//Anula ou zera componentes de simbolo que nao sao necessarios para um campo
		nt->Campos[i]->line = 0;
		nt->Campos[i]->col = 0;
		nt->Campos[i]->natureza = 0;
		nt->Campos[i]->eh_static = 0;
		nt->Campos[i]->eh_cons = 0;
		nt->Campos[i]->Argumentos = NULL;
		nt->Campos[i]->Campos = NULL;


		cam = f3->filhos[i];
		//pega o primeiro filho do campo para definir o encapsulamento
		if(cam->filhos[0]){
			NodoArvore *fc1 = (NodoArvore*)cam->filhos[0];
			if(strcmp(fc1->nodo.valor_lexico.val.string_val, "protected"))
				nt->Campos[i]->encapsulamento = 1;
			if(strcmp(fc1->nodo.valor_lexico.val.string_val, "private"))
				nt->Campos[i]->encapsulamento = 2;
			if(strcmp(fc1->nodo.valor_lexico.val.string_val, "public"))
				nt->Campos[i]->encapsulamento = 3;
		}else{
			nt->Campos[i]->encapsulamento = 0;
		}

		//pega o segundo filho do campo...
		NodoArvore *fc2 = (NodoArvore*)cam->filhos[1];
		//...para definir o tipo e tamanho
		define_tipo(nt->Campos[i],fc2);
		//...e somar o tamanho ao Tipo Usuario criado
		nt->tamanho = nt->tamanho + nt->Campos[i]->tamanho;

		//pega o terceiro filho do campo...
		NodoArvore *fc3 = (NodoArvore*)cam->filhos[2];
		//...para definir a *chave...
		nt->Campos[i]->chave = fc3->nodo.valor_lexico.val.string_val; //TODO:pode causar ponteiro pendente?

		//adiciona campo na tabela
		add_simbolo_tabela(nt->Campos[i], pilha->tabelas[pilha->num_tabelas - 1]);
	}
}


//Funcao Variavel Global
void add_vg(Pilha_Tabelas *pilha, NodoArvore *n){
	//inicializa simbolo
	Simbolo *vg = (Simbolo*)malloc(sizeof(Simbolo));

	//nao eh cons nem funcao
	vg->eh_cons = 0;
	vg->Argumentos = NULL;
	vg->num_argumentos = 0;

	//define natureza TODO:nao entendi muito o sentido da natureza entao nao tenho certeza
	vg->natureza = NATUREZA_IDENTIFICADOR;

	//pega o primeiro filho do nodo...
	NodoArvore *f1 = (NodoArvore*)n->filhos[0];
	//...para definir a *chave...
	vg->chave = f1->nodo.valor_lexico.val.string_val; //TODO:pode causar ponteiro pendente?
	//... e para definir a linha/col TODO:foi passado pros nodos folhas as linhas e colunas na E3?
	vg->line = f1->nodo.valor_lexico.line;
	vg->col = f1->nodo.valor_lexico.col;
	
	//pega o segundo filho do nodo para definir se eh static
	if(n->filhos[1]==NULL){
		vg->eh_static = 0;
	}else{
		vg->eh_static = 1;
	}

	//pega o quarto filho do nodo...
	NodoArvore *f4 = (NodoArvore*)n->filhos[3];
	//...para definir o tipo e tamanho
	define_tipo(vg,f4);

	//se for tipo usuario eh necessario ajustar o tamanho e **Campos
	if(vg->tipo == TIPO_USR){
		tamanho_usr(pilha,vg,f4);
	}else{
		vg->Campos = NULL;
		vg->num_campos = 0;
	}

	//pega o terceiro filho do nodo pra ver se eh vetor e ajustar o tamanho
	if(n->filhos[2]!=NULL){
		NodoArvore *f3 = (NodoArvore*)n->filhos[2];
		vg->var_ou_vet = 2;
		tamanho_vetor(vg,f3);
	}else{
		vg->var_ou_vet = 1;
	}
	
	//adiciona simbolo na tabela
	add_simbolo_tabela(vg, pilha->tabelas[pilha->num_tabelas - 1]);
}


//Funcao Funcao
void add_func(Pilha_Tabelas *pilha, NodoArvore *n){
	//inicializa simbolo
	Simbolo *func = (Simbolo*)malloc(sizeof(Simbolo));

	//nao eh cons nem tem encapsulamento
	func->eh_cons = 0;
	func->encapsulamento = 0;
	func->var_ou_vet = 0;

	//define natureza TODO:nao entendi muito o sentido da natureza entao nao tenho certeza
	func->natureza = NATUREZA_IDENTIFICADOR;

	//pega o primeiro filho do nodo que eh o cabecalho...
	NodoArvore *f1 = (NodoArvore*)n->filhos[0];

	//...pega o primeiro filho do cabecalho pra ver se eh static
	if(f1->filhos[0]==NULL){
		func->eh_static = 0;
	}else{
		func->eh_static = 1;
	}

	//pega o segundo filho do cabecalho...
	NodoArvore *fc2 = (NodoArvore*)f1->filhos[1];
	//...para definir o tipo e tamanho
	define_tipo(func,fc2);
	//se for tipo usuario eh necessario ajustar o tamanho e **Campos
	if(func->tipo == TIPO_USR){
		tamanho_usr(pilha, func,fc2);
	}else{
		func->Campos = NULL;
		func->num_campos = 0;
	}

	//pega o terceiro filho do cabecalho...
	NodoArvore *fc3 = (NodoArvore*)f1->filhos[2];
	//...para definir a *chave...
	func->chave = fc3->nodo.valor_lexico.val.string_val; //TODO:pode causar ponteiro pendente?
	//... e para definir a linha/col TODO:foi passado pros nodos folhas as linhas e colunas na E3?
	func->line = fc3->nodo.valor_lexico.line;
	func->col = fc3->nodo.valor_lexico.col;

	//adiciona simbolo na tabela
	add_simbolo_tabela(func, pilha->tabelas[pilha->num_tabelas - 1]);

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
	
	//pega o segundo filho do nodo que eh o bloco_comandos e se ele nao for apenas {}, ou seja, tiver filhos, empilha nova tabela
	if(n->filhos[1]->num_filhos != 0){
		empilha(pilha);
	}
}


//Funcao Var Local
void add_vl(Pilha_Tabelas *pilha, NodoArvore *n){
	//inicializa simbolo
	Simbolo *vl = (Simbolo*)malloc(sizeof(Simbolo));

	//nao eh funcao nem tem encapsulamento
	vl->Argumentos = NULL;
	vl->num_argumentos = 0;
	vl->encapsulamento = 0;
	vl->var_ou_vet = 1;

	//define natureza TODO:nao entendi muito o sentido da natureza entao nao tenho certeza
	vl->natureza = NATUREZA_IDENTIFICADOR;

	//pega o primeiro filho do nodo para ver se eh static
	if(n->filhos[0]==NULL){
		vl->eh_static = 0;
	}else{
		vl->eh_static = 1;
	}

	//pega o segundo filho do nodo para ver se eh cons
	if(n->filhos[1]==NULL){
		vl->eh_cons = 0;
	}else{
		vl->eh_cons = 1;
	}

	//pega o terceiro filho do nodo...
	NodoArvore *f3 = (NodoArvore*)n->filhos[2];
	//...para definir o tipo e tamanho
	define_tipo(vl,f3);

	//se for tipo usuario eh necessario ajustar o tamanho e **Campos
	if(vl->tipo == TIPO_USR){
		tamanho_usr(pilha,vl,f3);
	}else{
		vl->Campos = NULL;
		vl->num_campos = 0;
	}

	//pega o quarto filho do nodo...
	NodoArvore *f4 = (NodoArvore*)n->filhos[3];
	//...para definir a *chave...
	vl->chave = f4->nodo.valor_lexico.val.string_val; //TODO:pode causar ponteiro pendente?
	//... e para definir a linha/col TODO:foi passado pros nodos folhas as linhas e colunas na E3?
	vl->line = f4->nodo.valor_lexico.line;
	vl->col = f4->nodo.valor_lexico.col;

	//adiciona simbolo na tabela
	add_simbolo_tabela(vl, pilha->tabelas[pilha->num_tabelas - 1]);
}


//Outros
///ver se foi declarado 0 nao 1 sim (sem analisar tipo TODO:como comparar o tipo?)
int declarado_atr(Pilha_Tabelas *pilha, NodoArvore *n){
	char *chave = n->nodo.valor_lexico.val.string_val;
	
	for(int i=0; i < pilha->num_tabelas; i++){
		for(int j =0; j < pilha->tabelas[i]->num_simbolos; j++){
			if(strcmp(chave, pilha->tabelas[i]->simbolos[j]->chave)){
				return 1;
			}
		}
	}
	return 0;
}

//analisa se eh vetor 0 nao 1 sim
int eh_vetor(Pilha_Tabelas *pilha, NodoArvore *n){
	char *chave = n->nodo.valor_lexico.val.string_val;
	
	for(int i=0; i < pilha->num_tabelas; i++){
		for(int j =0; j < pilha->tabelas[i]->num_simbolos; j++){
			if(strcmp(chave, pilha->tabelas[i]->simbolos[j]->chave) && pilha->tabelas[i]->simbolos[j]->var_ou_vet == 2){
				return 1;
			}
		}
	}
	return 0;
}

//analisa se o campo existe 0 nao 1 sim
int existe_campo(Pilha_Tabelas *pilha, NodoArvore *n1, NodoArvore *n2){
	char *chave = n1->nodo.valor_lexico.val.string_val;
	char *chave_campo = n2->nodo.valor_lexico.val.string_val;
	Simbolo *camp = (Simbolo*)malloc(sizeof(Simbolo));
	int num_campos;
	
	for(int i=0; i < pilha->num_tabelas; i++){
		for(int j =0; j < pilha->tabelas[i]->num_simbolos; j++){
			if(strcmp(chave, pilha->tabelas[i]->simbolos[j]->chave)){
				camp = pilha->tabelas[i]->simbolos[j]->Campos;
				num_campos = pilha->tabelas[i]->simbolos[j]->num_campos;
			}
		}
	}
	for(int k=0; k<num_campos; k++){
		if(strcmp(camp[k].chave, chave_campo)){
			return 1;
		}
	}
	return 0;
}
						
//analisa se eh usr
int eh_usr(Pilha_Tabelas *pilha, NodoArvore *n){
	char *chave = n->nodo.valor_lexico.val.string_val;
	for(int i=0; i < pilha->num_tabelas; i++){
		for(int j =0; j < pilha->tabelas[i]->num_simbolos; j++){
			if(strcmp(chave, pilha->tabelas[i]->simbolos[j]->chave) && pilha->tabelas[i]->simbolos[j]->tipo == TIPO_USR){
				return 1;
			}
		}
	}
	return 0;
}

//analisa se foram passados argumentos suficientes 0 erro 1 ok
int analisa_args(Pilha_Tabelas *pilha, NodoArvore *n){
	char *chave = n->filhos[0]->nodo.valor_lexico.val.string_val;
	int num_args;
	Simbolo *arg = (Simbolo*)malloc(sizeof(Simbolo));
	for(int i=0; i < pilha->num_tabelas; i++){
		for(int j =0; j < pilha->tabelas[i]->num_simbolos; j++){
			if(strcmp(chave, pilha->tabelas[i]->simbolos[j]->chave)){
				arg = pilha->tabelas[i]->simbolos[j]->Argumentos;
				num_args = pilha->tabelas[i]->simbolos[j]->num_argumentos;
			}
		}
	}
	for(int k=0; k<num_args; k++){
		if(arg[k].tipo != n->filhos[k+1]->tipo){
			return 0;
		}
	}
	return 1;
}
	
