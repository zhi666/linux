[toc]



##  docker-compose一键部署typecho

### docker volume 持久化插件

```bash
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

```bash
wget https://github.com/MatchbookLab/local-persist/releases/download/v1.3.0/local-persist-linux-amd64
 
chmod +x local-persist-linux-amd64  && mv local-persist-linux-amd64 docker-volume-local-persist && mv docker-volume-local-persist /usr/bin/

systemctl daemon-reload && systemctl enable docker-volume-local-persist && systemctl start docker-volume-local-persist
```

### 安装docker

```
yum install -y yum-utils device-mapper-persistent-data lvm2

yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install  -y  docker-ce docker-ce-cli containerd.io
systemctl restart docker && systemctl enable docker
一、安装bash-complete
yum install -y bash-completion

二、刷新文件
source /usr/share/bash-completion/completions/docker && source /usr/share/bash-completion/bash_completion
```

### 安装docker-compose

    方法一：
    curl -L https://github.com/docker/compose/releases/download/1.26.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    或者：
    curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose


​    
​    chmod +x /usr/local/bin/docker-compose
​    查看版本信息
​    # docker-compose --version


​    
​    方法二：
​    
    yum install -y epel-release
     yum -y install python-pip python-devel
    
       pip install docker-compose 

如果报以下错误，

![arDuPH.png](https://s1.ax1x.com/2020/08/05/arDuPH.png)

就直接安装这个就可以了

```
pip install six --user -U
```





前提:已安装docker，域名已解析，已配置https,如没有域名 调整相关配置

支持端口转发

```
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf 
sysctl -p 
```



```
mkdir /data/{app,back,typecho} -p  && cd /data/typecho
```



### 编写Dockerfile

```
vim Dockerfile

FROM php:7.2.3-fpm


RUN apt-get update
RUN docker-php-ext-install pdo_mysql
```

保存Dockerfile

在typecho目录构建镜像

```
docker build -t scofieldpeng/php:7.2.3-fpm .

```

 创建docker编排文件 

```
cd /data/app/
touch docker-compose.yml
```

 mysql文件夹，用来存放mysql数据，方便后期导出 

```
mkdir mysql
```

 mysql镜像的环境 

```
touch mysql.env
```

 nginx配置文件 

```
touch typecho.conf
```

 克隆官方仓库 

```
git clone https://github.com/typecho/typecho.git
```

 mysql.env中的内容 

```
#MySQL的root用户默认密码，这里自行更改
MYSQL_ROOT_PASSWORD=Mysqlpass

#MySQL镜像创建时自动创建的数据库名称
MYSQL_DATABASE=typecho

#MySQL镜像创建时自动创建的用户名
MYSQL_USER=typecho

#MySQL镜像创建时自动创建的用户密码
MYSQL_PASSWORD=Mysqlpass

```

 typecho.conf的内容为   按需求修改相关内容，ssl可以注释掉

```
server {
    listen 0.0.0.0:80;
    root /app;
    index index.php;
    server_name www.baidu.com baidu.com;
    rewrite ^ https://$server_name$request_uri? permanent;
    charset utf-8;

    access_log  /var/log/nginx/typecho_access.log  main;
   


    if (-f $request_filename/index.html){
        rewrite (.*) $1/index.html break;
    }
    if (-f $request_filename/index.php){
        rewrite (.*) $1/index.php;
    }
    if (!-f $request_filename){
        rewrite (.*) /index.php;
    }



    location ~ .*\.php(\/.*)*$ {
    ##try_files $uri = 404;
       include        fastcgi_params;
       fastcgi_param  PATH_INFO $fastcgi_path_info;
       fastcgi_param  PATH_TRANSLATED $document_root$fastcgi_path_info;
       fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
       fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
       fastcgi_index  index.php;
       fastcgi_pass   php-fpm:9000;
    }




}




