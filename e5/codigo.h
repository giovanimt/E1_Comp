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
    ILOC *instrucao;
    ILOC *prev     
};

#endif
