#!/bin/bash

script_dir=$( cd $(dirname "$0") && pwd )

line=`wc -l ${script_dir}/message.txt | awk '{ print $1}'`

sed -i '2i\以下为50天内过期的域名' ${script_dir}/message.txt

if [ "$line" -gt 1 ];then

curl -X POST "https://api.telegram.org/bot709759784:AAF2Tff_lKOBLIXHPzfoM1WHQkXt-SqkAqo/sendMessage" -d "chat_id=-377237859&text=`head -100 ${script_dir}/message.txt`"

fi


if [ "$line" -gt 100 ];then

curl -X POST "https://api.telegram.org/bot709759784:AAF2Tff_lKOBLIXHPzfoM1WHQkXt-SqkAqo/sendMessage" -d "chat_id=-377237859&text=`sed -n '101,200p' ${script_dir}/message.txt`"

fi

if [ "$line" -gt 200 ];then

curl -X POST "https://api.telegram.org/bot709759784:AAF2Tff_lKOBLIXHPzfoM1WHQkXt-SqkAqo/sendMessage" -d "chat_id=-377237859&text=`sed -n '201,300p' ${script_dir}/message.txt`"


fi

if [ "$line" -gt 300 ];then

curl -X POST "https://api.telegram.org/bot709759784:AAF2Tff_lKOBLIXHPzfoM1WHQkXt-SqkAqo/sendMessage" -d "chat_id=-377237859&text=`sed -n '301,400p' ${script_dir}/message.txt`"

fi

if [ "$line" -gt 400 ];then

curl -X POST "https://api.telegram.org/bot709759784:AAF2Tff_lKOBLIXHPzfoM1WHQkXt-SqkAqo/sendMessage" -d "chat_id=-377237859&text=`sed -n '401,500p' ${script_dir}/message.txt`"

fi

if [ "$line" -gt 500 ];then

curl -X POST "https://api.telegram.org/bot709759784:AAF2Tff_lKOBLIXHPzfoM1WHQkXt-SqkAqo/sendMessage" -d "chat_id=-377237859&text=`sed -n '501,600p' ${script_dir}/message.txt`"

fi

if [ "$line" -gt 600 ];then

curl -X POST "https://api.telegram.org/bot709759784:AAF2Tff_lKOBLIXHPzfoM1WHQkXt-SqkAqo/sendMessage" -d "chat_id=-377237859&text=`sed -n '601,700p' ${script_dir}/message.txt`"

fi

if [ "$line" -gt 700 ];then

curl -X POST "https://api.telegram.org/bot709759784:AAF2Tff_lKOBLIXHPzfoM1WHQkXt-SqkAqo/sendMessage" -d "chat_id=-377237859&text=`sed -n '701,800p' ${script_dir}/message.txt`"

fi

if [ "$line" -gt 800 ];then

curl -X POST "https://api.telegram.org/bot709759784:AAF2Tff_lKOBLIXHPzfoM1WHQkXt-SqkAqo/sendMessage" -d "chat_id=-377237859&text=`sed -n '801,900p' ${script_dir}/message.txt`"

fi

if [ "$line" -gt 900 ];then

curl -X POST "https://api.telegram.org/bot709759784:AAF2Tff_lKOBLIXHPzfoM1WHQkXt-SqkAqo/sendMessage" -d "chat_id=-377237859&text=`sed -n '901,1000p' ${script_dir}/message.txt`"

fi

sed -i '1i\以下为被隐藏或者其它原因查询不到的\n' ${script_dir}/无法查询.txt

curl -X POST "https://api.telegram.org/bot709759784:AAF2Tff_lKOBLIXHPzfoM1WHQkXt-SqkAqo/sendMessage" -d "chat_id=-377237859&text= `cat ${script_dir}/无法查询.txt`"



