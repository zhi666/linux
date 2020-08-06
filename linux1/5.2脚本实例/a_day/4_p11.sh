#!/bin/bash

path="./1_passwd.txt"
cat /etc/passwd > $path
# 1
# sed -i -re 's/(.*)..$/\1/' $path

# 2
sed -i -re 's/(..)(.)(.*)(.)$/\1\4\3\2/' $path

# 3

