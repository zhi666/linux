#!/bin/bash

blackFri () {
    month_array=(0 31 28 31 30 31 30 31 31 30 31 30 31)
    num=0
    for i in {1..12}; do
        mday=${month_array[$[i - 1]]}
        let day+=mday
        [ $i -eq 3 ] && is_year $year && let day+=1
        ((day % 7 == 5)) \
            && echo "$year 年 $i 月 13 日 是黑色星期五! " && let num++
    done
    echo "$year 年一共有 $num 个黑色星期五"
}

main () {
    source /soul/linux/6_shell/tmp/c_homework/lib

    echo "请输入一个年份: "
    read -p "   " year
    day=$(count_year_day 1900 $year)
    let day+=13
    blackFri
}

main
