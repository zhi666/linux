#!/bin/bash
yum -y install wget lrzsz >>/dev/null
#今天
Date_today=$(date "+%Y-%m-%d")

#昨天

Yester_day=$(date "+%Y-%m-%d" -d '1 day ago')

#七天前

Sevendays_ago=$(date "+%Y-%m-%d" -d '7 day ago')

#今天星期几
week=`date +%w`
mysqluser="backup_mysql"
mysqlpass="123321.shui"
mysqlcon=/etc/my.cnf

first=`date "+%Y-%m-%d"`

if [ $first = 2019-10-13 ];then
  
    cd /root/ && wget https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.4/binary/tarball/percona-xtrabackup-2.4.4-Linux-x86_64.tar.gz

     tar zxf percona-xtrabackup-2.4.4-Linux-x86_64.tar.gz

    cd percona-xtrabackup-2.4.4-Linux-x86_64/ && cp bin/* /usr/bin/

    yum -y install perl-DBI perl-DBD-MySQL perl-Time-HiRes perl-IO-Socket-SSL perl-TermReadKey.x86_64 perl-Digest-MD5 

    cd /root/ && wget  https://www.percona.com/downloads/percona-toolkit/2.2.19/RPM/percona-toolkit-2.2.19-1.noarch.rpm

    rpm -vih percona-toolkit-2.2.19-1.noarch.rpm
	
	mkdir -p /mysqlbackup/{wanquan,zengliang}

fi


#判断今天是不是周日 如果是周日进行全量备份

if [ $week -eq 0 ];then

    rm -rf /mysqlbackup/wanquan/$Sevendays_ago >>/dev/null 

    innobackupex --default-file=${mysqlcon} --user=${mysqluser} --password=${mysqlpass} /mysqlbackup/wanquan/$Date_today  --no-timestamp  >>/dev/null

    if [ $? -eq 0 ];then

         rm -rf /mysqlbackup/zengliang/*

    fi

else

    dir=`ls /mysqlbackup/zengliang/ | wc -l | awk '{print $1}'`

        if [ $dir -eq 0 ];then

            innobackupex --incremental /mysqlbackup/zengliang/${Date_today} --incremental-basedir=/mysqlbackup/wanquan/`ls /mysqlbackup/wanquan/` --user=${mysqluser} --password=${mysqlpass} --no-timestamp

	else

	    innobackupex --incremental /mysqlbackup/zengliang/${Date_today} --incremental-basedir=/mysqlbackup/zengliang/${Yester_day} --user=${mysqluser} --password=${mysqlpass} --no-timestamp

	fi

fi
