#!/bin/bash

if test -z $1; then
    echo "请输入一个文件路径作为参数"
    exit
fi

# if test -e "$1"; then
    # echo $1"文件存在"
# else
    # echo $1"文件不存在"
# fi

# if test -r "$1"; then
    # echo $1"文件可读"
# else
    # echo $1"文件不可读"
# fi

# if test -w "$1"; then
    # echo $1"文件可写入"
# else
    # echo $1"文件不可写入"
# fi

# if test -x "$1"; then
    # echo $1"文件可执行"
# else
    # echo $1"文件不可执行"
# fi

# if test -d "$1"; then
    # echo $1"是一个文件夹"
# else
    # echo $1"不是一个文件夹"
# fi

# if test -f "$1"; then
    # echo $1"是一个普通文件"
# else
    # echo $1"不是一个普通文件"
# fi

if [ -s "$1" ]; then
    echo $1"里面有内容"
else
    echo $1"里面没内容"
fi
