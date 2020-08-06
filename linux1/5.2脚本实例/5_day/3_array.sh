#!/bin/bash

a=(1 2 3 4 5)

a1=(6 7 8 9)
a+=a1
num=123

exit
a[1]=123
a+=(6 7 8)
count=${#a[*]}
a+=(10 11 12 13)
count1=${#a[*]}
let count=(count1 + count)
echo $count
exit
unset a[1]
declare -A b
b=(["name1"]="soul" ["name2"]="shell" ["name3"]="hello world")
# echo ${a[-1]}
# echo ${b["name1"]}
# echo ${b["name2"]}
# echo ${b["name3"]}
# echo ${b["name4"]}
# echo ${a[@]}
# echo ${a[*]}
# for i in "${a[@]}"; do
    # echo "$i"
# done

# echo "--------------"

# for i in "${a[@]}"; do
    # echo "${a[$index]}"
    # let index++
# done

for i in $(seq 0 $count); do
    echo "${a[$i]}"
done

# echo "--------------"
# echo ${a[6]}
# echo ${a[0]}
# echo ${a[1]}
# echo ${a[2]}

# echo "--------------"
echo $count


# for i in "${a[*]}"; do
    # echo "$i"
# done

# echo ${#a[@]}
# echo ${#a[*]}

# echo ${!b[@]}
# echo ${!a[@]}

