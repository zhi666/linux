#!/bin/bash

# 找出在根目录下， 所属用户是root的， 大于1M,
    # 且权限是644的普通文件，屏蔽错误输出
# 练习find命令
    # 大小， 所属用户[组]， 文件类型， 名字(模糊搜索)
# 用ls -hl格式化输出


# 找出在根目录下， 所属用户是root的， 大于1M,
find / -user root -size +1M -perm 644 -type f 2> /dev/null
    # 且权限是644的普通文件，屏蔽错误输出
# 练习find命令
    # 大小， 所属用户[组]， 文件类型， 名字(模糊搜索)
find /soul -iname *.txt
# 用ls -hl格式化输出上条命令的结果
find /soul -iname *.txt -exec ls -hl "{}" \;




