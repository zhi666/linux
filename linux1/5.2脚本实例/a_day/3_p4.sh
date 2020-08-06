#!/bin/bash

echo "请输入一个文件路径： "
read -p "  " path

test -f $path && mv $path "/test/$path" || cp $path "/tmp/" -rf
