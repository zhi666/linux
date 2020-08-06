#!/bin/bash

# 1. 提示用户输入一个成绩
# 2. 90及以上为A
# 3. 80-89为B
# 4. 70-79为C
# 5. 70以下为D

echo "请输入一个成绩:"
read -p " " score

if test $score -ge 90; then
    echo "A"
fi

# if [ $score -ge 90 ]; then
    # echo "输入的成绩是  A"
# elif (($score >= 80)); then
    # echo "输入的成绩是  B"
# elif (($score >= 70 )); then
    # echo "输入的成绩是  C"
# elif (($score >= 60)); then
    # echo "输入的成绩是  D"
# else
    # echo "你可以去重考了"
# fi
