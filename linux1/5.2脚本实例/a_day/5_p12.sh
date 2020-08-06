#!/bin/bash

# 1
# find /etc -perm 644 -size +4M -size -10M -user root

# 2
# cat -n /etc/passwd | grep -e 'root' -e 'nfs'
# cat -n /etc/passwd | egrep '(root)|(nfs)'

# 3
# grep -A 2 -B 3 root /etc/passwd

# 4
# sed -i '3i hello world' 1_passwd.txt

# 5
sed -i 's/root/hello/g' 1_passwd.txt

# 6
awk -F ":" 'NF > 3 {print $0}' 1_passwd.txt
