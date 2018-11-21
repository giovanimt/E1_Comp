ls ijk?? |
while read i; do
    ../etapa5 < $i > $i.iloc
    export data=`cat eval.txt |grep $i |grep data |cut -d '|' -f4`;
    export stack=`cat eval.txt |grep $i |grep stack |cut -d '|' -f4`;
    ./ilocsim.py -m $i.iloc --stack $stack --data $data > $i.out;
done

