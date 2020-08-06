#!/bin/bash

# is_num () {
    # egrep -qn '^[0-9]+$' <<< $1 && return 0 || return 1
# }

# is_year () {
    # local year=$1
    # is_num $year || return 2
    # (($year % 400 == 0 || $year % 4 == 0 && $year % 100 != 0 )) \
        # && echo "输入的年份是闰年"  || echo "输入的年份不是闰年"
# }

source /soul/linux/6_shell/tmp/c_homework/lib

echo "请输入一个年份， 我能告诉你是不是闰年"
read -p "   " year
is_year $year && echo "输入的年份是闰年" || echo "输入的年份不是闰年"
