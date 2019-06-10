#include <gmodule.h>

typedef struct conceito{
	char* nome;
	GHashTable* relacoes;
	FILE* f;
}*Conceito;

typedef struct relacoes{
	char* tipo;
	GSList*  termos;
}*Relacoes;

typedef struct thesaurus{
	GHashTable* conceitos;
	GHashTable* linguas;
	char* lingua;
	GHashTable* inv;
}*Thesaurus;

Thesaurus inicializa();
void adicionaConceito(Thesaurus th, char* nome, GHashTable* relacoes);
void adicionaRelacao(GHashTable* r, char* t, GSList* termos);
void adicionaTermo(char* t, GSList* termos);
void adicionaMeta(Thesaurus th, char* t,GSList* ids);
void criarPrincipal(Thesaurus th);
void criarConceitos(Thesaurus th);
void adicionaConceitoInv(Thesaurus th);

