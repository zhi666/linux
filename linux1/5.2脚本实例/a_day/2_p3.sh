#!/bin/bash

# for i in {1..50}; do
    # sudo useradd test"$i"
# done

for i in {1..50}; do
    sudo userdel -r test$i
done
