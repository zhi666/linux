#!/bin/bash

weekday () {
    month_array=(0 31 28 31 30 31 30 31 31 30 31 30 31)
    year=$(date +%Y)
    month=$(date +%m)
    day=$(date +%d)

    echo "$year" " " "$month" " " "$day"
    is_year $year && month_array[2]=29
    mdays=${month_array[$month]}

    # 计算这个月的第一天是星期几
    week=$(date -d "$year-$month-01" +%u)
    let week+=1
    printf "%*s%s %d\n" 5 "" $(date +%B) $year
    echo -e "\033[31m日\033[0m 一 二 三 四 五 \033[31m六\033[0m"

    i=1
    for row in {1..6}; do
        for col in {1..7}; do
            if (($row == 1 && $col < week)); then
                printf "%2c " " "
            else
                if (($i <= $mdays)); then
                    if (($col >= 7 || $col == 1)); then
                        printf "\033[31;1m%2d \033[0m" $i
                    elif (($i == $day)); then
                        printf "\033[41;37;1m%2d\033[0m" $i
                        printf " "
                    else
                        printf "%2d " $i
                    fi
                fi
                let i++
            fi
        done
        echo
    done
}

main () {
    source ./lib
    weekday
    echo "请输入要查询的年月: "
    read -p " " dates
}

main
