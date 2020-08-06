#!/bin/bash

echo "1. 只打印/etc/passwd的以s, g, a开头的行"
sed -n '/^[sga]/p' /etc/passwd

echo "2. 输出/etc/passwd有空格的行"
sed -n '/\ /p' /etc/passwd

echo "3. 打印以c为结尾的行"
sed -n '/c$/p' /etc/passwd
