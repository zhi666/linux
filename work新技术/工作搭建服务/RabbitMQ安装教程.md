# RabbitMQ安装教程

##  1，Linux下rpm安装

```

1.1.安装Erlang
1.2.添加yum支持
cd /usr/local/src/
mkdir rabbitmq
cd rabbitmq

wget http://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm
rpm -Uvh erlang-solutions-1.0-1.noarch.rpm

rpm --import http://packages.erlang-solutions.com/rpm/erlang_solutions.asc

 sudo yum install erlang -y

1.3.安装RabbitMQ 


 wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.15/rabbitmq-server-3.6.15-1.el6.noarch.rpm

yum install socat -y    #安装依赖

rpm -ivh rabbitmq-server-3.6.15-1.el6.noarch.rpm

安装管理插件
rabbitmq-plugins enable rabbitmq_management
```

 



1.4启动、停止 

systemctl start rabbitmq-server

systemctl restart rabbitmq-server

systemctl status rabbitmq-server

 chkconfig rabbitmq-server on  #开机自启动

systemctl enable rabbitmq-server

1.5.设置配置文件
cd /etc/rabbitmq
cp /usr/share/doc/rabbitmq-server-3.4.1/rabbitmq.config.example /etc/rabbitmq/

mv rabbitmq.config.example rabbitmq.config

1.6.开启用户远程访问
vi /etc/rabbitmq/rabbitmq.config

注意要去掉后面的逗号。
1.7开启web界面管理工具
rabbitmq-plugins enable rabbitmq_management
service rabbitmq-server restart
1.9.防火墙开放15672端口
/sbin/iptables -I INPUT -p tcp --dport 15672 -j ACCEPT
/etc/rc.d/init.d/iptables save



## 2.运用docker安装rabbitmq 




```
 yum install -y yum-utils device-mapper-persistent-data lvm2
 yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
 yum install  -y  docker-ce docker-ce-cli containerd.io && systemctl restart docker && systemctl enable docker
 一、安装bash-complete yum install -y bash-completion 
 二、刷新文件 source /usr/share/bash-completion/completions/docker && source /usr/share/bash-completion/bash_completion 
 
 echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf 
 sysctl -p 
```

 安装docker-compose 

```

 yum install -y epel-release
 yum -y install python-pip python-devel

  yum install -y docker-compose
```

编写docker-compose.yml文件

mkdir rabbitmq

vim  rabbitmq/docker-compose.yml

```
version: '3'
services:
  rabbitmq:
    image: rabbitmq:management-alpine
    container_name: rabbitmq
    environment:
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=123.luke
    restart: always
    ports:
      - "15672:15672"
      - "5672:5672"
    volumes:
      - /etc/localtime:/etc/localtime
      - rabbitmq-data:/var/lib/rabbitmq
    logging:
      driver: "json-file"
      options:
        max-size: "200k"
        max-file: "10"

volumes:
  rabbitmq-data:
    driver: local-persist
    driver_opts:
      mountpoint: /rabbitmq
```

### docker volume 持久化插件

```

vim /etc/systemd/system/docker-volume-local-persist.service
#文件内容为
[Unit]
Description=docker-volume-local-persist
Before=docker.service
Wants=docker.service

[Service]
TimeoutStartSec=0
ExecStart=/usr/bin/docker-volume-local-persist

[Install]
WantedBy=multi-user.target
```

```

wget https://github.com/MatchbookLab/local-persist/releases/download/v1.3.0/local-persist-linux-amd64
 
chmod +x local-persist-linux-amd64  && mv local-persist-linux-amd64 docker-volume-local-persist && mv docker-volume-local-persist /usr/bin/

systemctl daemon-reload && systemctl enable docker-volume-local-persist && systemctl start docker-volume-local-persist
```

docker-compose up -d 运行

 http://192.168.224.11:15672/#/  访问

———————

 默认账号密码都为guest    

