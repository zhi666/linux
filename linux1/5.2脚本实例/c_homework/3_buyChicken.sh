#!/bin/bash

for i in {0..20}; do
    for j in {0..33}; do
        k=$[100 - i -j]
        ((k % 3 == 0 && i * 5 + j * 3 + k / 3 == 100)) \
            && echo "公鸡：${i}  母鸡：${j} 小鸡： ${k}"
    done
done
