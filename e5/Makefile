all: bison flex gcc

bison:
	bison -d parser.y -r all
flex:
	flex --header-file=lex.yy.h scanner.l
gcc:
	gcc -g -c lex.yy.c parser.tab.c arvore.c tabela.c codigo.c
	gcc -g -o etapa5 main.c lex.yy.o parser.tab.o arvore.o tabela.o codigo.o -lfl
clean:
	rm -f etapa5 lex.yy.* parser.tab.* parser.output *.o 
