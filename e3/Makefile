all: bison flex gcc

run:
	tests/run_tests.sh
bison:
	bison -d parser.y -r all
flex:
	flex --header-file=lex.yy.h scanner.l
gcc:
	gcc -c lex.yy.c parser.tab.c
	gcc -o etapa3 main.c lex.yy.o parser.tab.o -lfl
clean:
	rm -f etapa3 lex.yy.* parser.tab.* parser.output *.o
