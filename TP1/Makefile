V=pl

$V: $V.l
	flex $V.l
	gcc -g lex.yy.c `pkg-config --cflags --libs glib-2.0` -o $V

clean:
	rm $V
	rm lex.yy.c