all: flex gcc

flex:
	flex scanner.l
gcc:
	gcc -o etapa1 lex.yy.c main.c -lfl
clean:
	rm -f etapa1 lex.yy.c
