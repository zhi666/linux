#!/bin/bash
yum -y install wget lrzsz >>/dev/null
#今天
Date_today=$(date "+%w")

#昨天

Yester_day=$(date "+%w" -d '1 day ago')

#七天前

Sevendays_ago=$(date "+%w" -d '7 day ago')

#今天星期几
week=`date +%w`
mysqluser="root"
mysqlpass="123.Shui!!"
mysqlcon=/etc/my.cnf
host="192.168.224.11"

first=`date "+%Y-%m-%d"`

if [ $first = 2020-07-21 ];then
	yum install -y  https://repo.percona.com/yum/percona-release-latest.noarch.rpm &>/dev/null
  
	percona-release enable-only tools release
	yum install -y  percona-xtrabackup-80 qpress &> /dev/null




	
	mkdir -p /mysqlbackup/{wanquan,zengliang}

fi


#判断今天是不是周日 如果是周日进行全量备份

if [ $week -eq 0 ];then

    rm -rf /mysqlbackup/wanquan/$Sevendays_ago >>/dev/null 


    xtrabackup --backup --default-file=${mysqlcon} --target-dir=/mysqlbackup/wanquan/$Date_today  --user=${mysqluser}  --host=${host} --password=${mysqlpass} 
    if [ $? -eq 0 ];then

         rm -rf /mysqlbackup/zengliang/*

    fi

else

    dir=`ls /mysqlbackup/zengliang/ | wc -l | awk '{print $1}'`

        if [ $dir -eq 0 ];then
     xtrabackup --backup --default-file=${mysqlcon} --target-dir=/mysqlbackup/zengliang/$Date_today --incremental-basedir=/mysqlbackup/wanquan/`ls /mysqlbackup/wanquan/`  --user=${mysqluser}  --host=${host} --password=${mysqlpass} 


	else
     
     xtrabackup --backup --default-file=${mysqlcon} --target-dir=/mysqlbackup/zengliang/$Date_today --incremental-basedir=/mysqlbackup/zengliang/${Yester_day}  --user=${mysqluser}  --host=${host} --password=${mysqlpass} 


	fi

fi

