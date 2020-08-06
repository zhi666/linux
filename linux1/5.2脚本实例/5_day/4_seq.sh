#!/bin/bash

# for i in {1..10}; do
    # echo $i
# done

# 产生从10到20的数列
# for i in {10..20}; do
    # echo $i
# done

starts=20
end=30

for i in $(seq $starts $end); do
    echo $i
done

a=(1 2 3 4)
num=123
a[${#a[*]}]=$num
for i in ${a[*]}; do
    echo $i
done
