%option noyywrap

%{
#include <string.h>
#include <stdio.h>
#include <glib.h>
FILE *file;
FILE *journal;
FILE *indices;
FILE *tagFile;
char* article;
char* title;
char* category;
char* date;
char* back = "<h6><a href=indices.html>Regressar ao índice</a><h6>";
int existeArticle = 0;
GSList* tagsArticle = NULL;
GHashTable* articles = NULL;
GTree *tags = NULL;

typedef struct listArticles {
    char *article;
    char *title;
} *ListArticles;

ListArticles newArticle(char* a, char* t){
    ListArticles r = (ListArticles) malloc(sizeof(struct listArticles));
    if(r != NULL) {
        r->article = a;
        r->title = t;
    }
    return r;
}

void addArticleTags(char* tag){
	char* newTag = strdup(tag);
	tagsArticle = g_slist_append(tagsArticle, newTag);
}

void addTag(char* tag){
	GSList* l = NULL;
	char* newTag = strdup(tag);
    char* token = (char*) malloc(strlen(newTag)+1);
    token = strtok(newTag,"/");
    if(!strcmp(tag,token)){
	gpointer existe;
	ListArticles a = newArticle(article,title);
	existe = g_tree_lookup(tags,tag);
	if(!existe && (strlen(newTag)>1)){
		l = g_slist_append(l, a);
		g_tree_insert(tags,newTag,l);
	}
	else if (strlen(tag)>1) {
		l = g_tree_lookup(tags,newTag);
		l = g_slist_append(l, a);
		g_tree_replace(tags,newTag,l);
	}
}
}


void addArticle(char* a){
	char* newArticle = strdup(a);
	gpointer existe;
	existe = g_hash_table_lookup (articles,a);
	if(!existe && (strlen(newArticle)>1)){
		g_hash_table_insert(articles, newArticle,newArticle);
	}
	else existeArticle = 1;
}

void createHTML(char* filename){
char* file = (char*)malloc(1+strlen(filename)+strlen(".html"));
	strcpy(file,filename);
	strcat(file,".html");
	yyout = fopen(file,"w"); 
	tagFile = yyout;
}

void createHTMLFile(char* filename){
	article = strdup(filename);
	char* file = (char*)malloc(1+strlen(filename)+strlen(".html"));
	strcpy(file,filename);
	strcat(file,".html");
	yyout = fopen(file,"w"); 
	journal = yyout;
	fprintf(journal,"<meta charset=utf-8>");
}

gboolean createIndice(gpointer k, gpointer v, gpointer d) {
	GSList *iterator = NULL;
	char* tag = strdup(k);
	createHTML(k);
    char* tagHTML = (char*)malloc(1+strlen(k)+strlen(".html"));
	strcpy(tagHTML,k);
	strcat(tagHTML,".html"); 
	fprintf(tagFile, "<!DOCTYPE html>\n<html>\n<head>\n<title>Articles</title>\n</head>\n<body><h1>Articles - %s</h1>\n", tag);
	fprintf(tagFile, "\n<ul><h3>Indice:</h3>\n");
	fprintf(tagFile,"<meta charset=utf-8>");
	int oc = 0;
	char* ref="<td><a href=\"%s\"> %s </a></td>\n";
	fprintf(indices,"<tr>"); ListArticles la;
	for (iterator = v; iterator; iterator = iterator->next) {
		la = iterator->data;
		char* t = strdup(la->title);
		char* l = strdup(la->article);
        char* file = (char*)malloc(1+strlen(l)+strlen(".html"));
	    strcpy(file,l);
	    strcat(file,".html"); 
		fprintf(tagFile,"<h3><li><b>");
	        fprintf(tagFile,ref,file,t);
		fprintf(tagFile,"</b></li></h3>");
		oc++;
	}
	fprintf(tagFile,"</ul>");
	fprintf(tagFile,"</li></b><ul style=padding-left:40px> %s<ul>",back);
	fclose(tagFile);
	fprintf(indices,"<td> %i </td>", oc);
	fprintf(indices,ref,tagHTML,tag);
        fprintf(indices,"</tr>");
    return FALSE;
}

void indice() {
    fprintf(indices,"<table><tr><td style=width:200px><b>Occurrences</b></td><td><b>Tag</b></td></tr>");   
    g_tree_foreach(tags, createIndice, NULL);
    fprintf(indices,"</table>");
}


void articleToHTML(){
	GSList *iterator = NULL;
	addArticle(article);
	if(!existeArticle){
		createHTMLFile(article);
		fprintf(journal, "<link href=style.css rel=stylesheet>\n");
		fprintf(journal, "<pub id=\"%s\">\n",article);
		fprintf(journal, "<title>%s</title>\n",title);
		fprintf(journal, "<h1>%s</h1>\n",title);
		fprintf(journal, "<h2>%s</h2>\n",date);
		fprintf(journal, "<ul>\n<tags>\n");
		for (iterator = tagsArticle; iterator; iterator = iterator->next) {
			char* t = strdup(iterator->data);
			addTag(iterator->data);
	  		fprintf(journal, "<tag>%s</tag> ", t);
		}
		fprintf(journal, "</tags>\n</ul>\n");
		fprintf(journal, "<h3>Categoria: %s</h3>\n",category);
		fprintf(journal, "<text>\n");
	}
	tagsArticle = NULL;
}

void textToHTML(char* texto){
	if(!existeArticle)
		fprintf(journal,"%s",texto);
}

gboolean comparator(gconstpointer a, gconstpointer b){
	if(strcmp(a,b)==0) return TRUE; 
	else return FALSE;
}

%}
%x DEFtag DEFchavetas DEFid DEFespaco DEFcategoria DEFdata DEFparenteses DEFtitulo DEFtexto DEFx DEFim
%%

	file = fopen("pl.txt","r");

