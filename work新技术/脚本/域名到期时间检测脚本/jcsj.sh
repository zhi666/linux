#!/bin/bash
#author:anan
script_dir=$( cd $(dirname "$0") &&pwd)
echo "开始检测时间是  `date "+%Y-%m-%d-%R"`" >${script_dir}/gq.txt
echo "开始检测时间是  `date "+%Y-%m-%d-%R"`" >${script_dir}/无法查询.txt
echo "开始检测时间是  `date "+%Y-%m-%d-%R"`" >${script_dir}/message.txt


cat ${script_dir}/domain_ssl.info|while read line;do

    dq=`curl http://whois.ac/${line} | egrep  '(Expiry Date)'|egrep -o '([0-9]{1,4}-[0-9]{1,2}-[0-9]{1,2})'`
    today=`date "+%Y-%m-%d"`

    time1=$((($(date +%s -d ${dq}) - $(date +%s -d ${today}))/86400))
 #time1表示是从(1970开始至 到期时间的总秒数) -减去 (1970开始 至今天时间的总秒数)/除于一天的总秒，就是等于的时间天数   
  
  if [[ $time1 =~ -18([0-9]){3} ]];then
	
	echo "${line}可能控制器隐藏,无法查询!" >> ${script_dir}/无法查询.txt
	continue	
    elif [ $time1 -lt 50 ];then

	echo "检测的域名是: ${line}  域名还有${time1}天过期" >>${script_dir}/message.txt
    else
    	echo  "检测的域名是：${line}   域名还有${time1}天过期" >>${script_dir}/gq.txt

    fi
done

sh ${script_dir}/message.sh
