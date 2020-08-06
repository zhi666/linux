#!/bin/bash

script_dir=$( cd $(dirname "$0") && pwd )

line=`wc -l ${script_dir}/zjjc.txt | awk '{ print $1}'`

sed -i '2i\以下为域名证书到期时间' ${script_dir}/zjjc.txt

if [ $line -gt 1 ];then

curl -X POST "https://api.telegram.org/bot1036155060:AAGy9RKxmeRqvK42pWabHJrKorBs0kz6fn4/sendMessage" -d "chat_id=-326531556&text=`head -100 ${script_dir}/zjjc.txt`"

fi


if [ $line -gt 100 ];then

curl -X POST "https://api.telegram.org/bot1036155060:AAGy9RKxmeRqvK42pWabHJrKorBs0kz6fn4/sendMessage" -d "chat_id=-326531556&text=`sed -n '101,200p' ${script_dir}/zjjc.txt`"

fi

if [ $line -gt 200 ];then

curl -X POST "https://api.telegram.org/bot1036155060:AAGy9RKxmeRqvK42pWabHJrKorBs0kz6fn4/sendMessage" -d "chat_id=-326531556&text=`sed -n '201,300p' ${script_dir}/zjjc.txt`"


fi

if [ $line -gt 300 ];then

curl -X POST "https://api.telegram.org/bot1036155060:AAGy9RKxmeRqvK42pWabHJrKorBs0kz6fn4/sendMessage" -d "chat_id=-326531556&text=`sed -n '301,400p' ${script_dir}/zjjc.txt`"

fi

if [ $line -gt 400 ];then

curl -X POST "https://api.telegram.org/bot1036155060:AAGy9RKxmeRqvK42pWabHJrKorBs0kz6fn4/sendMessage" -d "chat_id=-326531556&text=`sed -n '401,500p' ${script_dir}/zjjc.txt`"

fi

if [ $line -gt 500 ];then

curl -X POST "https://api.telegram.org/bot1036155060:AAGy9RKxmeRqvK42pWabHJrKorBs0kz6fn4/sendMessage" -d "chat_id=-326531556&text=`sed -n '501,600p' ${script_dir}/zjjc.txt`"

fi

if [ $line -gt 600 ];then

curl -X POST "https://api.telegram.org/bot1036155060:AAGy9RKxmeRqvK42pWabHJrKorBs0kz6fn4/sendMessage" -d "chat_id=-326531556&text=`sed -n '601,700p' ${script_dir}/zjjc.txt`"

fi

if [ $line -gt 700 ];then

curl -X POST "https://api.telegram.org/bot1036155060:AAGy9RKxmeRqvK42pWabHJrKorBs0kz6fn4/sendMessage" -d "chat_id=-326531556&text=`sed -n '701,800p' ${script_dir}/zjjc.txt`"

fi

if [ $line -gt 800 ];then

curl -X POST "https://api.telegram.org/bot1036155060:AAGy9RKxmeRqvK42pWabHJrKorBs0kz6fn4/sendMessage" -d "chat_id=-326531556&text=`sed -n '801,900p' ${script_dir}/zjjc.txt`"

fi

if [ $line -gt 900 ];then

curl -X POST "https://api.telegram.org/bot1036155060:AAGy9RKxmeRqvK42pWabHJrKorBs0kz6fn4/sendMessage" -d "chat_id=-326531556&text=`sed -n '901,1000p' ${script_dir}/zjjc.txt`"

fi

sed -i '1i\以下为被墙或没有证书\n' ${script_dir}/被墙或没有证书

curl -X POST "https://api.telegram.org/bot1036155060:AAGy9RKxmeRqvK42pWabHJrKorBs0kz6fn4/sendMessage" -d "chat_id=-326531556&text= `cat ${script_dir}/被墙或没有证书`"


sed -i '1i\以下为没有dns解析\n' ${script_dir}/没有dns解析

curl -X POST "https://api.telegram.org/bot1036155060:AAGy9RKxmeRqvK42pWabHJrKorBs0kz6fn4/sendMessage" -d "chat_id=-326531556&text= `cat ${script_dir}/没有dns解析`"

sed -i '1i\以下为无法正常访问\n' ${script_dir}/无法正常访问

curl -X POST "https://api.telegram.org/bot1036155060:AAGy9RKxmeRqvK42pWabHJrKorBs0kz6fn4/sendMessage" -d "chat_id=-326531556&text= `cat ${script_dir}/无法正常访问`"

rm -rf ${script_dir}/未过滤.txt  
rm -rf ${script_dir}/被墙或没有证书  
rm -rf ${script_dir}/无法正常访问 
rm -rf ${script_dir}/zjjc.txt 
rm -rf ${script_dir}/没有dns解析 
rm -rf ${script_dir}/jc.txt
