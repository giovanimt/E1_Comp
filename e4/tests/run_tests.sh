ls s* p* q* |
while read FILE;
  do echo -n "$FILE ";
    ./etapa3 < $FILE > $FILE.out1;
    ./etapa3 < $FILE.out1 > $FILE.out2;
    diff $FILE.out1 $FILE.out2;
    echo $?;
  done;
