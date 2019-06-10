#include <stdio.h>
#include "estrutura.h"

FILE* home,*info;
Thesaurus thg;

Thesaurus inicializa(){
	Thesaurus th = malloc(sizeof(struct thesaurus));
	th->conceitos = g_hash_table_new(g_str_hash,g_str_equal);
	th->linguas = g_hash_table_new(g_str_hash,g_str_equal);
	th->inv = g_hash_table_new(g_str_hash,g_str_equal);
	return th;
}

void adicionaConceito(Thesaurus th, char* nome, GHashTable* relacoes){
	Conceito c = malloc(sizeof(struct conceito));
	c->nome = strdup(nome);
	c->relacoes = relacoes;
	strcat(nome,".html");
	char buffer[256];
	strcpy(buffer,"Files/");
	strcat(buffer,nome);
	c->f = fopen(buffer,"w+");
	g_hash_table_insert(th->conceitos,c->nome,c);
}


void adicionaMeta(Thesaurus th, char* t,GSList* ids){
	GSList* iterator = NULL;
	if(!strcmp(t,"language ")){
		for (iterator = ids; iterator; iterator = iterator->next) {
			char* termo = iterator->data;
			g_hash_table_add(th->linguas,strdup(termo));
		}
	}
	else if(!strcmp(t,"baselang ")){
		char* termo = (char*) g_slist_last(ids)->data;
		th->lingua = strdup(termo);
	}
	else if(!strcmp(t,"inv ")){
		char* primeiro = (char*) g_slist_nth(ids,0)->data;
		char* segundo = (char*) g_slist_nth(ids,1)->data;
		g_hash_table_insert(th->inv, primeiro, segundo);
		g_hash_table_insert(th->inv, segundo, primeiro);
	}
}

void adicionaRelacao(GHashTable* r, char* t, GSList* termos){
	Relacoes relacao = malloc(sizeof(struct relacoes));
	if(g_hash_table_contains(r,t)){
		GSList* aux = g_hash_table_lookup(r,t);
		aux = aux->next;
		for (int i =1; i<(int) g_slist_length(termos);i++) {
			char* termo = g_slist_nth_data(termos,i);
			aux = g_slist_append(aux,termo);
		}
		relacao->termos = aux;
	}
	else{
	GSList* aux = NULL;
		for (int i = 1; i<(int) g_slist_length(termos);i++) {
			char* termo = g_slist_nth_data(termos,i);
			aux = g_slist_append(aux,strdup(termo));
		}
		relacao->termos = aux;
	}
	relacao->tipo = strdup(t);
	g_hash_table_insert(r,relacao->tipo,relacao);
}

void adicionaTermo(char* t, GSList* termos){
	if(t!=NULL){
	char* termo = strdup(t);
	termos = g_slist_append(termos,termo);}
}

void imprimeConceitos(gpointer key, gpointer conceito, gpointer thesaurus){
	Conceito c  = (Conceito) conceito;
	fprintf(home,"<tr>\n<td>%i</td>\n",g_hash_table_size(c->relacoes));
	fprintf(home,"<td><a href=\"%s.html\">%s</a></td>\n</tr>\n",c->nome,c->nome);

}


int contaRelacoes(Thesaurus th){
	int conta = 0;
	GList* keys=g_hash_table_get_keys(th->conceitos);
	for(int i=0;i<(int)g_list_length(keys);i++){
        	char* key=g_list_nth_data(keys,i);
        	Conceito c=g_hash_table_lookup(th->conceitos,key);
        	GList* r=g_hash_table_get_keys(c->relacoes);
		for(int j=0;j<(int)g_list_length(r);j++){
			char* keyR=g_list_nth_data(r,j);
			Relacoes relacao=g_hash_table_lookup(c->relacoes,keyR);
			GSList* termo = relacao->termos;
			conta += g_slist_length(termo);	
    		}
    	}
	return conta;
	
}

void criarInfo(Thesaurus th){
	fprintf(info, "<!DOCTYPE html>\n<html>\n<head>\n<title>Estatísticas</title>\n</head>\n<body><h1>Estatísticas</h1>\n");
	fprintf(info, "<p>Número de conceitos: %d</p>\n",g_hash_table_size(th->conceitos));
	fprintf(info, "<p>Número de relações: %d</p>\n",contaRelacoes(th));
	fprintf(info, "<p>Número de línguas: %d</p>\n",g_hash_table_size(th->linguas));
	fprintf(info, "<p>Multi-linguístico: ");
	GList* l = g_hash_table_get_keys(th->linguas);
 	for(int i=0;i<(int) g_list_length(l);i++){
        	char* key=g_list_nth_data(l,i);
        	fprintf(info,"%s ",key);
    	}
	
	fprintf(info, "</p><p>Língua base: %s</p>\n",th->lingua);
	fprintf(info, "<p>Número de relações inversas: %d</p>\n",g_hash_table_size(th->inv));
	fprintf(info, "\n<h5><a href=\"home.html\">Home</a></h5>\n");
	fprintf(info,"</body>\n</html>\n");
}

