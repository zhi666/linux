#!/bin/bash

# 1. 提示用户"是否想得到一个50-100的随机数(yes/no)"
# 2. 用户输入yes/YES/Y/y, 直接回车, 乱输入都是参加
# 3. 用户输入no/NO/N/No则是不参加
# 4. 参加则打印一个55-99的随机数
# echo $RANDOM
# 5. 不参加则打印欢迎下次来玩

echo "是否想得到一个50-100的随机数(yes/no): "
read -p " " answer

case "$answer" in
    yes|YES|Y|y)
        echo "参加"
        echo "$(($RANDOM % 45 + 55)) "
        ;;
    no|NO|N|n|No)
        echo "欢迎下次来玩哦！"
        ;;
    *)
        echo "参加"
        echo "$(( $RANDOM % 45 + 55 )) "
        ;;
    esac

