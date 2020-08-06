#!/bin/bash

scp root@183.2.242.162:/root/1.txt /root/1.txt
scp root@183.2.242.162:/root/2.txt /root/2.txt

if [ $? -eq 0 ] #如何上面的命令正确，就把1.txt和2.txt的信息发送到Telegram的api接口的群里去
          then
           curl -X POST "https://api.telegram.org/bot745313291:AAGXXkROD8a_U77O8hNcFM9u8AsYTvM4X_E/sendMessage" -d "chat_id=-1001332404286&text=`cat ~/1.txt`" >>/dev/null
           sleep 5
               curl -X POST "https://api.telegram.org/bot745313291:AAGXXkROD8a_U77O8hNcFM9u8AsYTvM4X_E/sendMessage" -d "chat_id=-1001332404286&text=`cat ~/2.txt`" >>/dev/null
               sleep 5
           rm -rf ~/1.txt   #删除原来的文件
               rm -rf ~/2.txt
           echo "`date`" >>~/1.txt    #当前输出时间
               echo "`date`" >>~/2.txt
       else
               curl -X POST "https://api.telegram.org/bot745313291:AAGXXkROD8a_U77O8hNcFM9u8AsYTvM4X_E/sendMessage" -d "chat_id=-1001332404286&text=`echo "脚本出错"`"

       fi

