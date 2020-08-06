#!/bin/bash

num=10

until ((num < 0)); do
    echo $num
    let num--
done
