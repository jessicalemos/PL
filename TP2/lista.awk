BEGIN {FS=" "}
$6 ~/pos=verb.+/ {verb[tolower($2)]++;}
$6 ~/pos=noun.+/ {subs[tolower($2)]++;}
$6 ~/pos=adjective.+/ {adj[tolower($2)]++;}
$6 ~/pos=adposition.+/ {adv[tolower($2)]++;}

END{
    n = asorti(verb, ord)
    print "<html>\n<meta charset=\"UTF-8\"><h1> Verbos </h1>\n<table border=1>" > "verbos.html";
    for(i in ord){
       print "<tr><td width=50%>", ord[i], "</td><td>", verb[ord[i]], "</td><tr>" > "verbos.html";
    }   
    n = asorti(subs, ord)
    print "</table>\n</html>" > "verbos.html"
    print "<html>\n<meta charset=\"UTF-8\"><h1> Substantivos </h1>\n<table border=1>" > "substantivos.html";
    for(i in ord){
       print "<tr><td width=50%>", ord[i], "</td><td>", subs[ord[i]], "</td><tr>" > "substantivos.html";
    }
    n = asorti(adj, ord)
    print "</table>\n</html>" > "substantivos.html"
    print "<html>\n<meta charset=\"UTF-8\"><h1> Adjetivos </h1>\n<table border=1>" > "adjetivos.html";
    for(i in ord){
       print "<tr><td width=50%>", ord[i], "</td><td>", adj[ord[i]], "</td><tr>" > "adjetivos.html";
    }
    n = asorti(adv, ord)
    print "</table>\n</html>" > "adjetivos.html"
    print "<html>\n<meta charset=\"UTF-8\"><h1> Adverbios </h1>\n<table border=1>" > "adverbios.html";
    for(i in ord){
       print "<tr><td width=50%>", ord[i], "</td><td>", adv[ord[i]], "</td><tr>" > "adverbios.html";
    }
    print "</table>\n</html>" > "adverbios.html"
}
