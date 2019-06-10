%{
#include <stdio.h>
#include <string.h>
#include "estrutura.h"

int yylex();
void yyerror();	
char* yytext;
int yylineno;
GSList* termos;
GHashTable* relacoes;
%}
%parse-param{void* th}
%union{
	char* t;
}
%token TERMO ID LB
%type <t> TERMO ID
%%
Thesaurus : Metadados LB Conceitos {}
			;

Metadados : Metadados Meta {}
			|Meta  {}
			;

Meta: '%' TERMO Ids {adicionaMeta(th,$2,termos);}
		;

Ids: Ids ID {termos = g_slist_append(termos,$2);}
	| ID    {termos = NULL;termos = g_slist_append(termos,$1);}
	;

Conceitos: Conceitos LB Conceito {}
		| Conceito {}
		;

Conceito: TERMO Relacoes {adicionaConceito(th,$1,relacoes);}
		;

Relacoes: Relacoes ID Termos {adicionaRelacao(relacoes,$2,termos);}
		| ID Termos {relacoes=g_hash_table_new(g_str_hash,g_str_equal);
			     adicionaRelacao(relacoes,$1,termos);}
		;

Termos : Termos ',' TERMO  {adicionaTermo($3,termos);}
	   | TERMO {termos=g_slist_alloc();adicionaTermo($1,termos);}
	   ;

%%

void yyerror(){
	printf("error\n");
}

int main(){
	Thesaurus th = inicializa();
	yyparse(th);
	adicionaConceitoInv(th);
	criarPrincipal(th);
	criarConceitos(th);
}

