#!/bin/bash

test -z $1 && echo "请输入一个数字" && exit

case "$1" in
    A|a)
        echo "是a|A"
        ;;
    B|b)
        echo "是b|B"
        ;;
    C|c)
        echo "是c|C"
        ;;
    *)
        echo "不是a，b， c"
        ;;
esac
