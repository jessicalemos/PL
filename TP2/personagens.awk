BEGIN {FS=" "; n=0}
NF>0 {
    if($6=="pos=noun|type=proper")
        nomes[$2]++;
}
END{
for(i in nomes){print nomes[i], i | "sort -n -r"; n++}
printf("Número total de personagens: %d\n\n", n);
}
