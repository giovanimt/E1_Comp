all: bison flex gcc

run: all
	tests/run_tests.sh
bison:
	bison -d parser.y -r all
flex:
	flex --header-file=lex.yy.h scanner.l
gcc:
	gcc -g -c lex.yy.c parser.tab.c arvore.c
	gcc -g -o etapa3 main.c lex.yy.o parser.tab.o arvore.o -lfl
clean:
	rm -f etapa3 lex.yy.* parser.tab.* parser.output *.o tests/*.out?
