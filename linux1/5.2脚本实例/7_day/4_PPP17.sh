#!/bin/bash

# cat -n /etc/passwd > 1_passwd.txt
# 1. 删除每行前面的空格
# 2. 删除第10行的第10个字符到第20个字符
# 3. 删除倒数第10行的倒数第3个到倒数第10个字符
# 4. 删除第20行的第13个字符和第18个字符

path="./1_passwd.txt"
cat -n /etc/passwd > $path
# cat  /etc/passwd > $path

sed -i -r 's/^(\ )+(.*)+$/\2/' $path

sed -n '10p' $path
sed -n '10p' $path | sed -r 's/^(.{9}).{11}(.*)/\1\2/'

sed -r 's/^(.*)(.{8})(..)$/\1\3/'  <<< $(tail $path | head -n 1)

sed -n '20p' $path | sed -r 's/^(.{12}).(.{4}).(.*)/\1\2\3/'
