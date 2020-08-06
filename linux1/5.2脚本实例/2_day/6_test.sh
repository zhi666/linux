#!/bin/bash

ls
echo $?

ls sadfg
echo $?

# echo -n "这个是不换行的"
echo -e "这个是不换行的\c"
echo

num=123

printf "%10d\n" $num
printf "%-10dsfs\n" $num
printf "%010d\n" $num

float=10.127456789

printf "%10.2f\n" $float
printf "%010.2f\n" $float
printf "%-10.2ffff\n" $float


# read -sp "请输入一个数字: " num1
read -n 5 -t 3 -p "请输入一个数字: " num1
# echo "请输入一个数字: "
# read -p " "
echo $REPLY
