all: bison flex gcc

bison:
	bison -d parser.y -r all
flex:
	flex scanner.l
gcc:
	gcc -c lex.yy.c parser.tab.c
	gcc -o etapa2 lex.yy.o parser.tab.o main.c -lfl
clean:
	rm -f etapa2 lex.yy.c parser.tab.c parser.tab.h parser.output *.o
