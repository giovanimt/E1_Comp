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
	static int num_regs = 1;
	char *nome_reg = (char*)malloc(20);
	sprintf(nome_reg, "r%i", num_regs);
	num_regs++;		
	return nome_reg;
}
