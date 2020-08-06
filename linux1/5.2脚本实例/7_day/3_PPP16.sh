#!/bin/bash

# 1. cat /etc/passwd > passwd.txt
# 2. 在不知道有多少行的情况下， 在倒数第一行的上面加一行数据

path="./1_passwd.txt"

cat -n /etc/passwd > $path

# 第一种方法
# sed -i '$i hello world' $path

# 第二种方法
# tac $path > z_passwd.txt
# sed -i '2i hello world' z_passwd.txt
# tac z_passwd.txt > $path
# rm z_passwd.txt

# 第三种方法
row=$(wc -l $path)
echo "$row"
num=$(cut -d\  -f1 <<< $row)
echo "$num"
sed -i ""$num"i hello world" $path

# 第四种方法
# row=$(tail -n 1 $path)

