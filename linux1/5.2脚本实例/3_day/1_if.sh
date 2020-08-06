#!/bin/bash

num1="123"
num2="456"

# if test $1 = $2; then
    # echo " 第一个参数和第二个参数相等"
# else
    # echo " 第一个参数和第二个参数不相等"
# fi

# if [ $1 = $2 ]; then
    # echo " 第一个参数和第二个参数相等"
# else
    # echo " 第一个参数和第二个参数不相等"

# fi

if test -z $1; then
    exit
fi

if (( $1 == $2 )); then
    echo " 第一个参数和第二个参数相等"
else
    echo " 第一个参数和第二个参数不相等"
fi

# if [[ $1 == $2 ]]; then
    # echo " 第一个参数和第二个参数相等"
# else
    # echo " 第一个参数和第二个参数不相等"
# fi
