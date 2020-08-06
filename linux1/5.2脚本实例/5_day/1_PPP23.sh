#!/bin/bash

# 1. 实现一个加法的功能， 输入2个参数， 返回这2个参数的和的36倍
# 2. 实现一个减法的功能， 输入4个参数， 返回这4个参数的差的42倍
# 3. 实现一个乘法的功能， 输入3个参数， 返回这3个参数的42倍，再除以3500
# 4. 实现一个取模的功能， 输入3个参数， 返回第一个参数模以第二个参数，
# 再模以第三个参数

sum () {
    echo "第一个参数: "$1
    echo "第二个参数: "$2
    # add=$((($1 + $2) * 36))
    # add=$(($add * 36))
    let add=($1 + $2)*36
    echo "$add"
}

while : ; do

    echo "这是一个简单的计算器(输入1-4选择功能):"
    echo "  1. 加法功能， 请输入2个参数"
    echo "  2. 减法功能， 请输入4个参数"
    echo "  3. 乘法功能， 请输入3个参数"
    echo "  4. 取模功能， 请输入3个参数"
    num=0

    read -p "   " num

    case "$num" in

        1)
            echo "请输入2个参数"
            read -p " " parameter
            echo "$parameter"
            for i in $parameter; do
                let num++
            done
            # (( num < 2 )) || (( num > 2 )) && echo "输入的参数不对" && break
            ((num != 2)) && echo "输入的参数不对" && continue
            sum $parameter
            ;;
        2)
            echo "减法"
            ;;
        3)
            echo "乘法"
            ;;
        4)
            echo "取模"
            ;;
        *)
            echo "退出"
            exit
            ;;
        esac
done
