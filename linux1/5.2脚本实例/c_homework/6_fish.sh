#!/bin/bash

judge_day () {
    is_num $endDay

    (($? == 1 || $endDay < 1 || $endDay > 31)) \
        && echo "请输入一个正确的日子" && exit
    case $endDay in
        2)
            (($endDay > 29)) && echo "2月没有大于29的日子" && exit 1
            is_year $endYear
            (($? == 1)) && (( $endDay > 28)) \
                && echo "输入的年份不是闰年， 2月没有29天" && exit 1
            ;;
        4|6|9|11)
            (($endDay > 30)) && echo "小月没得31号" && exit 1
            ;;
    esac
}

count_month_day () {
    month_array=(0 31 28 31 30 31 30 31 31 30 31 30 31)
    local year=$1 month=$2 days=0
    ((month > 2)) && is_year $year && let days++
    while [ $month -gt 1 ]; do
        let month--
        mdays=${month_array[$month]}
        let days+=mdays
    done
    echo $days
}

judge () {
    echo "请输入要计算的年月日，以空格隔开， 计算老王在这一天是在打渔还是在晒网"
    read -p "   " date
    endYear=$(awk '{print $1}' <<< "$date")
    endMonth=$(awk '{print $2}' <<< "$date")
    endDay=$(awk '{print $3}' <<< "$date")

    is_num $endYear || exit
    is_num $endMonth || echo "月份不是纯数字"
    ((endMonth < 0 || endMonth > 12)) && echo "月份不对"
    judge_day

    yearDays=$(count_year_day $startYear $endYear)
    monthDay=$(count_month_day $endYear $endMonth)
    resultDays=$[ yearDays + monthDay + endDay ]
    echo "$resultDays"
    let resultDays%=5
    echo "$resultDays"
    (($resultDays > 0 && $resultDays < 4 )) && echo "打渔" || echo "晒网"
}


main () {
    # source /soul/linux/6_shell/tmp/c_homework/lib
    source ./lib
    startYear="2000"
    startMonth="1"
    startDay="1"

    judge

}

main