TAG[ ]*:[ ]*                { ;}
tag[ ]*:[ ]*  	       		{ BEGIN DEFtag; }
<DEFtag>\{                  { BEGIN DEFchavetas;}
<DEFchavetas>[ ]*\}         { BEGIN INITIAL; }
<DEFchavetas>[ \n\t\r]+     { ;}
<DEFchavetas>[^\{}]+        { addArticleTags(yytext);}

ID[ ]*:[ ]*                 { BEGIN DEFid;}
<DEFid>\{                   { BEGIN DEFespaco;}
<DEFespaco>[ ]              { BEGIN INITIAL; }
<DEFespaco>[^\{ ]+          { article = strdup(yytext);}

\}[ \t\n]*                  { BEGIN DEFcategoria;}
<DEFcategoria>[^\t\n]+		{ category = strdup(yytext); BEGIN DEFtitulo; }

<DEFtitulo>[^\n]+			{ title = strdup(yytext); BEGIN INITIAL; }

DATE[ ]*:[ ]*               { BEGIN DEFdata;}
<DEFdata>\[[^\]]+\]               { BEGIN DEFparenteses; }
<DEFparenteses>[\n]         { BEGIN INITIAL;}
<DEFparenteses>[^\]\n]+     { date = strdup(yytext); articleToHTML(); BEGIN DEFtexto; }

<DEFtexto>\[[^\]]+\]+        { ; }
<DEFtexto>[^\n]+			{ textToHTML(yytext); BEGIN DEFx;  }

<DEFx>.					{textToHTML(yytext); BEGIN DEFtexto;}
<DEFx>Etiquetas[ ]*:[ ]*       {BEGIN INITIAL;}


<*>\<\/pub\>         {BEGIN INITIAL; if(!existeArticle) fprintf(journal, "</text>\n%s\n</pub>\n",back); existeArticle = 0;}
(.|\n)                       { ; }
%%


int main(int argc, char* argv[]){
	tags = g_tree_new((GCompareFunc)g_ascii_strcasecmp);
	articles = g_hash_table_new (g_str_hash, g_str_equal);
	yylex();
	indices = fopen("indices.html", "w");
    	if (indices == NULL) {
        	printf("Erro ao abrir o ficheiro\n");
        return 1;}
	fprintf(indices, "<!DOCTYPE html>\n<html>\n<head>\n<meta charset=utf-8>\n<title>Tags</title>\n</head>\n<body><h1>Tags</h1>\n");
	yylex();

    indice();

    fprintf(indices, "</body>\n</html>\n");
    fclose(indices); 
    
	return 0;
}
