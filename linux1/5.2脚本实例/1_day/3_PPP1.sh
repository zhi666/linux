#!/bin/bash

a="c"
b="$a"
c="$a"" hello"
# d=$(ls /tmp)
d=`ls /tmp`
e="2333"
# f=$[ e + 1000 ]
# f=$((e + 1000))
let f=($e + 1000)

echo "$a"
echo "$b"
echo "$c"
echo "$d"
echo "$e"
echo "$f"
