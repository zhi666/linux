#!/bin/bash

. /soul/linux/6_shell/tmp/9_day/6_say_hello.sh
hello

cat /etc/passwd > 1_passwd.txt
path="./1_passwd.txt"

# 1. 打印uid在800到1000之间的用户名
# awk -F ":" '($3 >= 800 && $3 <= 1000) {print $1}' $path

# 2. 打印第6行到第9行
# awk '(NR >= 6 && NR <= 9){print $0}' $path

# 3. 打印/etc/passwd第5行和第9行的累积字段和当前行号
    # 5   20
    # 9   60
# awk -F ":" 'BEGIN{count=0}{count+=NF}(NR == 5 || NR == 9){print NR "\t" count}'  $path

# 4. 打印/etc/passwd倒数第3列的数据
# awk -F ":" '{print $((NF -2))}' $path

# 5. 打印/etc/passwd倒数第10行的倒数第3个字段
# tail $path | head -n 1 | awk -F ":" '{print $((NF - 2))}'
cat -n /etc/passwd > 1_passwd.txt
# 6. 替换1_passwd.txt倒数第三行的倒数第2个字段和倒数第10行的倒数第3个字段
num=$(awk 'END{print NR}' $path)
echo "$num"
let num_3=(num - 2)
let num_10=(num - 9)
# echo "$num_3" "|" "$num_10"

replace () {

    str_3_2=$(awk '( NR == '$num_3') {print $0}' $path | awk -F ":" '{print $((NF - 1))}')
    str_10_3=$(awk '( NR == '$num_10') {print $0}' $path | awk -F ":" '{print $((NF - 2))}')
    # echo "$str_3_2" "  "  "$str_10_3"

    # 原文件的倒数第3行
    old_str3=$(tail -n 3 $path | head -n 1)
    echo "$old_str3"
    # 把原文件的倒数第3行的倒数第2个字段换成倒数第10行的倒数第3个字段
    # new_str_3=$(sed -re "s/(.*):(.*):(.*):(.*)$/\1:\2:$str_10_3:\4/" <<< $old_str3)
    new_str_3=$(sed -re "s/^([0-9]+)([^a-Z0-9]?)(.*):(.*):(.*):(.*)$/\1\  \3\4:$str_10_3:\6/" <<< $old_str3)
    echo "$new_str_3"
    new_str_3="\ \ \ \ "$new_str_3

    sed -i ""$num_3"d" $path
    sed -i ""$num_3"i $new_str_3" $path


    # 原文件的倒数第10行
    old_str_10=$(tail -n 10 $path | head -n 1)
    echo "$old_str_10"
    echo "$str_3_2"
    # str_3_2="/var"
    # 因为字符串里面的/或造成下面替换程序的错误
    #    所以在这里要把/替换成\/
    str_3_2=${str_3_2//\//\\/}
    echo "$str_3_2"

    # 把原文件的倒数第10行的倒数第3个字段换成倒数第3行的倒数第2个字段
    # new_str_3=$(sed -re "s/(.*):(.*):(.*):(.*)$/\1:\2:$str_10_3:\4/" <<< $old_str3)
    new_str_10=$(sed -re 's/^([0-9]+)([^a-Z0-9]?)(.*):(.*):(.*):(.*)$/\1\  \3:'$str_3_2':\5:\6/' <<< $old_str_10)
    echo "$new_str_10"
    new_str_10="\ \ \ \ "$new_str_10

    sed -i ""$num_10"d" $path
    sed -i ""$num_10"i $new_str_10" $path
}

# replace
# exit

# 7. 删除1_passwd.txt倒数第3行的第3列数据
old_str_3_7=$(awk -F ":" '(NR == '$num_3') {print $0}' $path)
new_str_3_7=$(sed -re 's/[0-9a-Z/ ]+//3' <<< $old_str_3_7)
# new_str_3_7=$(sed -re 's/^([0-9a-Z /]+):(\b.*):(.*):(.*):(.*)/\1:\2:\4:\5/' <<< $old_str_3_7)
new_str_3_7="\ \ \ \ "$new_str_3_7
echo "$new_str_3_7"
new_str_3_7=$(sed -re 's/^([ \]+)([0-9]+)(.*)/\1\2\ \3/' <<< $new_str_3_7)
# new_str_3_7=$(sed -re 's/^([0-9 \]+)')

sed -i ""$num_3"d" $path
sed -i ""$num_3"i $new_str_3_7" $path



