%{
#include <stdio.h>
#include "y.tab.h"
%}


MINUSCULAS [(á)(à)(ã)(â)(é)(ê)(í)(õ)(ô)(ó)(ú)(ç)a-z0-9]
MAIUSCULAS [(Á)(À)(Ã)(Â)(É)(Ê)(Í)(Õ)(Ô)(Ó)A-Z] 
%option noyywrap

%%
({MAIUSCULAS}?{MINUSCULAS}+\ *)+   {yylval.t=strdup(yytext);return TERMO;}
{MAIUSCULAS}+  {yylval.t=strdup(yytext);return ID;}

^\n+                            {return LB;}

[,\%]                           {return yytext[0];}

\#.*                            {;}

[.*|\n]                         {;}
				
(.|\n)			{;}

%%
