ls s* p* q* |
while read FILE;
  do echo -n "$FILE ";
    ./etapa4 < $FILE > $FILE.out1;
    ./etapa4 < $FILE.out1 > $FILE.out2;
    diff $FILE.out1 $FILE.out2;
    echo $?;
  done;
