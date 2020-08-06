#!/bin/bash

# 1. 提示用户输入一个名字
# 2. 输入的超时时间为5s
# 3. 提示用户输入一个4位的数字id，多余的字符去除
# 4. 输入的超时时间为5s
# 5. 提示用户输入一个6位的密码，多于的字符去除
# 6. 输入用户的信息
# 7. 用户名前面有5个*，后面有5个*
# 8. id前面有5个空格， 后面有10个空格， 在后面加上"uid"
# 9. 密码明文显示

echo "请输入你的名字: "
read -t 5 -p " " name

echo "请输入一个4位数字的id: "
read -t 5 -n 4 -p " " uid

echo

echo "请输入一个6位数字的密码: "
read -n 6 -s -p " " passwd

echo -en  "*****""$name""*****"
printf "%9d" $uid
printf "%10c" " "
printf "uid\n"
echo "密码是: "$passwd


