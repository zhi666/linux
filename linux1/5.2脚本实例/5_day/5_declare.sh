#!/bin/bash

# declare -r readonlys="hehe"
# # readonlys="qazxsw"
# echo "$readonlys"

# declare -u max
# max="hello world"
# echo "$max"

# declare -l min
# min="HELLO WORLD"
# echo "$min"

test1 () {
    local a=1
    b=1
    c=$(($b + 1))
}
c=1
echo $a
test1
echo $a
echo $b
echo $c
