#!/bin/bash

hello12="hello"

Hello34="Hello"

hello="hello world"
hello1="$hello"

echo "$hello12" "$Hello34"
echo "$hello"
echo "$hello1"


route=$(route -n)
route=`route -n`
echo $route

num1=2333
num2=$((num1+1000))
num3=$[ num1 + 1000 ]

let num1+=1

echo "$num1"
echo "$num2"
echo "$num3"
echo "$num4"

str1="hello world"

unset str1

str2=$str1" shell"" world"

echo "$str2"

