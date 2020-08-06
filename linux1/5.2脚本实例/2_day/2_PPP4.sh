#!/bin/bash

export LANG=en_US.UTF-8
export LANGUAGE=en_US:en

route=$(route -n)
route=$(echo "$route" | grep UG)
route=${route##* }

ip=$(ip a | grep "$route")
ip=${ip#*inet }
ip=${ip% brd*}

echo "|$ip|"
