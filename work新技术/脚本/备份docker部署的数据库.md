# 备份docker部署的数据库

```
#!/bin/bash

#7天前
Sevendays_ago=$(date "+%Y-%m-%d" -d '7 day ago')
#当前时间
timea=`echo $(date "+%Y-%m-%d-%R")`
#当天时间
timeb=`echo $(date "+%Y-%m-%d")`

mkdir -p /mysqlbackup/${timeb}

docker exec mysql sh -c 'exec mysqldump --all-databases -uroot -p123.yichen' > /mysqlbackup/${timeb}/${timea}.sql


rm -rf /mysqlbackup/${Sevendays_ago}*  >>/dev/null

```

设置定时任务每隔3小时执行

```
00 */3 * * * /root/mysqlbackup.sh
```



数据库的恢复

1 使用docker cp 命令 复制.sql文件到容器中的目录

```
docker cp /mysqlbackup/当前备份日期/最新时间mysqlall.sql   mysql:/tmp/

docker exec mysql bash -c  ' exec mysql -uroot -p123.yichen < /tmp/最新时间mysqlall.sql'
```



或 2，进入容器内部，导入sql文件到数据库

```
docker exec -it 容器名 bash

mysql -uroot -ppassword

use database_name;

source /tmp/最新时间mysqlall.sql;

show tables;
```



　　

