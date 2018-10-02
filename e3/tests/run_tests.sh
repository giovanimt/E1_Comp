ls tests/asl* |while read FILE; do echo "$FILE "; cat $FILE | ./etapa3; done;
