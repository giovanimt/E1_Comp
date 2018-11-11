#ifndef __codigo__
#define __codigo__

// Instrucao ILOC
typedef struct iloc {
    char *opcode;
    char *op1;
    char *op2;
    char *op3;
}ILOC;

// Lista de instrucoes. Aponta para a instrucao anterior
struct iloc_list {
    ILOC iloc;
    ILOC *prev;     
};

//Função que gera o nome de um rótulo
char* gera_rotulo();
//Função que gera o nome de um registrador
char* gera_registrador();
//Gera codigo de declaracao de var_global
void gera_codigo_vg(NodoArvore *n);
//Inicializa atributo code de no da AST
void gera_codigo_init(NodoArvore *n);

#endif
