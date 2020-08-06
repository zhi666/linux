#!/bin/bash

# 1. 值为hello world hello uplooking hello YW201811
# 2. name中， 从第3个字符截取16个字符
# 3. name中， 从第7个字符截取到倒数第3个字符
# 4. name中， 从右边第12个字符开始， 截取到最后
# 5. name中， 从右边第12个字符开始， 截取到倒数第3个字符

name="hello world hello uplooking hello YW201811"

echo ${name:2:16}
echo ${name:6:-2}
echo ${name:0-12}
echo ${name:0-12:-2}
