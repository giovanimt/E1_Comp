ls tests/asl* |while read FILE; do echo "$FILE "; cat $FILE | ./etapa2; done;
