#!/bin/bash

# 1. cat /etc/passwd > 1_passwd.txt
    # 交换1_passwd.txt的第二个单词和倒数第二个单词
# 2. 截取出ip地址和掩码
    # 输出结果格式: 192.168.0.183/255.255.255.0

# path="./1_passwd.txt"

# cat /etc/passwd > $path

# sed -i -re 's/^([^a-Z]*)([a-Z]+)([^a-Z]+)([a-Z]+)(.*)(\b[a-Z]+)([^a-Z]+)([a-Z]+$)/\1\2\3\6\5\4\7\8/' "./1_passwd.txt"

export LANG=en_US.UTF-8
export LANGUAGE=en_US:en

link=$(route -n | sed -n '/UG/p' | sed -re 's/(.*)(\b[a-z0-9]+$)/\2/')
ip=$(ifconfig $link | sed -n '/netmask/p' | sed -r 's/^([^0-9]+)([0-9.]+)([^0-9.]+)([0-9.]+)(.*)/\2\/\4/')
echo "$ip"
