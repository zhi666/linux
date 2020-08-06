[TOC] 



# 用docker-compose 安装jumpserver

## 安装docker 
```

yum install -y yum-utils   device-mapper-persistent-data   lvm2
yum-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo

yum install  -y  docker-ce docker-ce-cli containerd.io

systemctl start docker  &&   systemctl enable docker
```

**docker疑难杂症：docker命令Tab无法自动补全**

```

一、安装bash-complete
yum install -y bash-completion

二、刷新文件
source /usr/share/bash-completion/completions/docker
source /usr/share/bash-completion/bash_completion

```
## 安装docker-compose

```

 curl -L https://github.com/docker/compose/releases/download/1.26.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
 
 或者：
curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose


chmod +x /usr/local/bin/docker-compose
查看版本信息
# docker-compose --version


```

需要注意安装iptables 而且如果iptables相关报错的话 重启下

```
注意/etc/sysctl.conf 里面写 net.ipv4.ip_forward = 1

运行命令 sysctl -p --system

```
## 开始安装jumpserver dockerfile 文件

```
mkdir jumpserver cd jumpserver
git clone https://github.com/wojiushixiaobai/docker-compose.git
cd docker-compose

cat .env
docker-compose up -d

```

*以下文件内容为.env*

```
# 版本号可以自己根据项目的版本修改
Version=1.5.4

# MYSQL_ROOT_PASSWORD 不支持纯数字, 字符串位数推荐大于等于 8
MYSQL_ROOT_PASSWORD=oM0aevSQaH8Bd2Bgg5cX8lOd

# SECRET_KEY 不支持纯数字, 推荐字符串位数大于等于 50, 仅首次安装定义, 升级或者迁移请勿修改此项
SECRET_KEY=B3f2w8P2PfxIAS7s4URrD9YmSbtqX4vXdPUL217kL9XPUOWrmy

# BOOTSTRAP_TOKEN 不支持纯数字, 推荐字符串位数大于等于 16, 仅首次安装定义, 升级或者迁移请勿修改
BOOTSTRAP_TOKEN=7Q11Vz6R2J6BLAdO

```

