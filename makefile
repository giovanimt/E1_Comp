all: flex gcc

flex:
	flex scanner.l
gcc:
	gcc -o etapa1 lex.yy.c -lfl
clean:
	rm etapa1 lex.yy.c
