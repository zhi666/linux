#!/bin/bash

# function test1 () {
    # echo "这是一个函数"
# }

# test1

# test2 () {
    # exit 123
    # echo $str
    # str="这也是一个简单的函数"
    # echo "$str"
    # str2="第一次修改"
    # return "254455"
    # str2="第二次修改"
# }

# str2="hello"
# echo "$str2"
# test2
# echo $?
# echo $str2

# result=$(test2)
# echo "$result"

test3 () {
    echo $0
    echo $1
    echo $2
    echo $3
    echo $@
    echo $*
    echo "----------------"
    for i in "$*"; do
        echo "$i"
    done
    for i in "$@"; do
        echo "$i"
    done
}

test3 1 2 3 4 5 6