![ar2YXd.png](https://s1.ax1x.com/2020/08/05/ar2YXd.png)

*以下文件内容为docker-compose.yml*

```
version: '3'
services:
  mysql:
    image: mysql:5.7
    container_name: jms_mysql
    restart: always
    tty: true
    environment:
      MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD
      MYSQL_DATABASE: jumpserver
    command: --character-set-server=utf8
    volumes:
      - db-data:/var/lib/mysql
    networks:
      - jumpserver

  redis:
    image: redis:alpine
    container_name: jms_redis
    restart: always
    tty: true
    volumes:
      - redis-data:/data
    networks:
      - jumpserver

  core:
    image: wojiushixiaobai/jms_core:${Version}
    container_name: jms_core
    hostname: jms_core
    restart: always
    tty: true
    environment:
      SECRET_KEY: $SECRET_KEY
      BOOTSTRAP_TOKEN: $BOOTSTRAP_TOKEN
      DB_ENGINE: mysql
      DB_HOST: mysql
      DB_PORT: 3306
      DB_USER: root
      DB_PASSWORD: $MYSQL_ROOT_PASSWORD
      DB_NAME: jumpserver
      REDIS_HOST: redis
    depends_on:
      - mysql
      - redis
    volumes:
      - static:/opt/jumpserver/data/static
      - media:/opt/jumpserver/data/media
      - logs:/opt/jumpserver/logs
    networks:
      - jumpserver

  koko:
    image: wojiushixiaobai/jms_koko:${Version}
    container_name: jms_koko
    restart: always
    tty: true
    environment:
      CORE_HOST: http://core:8080
      BOOTSTRAP_TOKEN: $BOOTSTRAP_TOKEN
    depends_on:
      - core
      - mysql
      - redis
    volumes:
      - keys-data:/opt/koko/data/keys
    ports:
      - 2222:2222
    networks:
      - jumpserver

  guacamole:
    image: wojiushixiaobai/jms_guacamole:${Version}
    container_name: jms_guacamole
    restart: always
    tty: true
    environment:
      JUMPSERVER_SERVER: http://core:8080
      BOOTSTRAP_TOKEN: $BOOTSTRAP_TOKEN
      JUMPSERVER_KEY_DIR: /config/guacamole/keys
      GUACAMOLE_HOME: /config/guacamole
      GUACAMOLE_LOG_LEVEL: ERROR
    depends_on:
      - core
      - mysql
      - redis
    volumes:
      - gua-key:/config/guacamole/keys
    networks:
      - jumpserver

  nginx:
    image: wojiushixiaobai/jms_nginx:${Version}
    container_name: jms_nginx
    restart: always
    tty: true
    depends_on:
      - core
      - koko
      - mysql
      - redis
    volumes:
      - static:/opt/jumpserver/data/static
      - media:/opt/jumpserver/data/media
    ports:
      - 80:80
    networks:
      - jumpserver

volumes:
  static:
  media:
  logs:
  db-data:
  redis-data:
  keys-data:
  gua-key:

networks:
  jumpserver:

```

**jms_koko的端口也可以改**

![arRngg.png](https://s1.ax1x.com/2020/08/05/arRngg.png)

**也可以改变下jumpserver的访问端口**

```
vim ./docker-compose/docker-compose.yml
把里面的nginx 容器映射端口80:80 改成88:80
```

![arWed1.png](https://s1.ax1x.com/2020/08/05/arWed1.png)



然后输入ip地址对应的88端口就可以登录了，默认密码是admin



## jumpserver的使用

### 登录后先创建相关用户，设置

   首先创建 **用户管理** ------>用户列表-----**创建用户**  

![arWKJK.png](https://s1.ax1x.com/2020/08/05/arWKJK.png)





![arW4lF.png](https://s1.ax1x.com/2020/08/05/arW4lF.png)



**用户管理** ------>用户组-----**创建用户组**  

![arWqFx.png](https://s1.ax1x.com/2020/08/05/arWqFx.png)

现在luke用户就属于运维组了

 **资产管理 ** ----> 资产列表 ---->创建资产

![arWvlD.png](https://s1.ax1x.com/2020/08/05/arWvlD.png)



![arIAEj.png](https://s1.ax1x.com/2020/08/05/arIAEj.png)



 **资产管理 ** ----> 管理用户 和系统用户 

**1,创建管理用户root的时候密码需要写服务器的登录密码，系统用户也要自己新设密码**

![arIV5n.png](https://s1.ax1x.com/2020/08/05/arIV5n.png)



**2,创建管理用户最好是设置秘钥的方式连接**

先在服务器设置秘钥 -**C** 是生成新的备注luke.com

```
ssh-keygen  -C "luke.com"  直接敲回车生成秘钥对， cd ~/.ssh   把自己的公钥复制到authorized_keys中
cp id_rsa.pub authorized_keys
然后把id_rsa私钥 下载到本地保存

```

然后在管理用户里面上传服务器的秘钥 

![arIeCq.png](https://s1.ax1x.com/2020/08/05/arIeCq.png)

然后提交就可以了， 

**需要连接其他服务器的话就直接把第一台服务器的公钥放到~/.ssh/authorized_keys 文件去，然后就可以了**



还需要设置命令过滤

![arIn2V.png](https://s1.ax1x.com/2020/08/05/arIn2V.png)

创建系统用户的时候重要的命名需要添加sudo 权限才能执行

![arIuvT.png](https://s1.ax1x.com/2020/08/05/arIuvT.png)



![arIQrF.png](https://s1.ax1x.com/2020/08/05/arIQrF.png)

设置密码123.yunwei





例如下面的命令

```

 /bin/whoami,/usr/bin/docker,/usr/sbin/nginx,/usr/bin/ansible-playbook,/usr/bin/openresty,/usr/bin/vim,/usr/bin/ansible,/usr/bin/cd,/usr/bin/unzip,/usr/bin/cp,/usr/bin/mkdir,/usr/bin/chown,/usr/bin/ssh,/usr/sbin/iptables,/usr/bin/echo,/usr/bin/systemctl,/usr/bin/sh,/usr/bin/sed,/usr/bin/cat,/usr/bin/grep,/usr/bin/mv,/usr/bin/chmod,/usr/local/bin/docker-compose,/usr/sbin/service,/usr/bin/tail,/usr/bin/rm
```

下一步创建 **权限管理** --->资产授权--->创建授权

![arI8a9.png](https://s1.ax1x.com/2020/08/05/arI8a9.png)



创建相关资产，然后退出administrator用户，

重新用luke用户登录，并设置ssh 

点击**资产管理**---->系统用户---->点击yunwei 然后测试资产连接性



点击**会话管理** 然后点击**web终端**  就可以了，进入是以系统用户的身份登录的服务器

![arIsIA.png](https://s1.ax1x.com/2020/08/05/arIsIA.png)

在里面编辑一些文件都需要加sudo 权限

报这样的错误，就需要把权限加进去

![arI2xf.png](https://s1.ax1x.com/2020/08/05/arI2xf.png)

加入给系统用户加上权限后就可以编辑文件了

### 用Xshell连接jms_koko 2020端口然后进行操作

先把自己用户的秘钥下载到本地，然后导入xshell里面 然后进行连接，

也可以用 用户的登录密码进行连接

![arIIaj.png](https://s1.ax1x.com/2020/08/05/arIIaj.png)

然后就可以通过终端的方式连接

![arI7in.png](https://s1.ax1x.com/2020/08/05/arI7in.png)



