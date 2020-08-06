#!/bin/bash

# str="hello world hello uplooking hello YW201809"
# 1. 把前3个o替换成O
# 2. 把第4个o替换成O
# 3. 把所有的e替换成E

str="hello world hello uplooking hello YW201809"

str1=$str
for ((i=0; i < 3; i++)); do
    str1=${str1/o/O}
done

echo "$str1"

for ((i=0; i < 1; i++)); do
    str2=${str1/o/O}
    for ((j=0; j<3; j++ )); do
        str2=${str2/O/o}
    done
done

echo "$str2"

str3=${str//e/E}
echo "$str3"
