BEGIN {FS=" "}
$6 ~/pos=verb.+/ {
    split($6,pos,"|"); 
    for(i in pos)
        if(pos[i] ~ /tense=.+/){
            split(pos[i], p, "=");
            tempos[p[2]]++;
            break;        
        }
}
$6 ~/pos=noun.+/ {
    split($6,pos,"|"); 
    for(i in pos)
        if(pos[i] ~ /type=.+/){
            split(pos[i], p, "=");
            tipos[p[2]]++;
            break;        
        }
}
$6 ~/pos=adjective.+/ {
 split($6,pos,"|"); 
    for(i in pos)
        if(pos[i] ~ /type=.+/){
            split(pos[i], p, "=");
            types[p[2]]++;
            break;        
        }
}

END{
    print "<html>\n<meta charset=\"UTF-8\">" > "ocorrencias.html";
    print "<h4> Verbos </h4><table border=1>" > "ocorrencias.html";
    print "<tr><td width=50%><b>Ocorrências</b></td><td><b>Tempo</b></td><tr>" > "ocorrencias.html";
    for(i in tempos){
       print "<tr><td width=50%>", tempos[i], "</td><td>", i, "</td><tr>" > "ocorrencias.html";
    }  
    print "</table>\n" > "ocorrencias.html" 
    print "<h4> Substantivos </h4>" > "ocorrencias.html";
    print "<table border=1>" > "ocorrencias.html";
    print "<tr><td width=50%><b>Ocorrências</b></td><td><b>Tipo</b></td><tr>" > "ocorrencias.html";
    for(i in tipos){
       print "<tr><td width=50%>", tipos[i], "</td><td>", i, "</td><tr>" > "ocorrencias.html";
    }  
    print "</table>\n" > "ocorrencias.html";
    print "<h4> Adjetivos </h4>" > "ocorrencias.html";
    print "<table border=1>" > "ocorrencias.html";
    print "<tr><td width=50%><b>Ocorrências</b></td><td><b>Tipo</b></td><tr>" > "ocorrencias.html";
    for(i in types){
       print "<tr><td width=50%>", types[i], "</td><td>", i, "</td><tr>" > "ocorrencias.html";
    }  
    print "</table>\n</html>" > "ocorrencias.html"
}
