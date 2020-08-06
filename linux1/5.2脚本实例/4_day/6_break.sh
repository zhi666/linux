#!/bin/bash

# echo "输入要循环多少次： "
# read -p " " num

# count=0

# while (($count <= $num)); do
    # let count++
    # case $count in
        # 3)
            # echo "打印到第三次的时候就不打印了"
            # continue
            # echo "continue后面的还打印么？"
            # ;;
        # 7)
            # echo "这是第7次， 打印完这个之后就不打印了"
            # # break
            # echo "break之后还会打印么？"
            # ;;
        # *)
            # echo "hello, $count"
            # ;;
    # esac
    # echo "hehe"
# done

# for ((i = 0; i < 5; i++)); do
    # echo $i
# done

for i in "$*"; do
    echo "$i"
done
echo "--------------------------"
for i in "$@"; do
    echo "$i"
done
