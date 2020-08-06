#!/bin/bash
number=`/usr/bin/free -h | /usr/bin/grep Mem  | /usr/bin/awk '{print $6}'|cut -c 1-3`
number1=300

if [ $number -gt $number1 ];then
	echo 1 > /proc/sys/vm/drop_caches 
	echo 2 > /proc/sys/vm/drop_caches
	echo 3 > /proc/sys/vm/drop_caches
else
	exit 0
fi