server {
   listen   443 ssl;
   root /app;
    index index.php;
   server_name  www.baidu.com baidu.com;
   ssl_certificate      /etc/letsencrypt/live/www.baidu.com/fullchain.pem;
   ssl_certificate_key  /etc/letsencrypt/live/www.baidu.com/privkey.pem;
   ssl_session_timeout 1d;
   ssl_session_cache shared:SSL:50m;
   ssl_session_tickets on;
   ssl_dhparam /etc/ssl/private/dhparam.pem;
   ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
   ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128:AES256:AES:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK';
   ssl_prefer_server_ciphers on;


    access_log  /var/log/nginx/typecho_access.log  main;



    if (-f $request_filename/index.html){
        rewrite (.*) $1/index.html break;
    }
    if (-f $request_filename/index.php){
        rewrite (.*) $1/index.php;
    }
    if (!-f $request_filename){
        rewrite (.*) /index.php;
    }

    

    location ~ .*\.php(\/.*)*$ {
    ##try_files $uri = 404;
       include        fastcgi_params;
       fastcgi_param  PATH_INFO $fastcgi_path_info;
       fastcgi_param  PATH_TRANSLATED $document_root$fastcgi_path_info;
       fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
       fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
       fastcgi_index  index.php;
       fastcgi_pass   php-fpm:9000;
    }




}
```

### docker-compose.yml中内容

```
version: '2'
services:
  nginx:
    image: nginx:1.13.9-alpine
    container_name: app_nginx
    ports:
      - "80:80"
      - "443:443"
    restart: always
    volumes:
      - ./typecho:/app
      - ./typecho.conf:/etc/nginx/conf.d/default.conf
      - logs:/var/log/nginx
      - /etc/ssl:/etc/ssl
      - /etc/letsencrypt:/etc/letsencrypt
    links:
      - php-fpm
    depends_on:
      - php-fpm
  php-fpm:
    image: scofieldpeng/php:7.2.3-fpm
    restart: always
    container_name: app_php-fpm
    volumes:
      - ./typecho:/app
    links:
      - db
    depends_on:
      - db
  db:
    image: mysql:5.7.21
    restart: always
    container_name: app_db
    ports:
      - 7878:3306
    volumes:
      - mysqldb:/var/lib/mysql
      - logs:/var/logs/mysql
      - /etc/mysql/mysqld.cnf:/etc/mysql/mysql.conf.d/mysqld.cnf 
    env_file:
      - mysql.env
volumes:
  logs:
    driver: local-persist
    driver_opts:
      mountpoint: /data/back/
  mysqldb:
    driver: local-persist
    driver_opts:
      mountpoint: /data/app/mysql
```

```
mkdir /etc/mysql   
vim /etc/mysql/mysqld.cnf
```



 我的mysqld.cnf 

```
[mysqld]
pid-file    = /var/run/mysqld/mysqld.pid
socket        = /var/run/mysqld/mysqld.sock
datadir        = /var/lib/mysql
#log-error    = /var/log/mysql/error.log
# By default we only accept connections from localhost
#bind-address    = 127.0.0.1
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
max_allowed_packet=400M
```



然后运行

```
docker-compose up -d
```

开通对应的防火墙端口

```
iptables -A INPUT -p tcp -m multiport --dports 80,443,7878 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --sports 80,443,7878 -j ACCEPT
```



docker inspect app_db 查看数据库的ip地址

### 开始访问,做初始化配置

```
http://192.168.224.12
```

这时候会提示手动创建`config.inc.php`文件。

![arD1Mt.png](https://s1.ax1x.com/2020/08/05/arD1Mt.png)

然后进入typecho目录 



`vim  config.inc.php`   文件

 ```
<?php
/**
 * Typecho Blog Platform
 *
 * @copyright  Copyright (c) 2008 Typecho team (http://www.typecho.org)
 * @license    GNU General Public License 2.0
 * @version    $Id$
 */

/** 定义根目录 */
define('__TYPECHO_ROOT_DIR__', dirname(__FILE__));

/** 定义插件目录(相对路径) */
define('__TYPECHO_PLUGIN_DIR__', '/usr/plugins');

/** 定义模板目录(相对路径) */
define('__TYPECHO_THEME_DIR__', '/usr/themes');

/** 后台路径(相对路径) */
define('__TYPECHO_ADMIN_DIR__', '/admin/');

/** 设置包含路径 */
@set_include_path(get_include_path() . PATH_SEPARATOR .
__TYPECHO_ROOT_DIR__ . '/var' . PATH_SEPARATOR .
__TYPECHO_ROOT_DIR__ . __TYPECHO_PLUGIN_DIR__);

/** 载入API支持 */
require_once 'Typecho/Common.php';

/** 程序初始化 */
Typecho_Common::init();

/** 定义数据库参数 */
$db = new Typecho_Db('Pdo_Mysql', 'typecho_');
$db->addServer(array (
  'host' => '172.20.0.2',
  'user' => 'root',
  'password' => 'Mysqlpass',
  'charset' => 'utf8',
  'port' => '3306',
  'database' => 'typecho',
  'engine' => 'InnoDB',
), Typecho_Db::READ | Typecho_Db::WRITE);
Typecho_Db::set($db);

 ```



然后回到网页上开始安装

最后
Typecho 安装好后，默认的后台路径是”你的域名/admin“，为了提高安全性，把访问路径设置为“你的域名/自定义文件夹”。
网站根目录下的config.inc.php文件里，找到：

后台路径(相对路径)

define('__TYPECHO_ADMIN_DIR__', '/admin/');

![arDYdS.png](https://s1.ax1x.com/2020/08/05/arDYdS.png)

把这个/admin/路径改成自己想要的路径就行了，同时把网站中的admin文件夹改成相同的名字。重新建立个admin文件夹，建立index.html文件，里面可以随意写嘲讽内容。

