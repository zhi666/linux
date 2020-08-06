#!/bin/bash

# 1. 替换
    # 2018/9/1
    # 2011/10/23
    # 2020/12/12
    # 2023/1/1
    # 替换成2018 09 01
# 2. cat /etc/passwd > 1_passwd.txt
    # 打印倒数第5行和倒数第10行的倒数第5个字符
    # 把倒数第20行的倒数第12个字符换成倒数第25行的倒数第10个字符

# while : ; do
    # echo "请输入一个日期(格式为：2018/8/1): "
    # read -p "  " date
    # sed -re 's/([/])/\ /g' <<< $date  | sed -re 's/([ ])([0-9])\b/\ 0\2/g'
# done

# 把倒数第20行的倒数第12个字符换成倒数第25行的倒数第10个字符


#创建文件
path="./1_passwd.txt"
cat /etc/passwd > "$path"

num=$(wc -l $path | sed -re 's/^([0-9]+)(.*)/\1/')

let num_5=(num - 4)
sed -n ""$num_5"p" "$path" | sed -re 's/(.*)(.)(.{4})$/\2/'

let num_10=(num - 9)
sed -n ""$num_10"p" "$path" | sed -re 's/(.*)(.)(.{4})$/\2/'

let num_20=(num - 19)
str_20_12=$(sed -n ""$num_20"p" "$path" | sed -re 's/^(.*)(.)(.{11})$/\2/')
echo "$str_20_12"

let num_25=(num - 24)
str_25_10=$(sed -n ""$num_25"p" "$path" | sed -re 's/^(.*)(.)(.{9})$/\2/')

str_20=$(sed -n ""$num_20"p" "$path")
new_str_20=$(sed -re "s/(.)(.{11}$)/$str_25_10\2/" <<< $str_20)
sed -i ""$num_20"d" "$path"
sed -i ""$num_20"i $new_str_20" $path
echo "$new_str_20"


str_25=$(sed -n ""$num_25"p" "$path")
new_str_25=$(sed -re "s/(.)(.{9}$)/$str_20_12\2/" <<< $str_25)
sed -i ""$num_25"d" "$path"
sed -i ""$num_25"i $new_str_25" $path
echo "$new_str_25"
