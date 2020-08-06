#!/bin/bash

a="0 "
b="1 "

echo -ne "\033[2J"
echo -ne "\033[?25l"
echo -ne "\033[50A"
echo -ne "\033[1m"
echo -ne "\033[5m"
while : ; do
    echo -ne "\033[;32m$a\033[0m"
    echo -ne "\033[;32m$b\033[0m"
    sleep 0.003
done
echo -ne "\033[?25h"
