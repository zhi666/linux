#!/bin/bash

ip=$(ip a)

# echo "$ip"

# echo "${ip#*inet}"
# echo "${ip##*inet}"
# echo "${ip%inet*}"
echo "${ip%%inet*}"
echo "${#ip}"
