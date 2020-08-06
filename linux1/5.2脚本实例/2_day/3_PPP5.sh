#!/bin/bash

# str="hello world hello uplooking hello YW201809"
# 1. 把前3个o替换成O
# 2. 把第4个o替换成O
# 3. 把所有的e替换成E

str="hello world hello uplooking hello YW201809"

str1=${str/o/O}
str1=${str1/o/O}
str1=${str1/o/O}

str2=${str1/o/O}
str2=${str2/O/o}
str2=${str2/O/o}
str2=${str2/O/o}

str3=${str//e/E}

echo "$str1"
echo "$str2"
echo "$str3"
