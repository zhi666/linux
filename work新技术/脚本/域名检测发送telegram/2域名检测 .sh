#!/bin/bash
           echo "`date`" >>~/1.txt    #当前输出时间
               echo "`date`" >>~/2.txt
for i in $(cat ~/yuming.txt)
do
  url=$i
  state=`/usr/bin/curl -I -m 5 -s -w "%{http_code}\n" -o /dev/null ${url}`  #获取状态码

  if [ "$state" -eq 200 ] || [ "$state" -eq 301 ] || [ "$state" -eq 302 ]  #判断状态码是不是等于200,301,302，
    then
          echo  "${url} 正常 状态码  ${state}  ip：`cat ~/yuming_ip.txt |grep ${url} |awk '{print $2}'`" >>~/1.txt   #是的就输出状态码，然后查看域名，和IP把结果追加到1.txt
      #curl -X POST "https://api.telegram.org/bot927831179:AAHP1fGedWCw3T0yJOG_6UbZlE9Sn-k1_G0/sendMessage" -d "chat_id=-1001195075392&text=${url} state is ${state}"

  else
        echo  "${url} 异常 状态码  ${state}  ip：`cat ~/yuming_ip.txt |grep ${url} |awk '{print $2}'`" >>~/2.txt    # 其他状态码，则输出到2.txt
      #curl -X POST "https://api.telegram.org/bot927831179:AAHP1fGedWCw3T0yJOG_6UbZlE9Sn-k1_G0/sendMessage" -d "chat_id=-1001195075392&text=${url} state is ${state}"

  fi

done
        if [ $? -eq 0 ] #如何上面的命令正确，就把1.txt和2.txt的信息发送到Telegram的api接口的群里去
          then
           curl -X POST "https://api.telegram.org/bot745313291:AAGXXkROD8a_U77O8hNcFM9u8AsYTvM4X_E/sendMessage" -d "chat_id=-1001332404286&text=`cat ~/1.txt`" >>/dev/null
           sleep 5
               curl -X POST "https://api.telegram.org/bot745313291:AAGXXkROD8a_U77O8hNcFM9u8AsYTvM4X_E/sendMessage" -d "chat_id=-1001332404286&text=`cat ~/2.txt`" >>/dev/null
               sleep 5
           rm -rf ~/1.txt   #删除原来的文件
               rm -rf ~/2.txt
       else
               curl -X POST "https://api.telegram.org/bot745313291:AAGXXkROD8a_U77O8hNcFM9u8AsYTvM4X_E/sendMessage" -d "chat_id=-1001332404286&text=`echo "脚本出错"`" 

       fi

