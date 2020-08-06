#!/bin/bash

# 1. 接受用户输入的边长
# 2. 根据边长打印这个直角三角形(4种)

echo "请输入要打印的直角三角形的边长: "
read -p " " len

# for ((i = 1; i <= len; i++)); do
    # for ((j = $len; j >= $i; j--)); do
        # echo -n "* "
    # done
    # echo
# done

for ((i = 1; i <= $len; i++)); do
    for ((j = $i; j <= $len; j++  )); do
        echo -n "* "
    done
    echo
done

# * * * * *
# * * * *
# * * *
# * *
# *

echo "---------------------------------"
