#!/bin/bash

echo "请输入要打印的三角形的边长: "
read -p "  " num
egrep -q '^[0-9]+$' <<< $num || exit 1

for i in $(seq 0 $[$num * $num -1]); do
    row=$[i / num]
    col=$[i % num]
    (($col <= $row)) &&  echo -n " * " || echo -n "  "
    (($col == ($num - 1))) && echo
done


