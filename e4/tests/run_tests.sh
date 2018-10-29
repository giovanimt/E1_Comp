ls s* p* q* |
while read FILE;
  do echo -n "$FILE ";
    ./etapa4 < $FILE;
    echo $?;
  done;
