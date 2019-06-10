BEGIN {FS=" "; inc=0}
NF==0 {inc++}
NF>0 {
      split($6,pos,"|");

      info[pos[1]] += 1;
      n++;
}

END {
      printf("Número de extratos: %i\n\n", inc);
      printf("============ Estatisticas ============\n");
      for (i in info)
            if (info[i] != 0)
                  printf("\t%s -> %3.2f %\n", i, info[i] *100/n);
}
