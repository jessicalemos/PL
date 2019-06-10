CFLAGS=-g -Wall -Wextra -std=gnu99 -pedantic -pedantic-errors -Wshadow -Wno-unused-parameter 
INCLUDE  = `pkg-config --cflags --libs glib-2.0` 
thesaurus : lex.yy.o y.tab.o estrutura.o
	gcc -o thesaurus lex.yy.o y.tab.o estrutura.o -lglib-2.0 $(CFLAGS) $(INCLUDE)
	rm *.o

teste	: thesaurus
	./thesaurus < teste

exemplo	: thesaurus
	./thesaurus < exemplo

lex.yy.o : lex.yy.c y.tab.h
	gcc -c lex.yy.c

y.tab.o : y.tab.c
	gcc -c $(CFLAGS) $(INCLUDE) $< -o $@

y.tab.c y.tab.h : thesaurus.y estrutura.h
	yacc -d thesaurus.y 

lex.yy.c : thesaurus.l 
	flex -8 thesaurus.l 

estrutura.o : estrutura.c estrutura.h
	gcc $(CFLAGS) $(INCLUDE) -c  $< -o $@


clean:
	rm -rf lex.yy.c y.tab*
