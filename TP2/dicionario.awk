BEGIN { FS=" " }

NF>0 {  
        results[$6][tolower($3)][tolower($2)]++;
}

END {   for(i in results){
            printf("====== %s ======\n", i);       
            for(j in results[i]) 
                for(k in results[i][j]){
                    printf("\t%s -> %s => Nr Ocorrencias: %s\n", j, k, results[i][j][k]);
                }
            printf("\n");
        }
}
