# Docker部署Zabbix+Grafana

## 一，zabbix和grafana环境搭建




如在生产环境下运行请挂载volume 或者数据卷容器

环境
```
vm1  192.168.224.11 zabbix-server端 + grafana


vm2  192.168.224.12  zabbix-agent端 + nginx


```

以下操作在vm1

**docker部署**

```
 echo  "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf 
 sysctl -p --system

yum install -y yum-utils   device-mapper-persistent-data   lvm2

yum-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo

 yum install -y  docker-ce docker-ce-cli containerd.io
 
systemctl start docker &&  systemctl enable docker
一、安装bash-complete
yum install -y bash-completion

二、刷新文件
source /usr/share/bash-completion/completions/docker && source /usr/share/bash-completion/bash_completion
```



**1.启动mysql容器**

```
docker run --name mysql -t \
 --restart=always \
 -p 3306:3306 \
 -v /etc/localtime:/etc/localtime \
 -e MYSQL_DATABASE="zabbix" \
 -e MYSQL_USER="zabbix" \
 -e MYSQL_PASSWORD="zabbix_pwd" \
 -e MYSQL_ROOT_PASSWORD="root_Password@" \
 -v /data/mysql/data:/var/lib/mysql \
 -d mysql:5.7.28 \
 --character-set-server=utf8 --collation-server=utf8_bin
```

**2.zabbix-java-gateway部署**

```
docker run --name zabbix-java-gateway -t \
--restart=always \
-v /etc/localtime:/etc/localtime \
-d zabbix/zabbix-java-gateway:latest
```

**3.zabbix-snmptraps部署**

```
docker run --name zabbix-snmptraps -t \
-v /zbx_instance/snmptraps:/var/lib/zabbix/snmptraps:rw \
-v /var/lib/zabbix/mibs:/usr/share/snmp/mibs:ro \
--restart=always \
-v /etc/localtime:/etc/localtime \
-p 162:162/udp \
-d zabbix/zabbix-snmptraps:latest
```

**4.zabbix-server-mysql部署**

```

docker run --name zabbix-server-mysql -t \
-e DB_SERVER_HOST="mysql" \
-e MYSQL_DATABASE="zabbix" \
-e MYSQL_USER="zabbix" \
-e MYSQL_PASSWORD="zabbix_pwd" \
-e MYSQL_ROOT_PASSWORD="root_Password@" \
-e ZBX_JAVAGATEWAY="zabbix-java-gateway" \
-e PHP_TZ="Asia/Shanghai" \
--restart=always \
-v /etc/localtime:/etc/localtime \
--volumes-from zabbix-snmptraps \
--link mysql:mysql \
--link zabbix-java-gateway:zabbix-java-gateway \
-p 10051:10051 \
-d zabbix/zabbix-server-mysql:latest
```

**5.zabbix-web-nginx-mysql部署**

```

docker run --name zabbix-web-nginx-mysql -t \
--restart=always \
-v /etc/localtime:/etc/localtime \
-e DB_SERVER_HOST="mysql" \
-e MYSQL_DATABASE="zabbix" \
-e MYSQL_USER="zabbix" \
-e MYSQL_PASSWORD="zabbix_pwd" \
-e MYSQL_ROOT_PASSWORD="root_Password@" \
-e PHP_TZ="Asia/Shanghai" \
--link mysql:mysql \
--link zabbix-server-mysql:zabbix-server \
-p 8080:8080 \
-d zabbix/zabbix-web-nginx-mysql:latest
```

现在应该可以直接访问`http://192.168.224.11:8080/ ` 默认用户名Admin 密码zabbix 

   有时候点击小人会出错

