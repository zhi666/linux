#!/bin/bash

# 1. cat /etc/passwd > passwd.txt
# 2. 在不知道有多少行的情况下， 在倒数第一行的上面加一行数据

path="./passwd.txt"

cat -n /etc/passwd > $path

finally="$(tail -1 $path)"
num=${finally%%s*}
num1=${num##*\ }
num2=$num1
nuc=${num2%%\ *}
nuc=$(cut -d\  -f1 <<< $nuc)
echo "|$nuc|"
sed -i ""$nuc"i hello world" $path
