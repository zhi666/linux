#!/bin/bash

# 1. 随即数字1-100
# 2. 随机猜数字的最大次数(4-7), 给用户提示还有几次机会
# 3. 猜对了， 提示猜对了
# 4. 猜错的次数到上限提示退出
# 5. 设置用户自由退出

num=$[$RANDOM % 100 + 1]
count=$[$RANDOM % 4 + 4]

echo "这是个猜数字游戏， 数字的范围是(1-100)"
echo "你有$count""次猜数字的机会"
echo "现在开始"
echo "--------------------"
let count--

for ((i = $count; i >= 0; i--)); do
    echo "输入字母(Q/q)退出"
    read -p " " answer

    case $answer in
        $num)
            echo "恭喜你， 猜对了"
            exit
            ;;
        q|Q)
            echo "欢迎下次再来玩哦"
            exit
            ;;
        *)
            echo "猜的不对，请继续努力"
            [ $i == 0 ] && echo "你的猜数字的机会用完了， 欢迎下次再来玩" \
                && echo "正确答案是$num"      \
                || echo "你还有$i""次猜数字的机会"
            ;;
    esac
    # if test "$answer" == $num; then
        # echo "恭喜你， 猜对了"
        # exit
    # elif [ $answer == q ] || [ $answer == Q ]; then
        # echo "欢迎下次再来玩哦"
        # exit
    # else
        # echo "猜的不对，请继续努力"
        # [ $i == 0 ] && echo "你的猜数字的机会用完了， 欢迎下次再来玩" \
            # || echo "你还有$i""次猜数字的机会"
    # fi
done