void criarPrincipal(Thesaurus th){
	thg = th;
	home = fopen("Files/home.html","w+"); 
	info = fopen("Files/info.html","w+"); 
	fprintf(home, "<!DOCTYPE html>\n<html>\n<head>\n<title>Home</title>\n</head>\n<body><h1>Home</h1>\n");
	criarInfo(th);
	fprintf(home,"<a href=\"info.html\">%s</a>","Estatísticas");
	fprintf(home, "\n<h3>Indice:</h3>\n");
	fprintf(home,"<meta charset=utf-8>\n");
	fprintf(home,"<table>\n");
	fprintf(home,"<tr>\n<td style=width:200px><b>Nº Tipo de Relações</b></td>\n<td><b>Conceitos</b></td>\n</tr>");
	g_hash_table_foreach(th->conceitos,imprimeConceitos,th);	
	fprintf(home,"</table>\n</body>\n</html>\n");
}



void imprimeRelacoes(gpointer key, gpointer relacao, gpointer conceito){
	Relacoes r = (Relacoes) relacao;
	Conceito c = (Conceito) conceito;
	fprintf(c->f, "<h4>%s</h4><ul>\n", r->tipo);
	GSList* iterator = NULL;
	for (iterator = r->termos; iterator; iterator = iterator->next) {
		char* termo = iterator->data;
		if(g_hash_table_contains(thg->inv,r->tipo))
			fprintf(c->f, "<li><a href=\"%s.html\">%s</a></li>\n", termo,termo);
		else fprintf(c->f, "<li>%s</li>\n", termo);
	}
	fprintf(c->f, "</ul>\n");

}

void criarConceito(gpointer key, gpointer conceito, gpointer thesaurus){
	Conceito c  = (Conceito) conceito;
	fprintf(c->f, "<!DOCTYPE html>\n<html>\n<head>\n<title>%s</title>\n</head>\n<body><h1>%s</h1>\n",c->nome,c->nome);
	Relacoes r = g_hash_table_lookup(c->relacoes,"SN");
	if(r!=NULL){
		char* def = g_slist_last(r->termos)->data;
		fprintf(c->f,"<h3>%s</h3>",def);
	}
	fprintf(c->f, "\n<h3>Relações:</h3>\n");
	g_hash_table_foreach(c->relacoes,imprimeRelacoes,c);	
	fprintf(c->f, "\n<h5><a href=\"home.html\">Home</a></h5>\n");
	fprintf(c->f,"</body>\n</html>\n");

}

void criarConceitos(Thesaurus th){
	g_hash_table_foreach(th->conceitos,criarConceito,th);
}

void adicionaInversa(char* tipo, char* conceito, char* inversa, char* termo, Thesaurus th){
	if(g_hash_table_contains(th->conceitos,termo)){
		Conceito c = g_hash_table_lookup(th->conceitos,termo);
		if(g_hash_table_contains(c->relacoes,inversa)){
			Relacoes relacao = g_hash_table_lookup(c->relacoes,inversa);
			GSList* termos = relacao->termos;
			for(int i=0;i<(int)g_slist_length(termos);i++){
				char* t = g_slist_nth_data(termos,i);
				if(!strcmp(conceito,t)){
					return;
				}
			}
		}
		GSList* ts = g_slist_alloc();
		adicionaTermo(conceito,ts);	
		adicionaRelacao(c->relacoes, inversa, ts);
	}
	else{
		GHashTable* relacoes = g_hash_table_new(g_str_hash,g_str_equal);
		GSList* termos = g_slist_alloc();
		adicionaTermo(conceito,termos);
		adicionaRelacao(relacoes,inversa,termos);
		adicionaConceito(th,strdup(termo),relacoes);
	}
}

void adicionaConceitoInv(Thesaurus th){
	GList* keys=g_hash_table_get_keys(th->conceitos);
	char* inversa;
	Relacoes relacao;Conceito c; int flag = 0;
	for(int i=0;i<(int)g_list_length(keys);i++){
        char* key=g_list_nth_data(keys,i);
       	c=g_hash_table_lookup(th->conceitos,key);
       	GList* r=g_hash_table_get_keys(c->relacoes);
		for(int j=0;j<(int)g_list_length(r);j++){
			flag = 0;
			char* keyR=g_list_nth_data(r,j);
			relacao=g_hash_table_lookup(c->relacoes,keyR);
			if(g_hash_table_contains(th->inv,relacao->tipo))
				inversa = (char*) g_hash_table_lookup(th->inv,relacao->tipo);
			else flag = 1;
    		if(flag==0){
    			GSList* termos = relacao->termos;
				for(int k=0;k<(int)g_slist_length(termos);k++){
					char* termo = g_slist_nth_data(termos,k);	
					adicionaInversa(relacao->tipo,c->nome,inversa,termo,th);
				}
			}
		}
    }
}