![a04KA0.png](https://s1.ax1x.com/2020/08/04/a04KA0.png)

以下报错这样解决

```
[root@localhost ~]# docker exec  -it zabbix-web-nginx-mysql bash 
bash-5.0# apk add php7-fileinfo
bash-5.0# exit
[root@localhost ~]# docker restart zabbix-web-nginx-mysql
```

重新访问就好了 调成中文

![a04GjJ.png](https://s1.ax1x.com/2020/08/04/a04GjJ.png)





**6.grafana部署**

```
docker run --name grafana -t \
--hostname grafana \
--restart=always \
-v /etc/localtime:/etc/localtime \
-e "GF_SERVER_ROOT_URL=http://grafana.server.name" \
-e "GF_SECURITY_ADMIN_PASSWORD=123456" \
-e "GF_INSTALL_PLUGINS=alexanderzobnin-zabbix-app,raintank-worldping-app,grafana-piechart-panel,grafana-clock-panel,farski-blendstat-panel" \
-v /data/grafana:/var/lib/grafana \
-p 3000:3000 \
-d grafana/grafana
```

如果容器没有启动就看下是什么问题，有时候是权限不到会启动不了

docker logs  -f  gragana    看日志

此时 3000端口可以正常打开grafana  用户admin 密码 123456  不设置密码，默认密码就是admin





vm2装好zabbix-agent

```
 yum install -y wget && wget http://repo.zabbix.com/zabbix/4.4/rhel/7/x86_64/zabbix-release-4.4-1.el7.noarch.rpm
 rpm -ivh zabbix-release-4.4-1.el7.noarch.rpm
  yum install -y epel-release
[root@localhost yum.repos.d]# yum -y install zabbix-agent nginx

vim /etc/nginx/nginx.conf  
 在server端相应位置增加 
 
   location /status {
                stub_status on;
                access_log off;

    }


[root@localhost ~]# nginx -t 

```

![a04w4K.png](https://s1.ax1x.com/2020/08/04/a04w4K.png)

使用sed 来修改zabbix-agentd.conf 文件 

```

sed -i 's/Server=127.0.0.1/Server=192.168.224.11/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive=192.168.224.11/g' /etc/zabbix/zabbix_agentd.conf

sed -i 's/Hostname=Zabbix server/Hostname='server2.com' ----- '192.168.224.12'/g' /etc/zabbix/zabbix_agentd.conf

sed -i 's/# ListenPort=10050/ListenPort=10050/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# HostMetadataItem=/HostMetadataItem=system.uname/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# StartAgents=3/StartAgents=3/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# Timeout=3/Timeout=10/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# UnsafeUserParameters=0/UnsafeUserParameters=1/g' /etc/zabbix/zabbix_agentd.conf
```

自定义监控nginx链接

```
vim  /etc/zabbix/zabbix_agentd.conf 

UserParameter=Nginx.connect,/usr/bin/curl -s 192.168.224.12/status |grep '^Active connections' |awk '{print $NF}'

```

systemctl restart zabbix-agent.service 

 docker exec -it zabbix-server-mysql bash

 zabbix_get -s 192.168.224.12 -k "Nginx.connect" -p 10050	--使用此命令可以得到被监控端的结果，则测试ok



以下操作在vm1的zabbix web页面

![a044C8.png](https://s1.ax1x.com/2020/08/04/a044C8.png)

![a04HDs.png](https://s1.ax1x.com/2020/08/04/a04HDs.png)

在这里要等ZBX由灰色变成绿色 ，如果没变绿，看下是不是localtime监控项没有启用

创建应用集

![a04X5V.png](https://s1.ax1x.com/2020/08/04/a04X5V.png)

创建监控项

![a04z2F.png](https://s1.ax1x.com/2020/08/04/a04z2F.png)





配置数据源

![a05PbR.png](https://s1.ax1x.com/2020/08/04/a05PbR.png)



安装zabbix插件

```
[root@server1 grafana]#  docker exec -it grafana bash
bash-5.0$ grafana-cli plugins install alexanderzobnin-zabbix-app

[root@localhost ~]# docker restart grafana 

```

启用zabbix插件

![a05uKH.png](https://s1.ax1x.com/2020/08/04/a05uKH.png)



添加zabbix数据源

```
http://192.168.224.11:8080/api_jsonrpc.php
```



![a05dqs.png](https://s1.ax1x.com/2020/08/04/a05dqs.png)

启用警报

![aBKyb8.png](https://s1.ax1x.com/2020/08/04/aBKyb8.png)

```
Vm2安装 yum -y install httpd-tools
vm2运行伪造并发
[root@localhost ~]# while true ;do ab -c 1000 -n 10000 http://192.168.224.12/status ;done
```

创建新的仪表盘，里面可以添加很多监控的项目

![aBKIK0.png](https://s1.ax1x.com/2020/08/04/aBKIK0.png)



填好 后点击右上角的保存按钮，然后命名，就保存了

![aBKTbT.png](https://s1.ax1x.com/2020/08/04/aBKTbT.png)



增加一个ssh是否在线

![aBMpqK.png](https://s1.ax1x.com/2020/08/04/aBMpqK.png)

后续可以安装其他插件，

增加多个仪表盘后，可以再新增一个仪表盘，把改为转换为行(Convert  to row )  就把多个仪表盘合成一行了，方便管理

最后的页面布局样板

![aBMmsP.png](https://s1.ax1x.com/2020/08/04/aBMmsP.png)

```
docker exec -it grafana bash

grafana-cli plugins install  raintank-worldping-app   #安装worldping插件
grafana-cli plugins install  grafana-piechart-panel    #安装Pie Chart面板插件
grafana-cli plugins install  grafana-clock-panel      #安装clock面板插件
grafana-cli plugins install  farski-blendstat-panel   #安装Blendstat面板插件

docker restart grafana 
```

## 二，新增配置客户端服务器的tcp状态，

1，编辑规则

```
vim /etc/zabbix/zabbix_agentd.d/tcp_status.conf

#!/bin/bash
UserParameter=TCP_STATUS[*],netstat -ant | grep -c $1
重启zabbix-agent
```

2，然后去zabbix-web端创建模板 

![aBMQIg.png](https://s1.ax1x.com/2020/08/04/aBMQIg.png)



3，接着创建应用集和监控项，监控项需要创建12个

![aBMts0.png](https://s1.ax1x.com/2020/08/04/aBMts0.png)

12个监控项键值分别是

```
TCP_STATUS[CLOSE]   	TCP_STATUS[CLOSE_WAIT]    TCP_STATUS[CLOSING]  TCP_STATUS[ESTABLISHED] TCP_STATUS[FIN_WAIT1]  	 TCP_STATUS[FIN_WAIT2] TCP_STATUS[LAST_ACK]     TCP_STATUS[LISTEN]   	TCP_STATUS[SYN_RECV]
TCP_STATUS[SYN_SENT]      TCP_STATUS[TIME_WAIT]   TCP_STATUS[UNKNOWN]
```

4，接着把新建的模板链接到其他模板，

![aBMddU.png](https://s1.ax1x.com/2020/08/04/aBMddU.png)

5，去grafana新建仪表盘，**应用集的名称可以不用填写**

![aBMrW9.png](https://s1.ax1x.com/2020/08/04/aBMrW9.png)

### 新增监控nginx状态

1,创建脚本

```
mkdir /script
vim /script/nginx_status.sh

#!/bin/bash

case $1 in
ping)
     /usr/sbin/pidof nginx |wc -l ;;
active)
     curl -s http://127.0.0.1/nginx_status | awk '/Active/ {print $3}' ;;
accepts)
     curl -s http://127.0.0.1/nginx_status | awk 'NR==3 {print $1}' ;;
handled)
     curl -s http://127.0.0.1/nginx_status | awk 'NR==3 {print $2}' ;;
requests)
     curl -s http://127.0.0.1/nginx_status | awk 'NR==3 {print $3}' ;;
reading)
     curl -s http://127.0.0.1/nginx_status | awk '/Reading/ {print $2}' ;;
writing)
     curl -s http://127.0.0.1/nginx_status | awk '/Writing/ {print $4}' ;;
waiting)
     curl -s http://127.0.0.1/nginx_status | awk '/Waiting/ {print $6}' ;;
*)
     echo \"Usage: $0 { ping | active | accepts | handled | requests | reading | writing | waiting }\" ;;
esac


```

2，创建监控项

```
vim /etc/zabbix/zabbix_agentd.d/nginx_status.conf

## Nginx_status
UserParameter=nginx.ping,/script/nginx_status.sh ping
UserParameter=nginx.active,/script/nginx_status.sh active
UserParameter=nginx.accepts,/script/nginx_status.sh accepts
UserParameter=nginx.handled,/script/nginx_status.sh handled
UserParameter=nginx.requests,/script/nginx_status.sh requests
UserParameter=nginx.reading,/script/nginx_status.sh reading
UserParameter=nginx.writing,/script/nginx_status.sh writing
UserParameter=nginx.waiting,/script/nginx_status.sh waiting

```

重启zabbix-agent  后面的操作和之前一样

## 三，grafana面板设置

设置变量

![aBM5JH.png](https://s1.ax1x.com/2020/08/04/aBM5JH.png)



![aBQPO0.png](https://s1.ax1x.com/2020/08/04/aBQPO0.png)

**group变量设置**



![aBQMOx.png](https://s1.ax1x.com/2020/08/04/aBQMOx.png)

**host变量设置**

![aBQ0nP.png](https://s1.ax1x.com/2020/08/04/aBQ0nP.png)



**netif变量设置 **

![aBQ6hQ.png](https://s1.ax1x.com/2020/08/04/aBQ6hQ.png)



**disk变量设置**

![aBQ57T.png](https://s1.ax1x.com/2020/08/04/aBQ57T.png)