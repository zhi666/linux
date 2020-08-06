#!/bin/bash

name1="zhangsan"
name2="lisi"
name3="wangwu"
name4="zhaoliu"

echo ${name1-unknow}
echo ${name2-unknow}
echo ${name3-unknow}
echo ${name4-unknow}
echo "---------------------------------------------------------------------"

unset name2 name4

echo ${name1-unknow}
echo ${name2-unknow}
echo ${name3-unknow}
echo ${name4-unknow}

echo "开始的进程号是: $$"

. ./5_process.sh
source ./5_process.sh

echo $0
echo $1
echo $@
echo $*

echo "hello world"                                              "hao"     \
        "hehe"

