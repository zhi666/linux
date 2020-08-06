#!/bin/bash
script_dir=$( cd $(dirname "$0") && pwd )
    echo "`date +"%Y-%m-%d-%R"`" >$script_dir/domain.txt
    echo "`date +"%Y-%m-%d-%R"`" >$script_dir/有问题.txt

cat ${script_dir}/domain_ssl.info |while read line;do

    code=`curl https://tool.chinaz.com/pagestatus/?url=https%3A%2F%2F${line}| egrep -o '(<span>[0-9]{1,4}</span>)'|egrep -o '([0-9]{1,4})'`

    if [ $code -ne 200 ] && [ $code -ne 301 ] && [ $code -ne 302 ];then echo "可能有问题的域名是 ${line},状态码是: ${code}" >>${script_dir}/有问题.txt;fi

    echo "检测的域名是 ${line},状态码是: ${code}" >>${script_dir}/domain.txt

done


cat domain.txt | egrep -v '状态码是: [0-9]{3,4}' >> $script_dir/有问题.txt



