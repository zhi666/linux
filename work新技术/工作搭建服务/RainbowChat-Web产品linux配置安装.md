**一，RainbowChat-Web产品linux配置安装**

创建库rainbowchat_pro，并把数据导入这个库

create database rainbowchat_pro  default charset utf8;

cat rainbowchat_pro.sql |mysql  -u root -p rainbowchat_pro

**1，需要一台 RabittMQ 消息队列服务器**

直接通过docker-compose安装就可以了

```
mkdir chat 
分别把RainbowChat server端和web端的目录放到chat目录里面

```

**2，Chat-Web 主服务配置 MQ 的连接和数据库的连接**

```
find / -name config.js

vim  /root/chat-compose/chat-web/RainbowChatServer_web/bin/conf/config.js

vim /root/chat-compose/chat-web/RainbowChatServer_web/node_modules/mobile-im-sdk/j_conf/config.js


```

![image-20191215225328346](https://s2.ax1x.com/2019/12/16/QhGz4J.png)

以上共 2 项配置：**修改** **MQ** **的连接** **URL** **为您自已的** **RabbitMQ** **服务器地址即可（注意用户名、密码）**

![image-20191215231237159](https://s2.ax1x.com/2019/12/16/QhJnCd.png)

以上共 4 项配置：**修改** **DB** **的连接信息为您自已的 MySQL 即可（注意用户名、密码、ip地址）**



**3，配置 RainboChat-Web 网页前端的 IP 连接**

```

vim  /root/chat-compose/chat-web/RainbowChatServer_web/public/javascripts/others/rbchat_config.js
```

![image-20191215232834679](https://s2.ax1x.com/2019/12/16/QhJ1Df.png)

下面是域名版截图

![web连接前端.png](https://s2.ax1x.com/2019/12/28/leQsde.png)



2项配置：标号**1**配置为您的RainbowChat APP版 Http服务地址，标号**2**为本文档中的RainbowChat-Web 的 IM 主服务地址

**4，启动 RainbowChat-Web 主服务**

```

forever restart  /root/chat-compose/chat-web/RainbowChatServer_web/bin/www.js


```



**二、linux配置并运行 RainbowChatMQServer 服务**

1,**配置RainbowChatMQServer 服务与 MQ 的连接**

```
find / -name base_conf.properties
vim /root/chat/RainbowChatMQServer/src/com/x52im/rainbowchat/mq/base_conf.properties

vim /root/chat/RainbowChatMQServer/deploy/RainbowChatMQServer_deploy_20190401/classes/com/x52im/rainbowchat/mq/base_conf.properties
vim /root/chat-compose/tomcat/tomcat/webapps/RainbowChatServer/WEB-INF/classes/com/x52im/rainbowchat/base_conf.properties
```



![image-20191215233938456](https://s2.ax1x.com/2019/12/16/QhJNCj.png)

tomcat配置与app的消息互通，默认是false

![lelpo4.png](https://s2.ax1x.com/2019/12/28/lelpo4.png)

**2,配置RainbowChatMQServer 服务与DB 数据库的连接**

```
find / -name c3p0.properties  有四个这样的文件都要改

vim  /root/chat/RainbowChatMQServer/src/c3p0.properties
vim  /root/chat/RainbowChatMQServer/bin/c3p0.properties
vim /root/chat-compose/tomcat/tomcat/webapps/RainbowChatServer/WEB-INF/classes/c3p0.properties
vim   /root/chat/RainbowChatMQServer/deploy/RainbowChatMQServer_deploy_20190401/classes/c3p0.properties

```

![image-20191215234929345](https://s2.ax1x.com/2019/12/16/QhJ0K0.png)

以上共 3 项配置：**修改 DB 的连接 URL、用户名、密码为您自已的RainbowChat 数据库即可**



**3,启动 RainbowChatMQServer 服务**

直接运行 run.sh 文件即可，如果java环境没有设置变量的话就做相应的修改

```
cd /root/chat-compose/chatweb-server/RainbowChatMQServer/deploy/RainbowChatMQServer_deploy_20190401
nohup sh run.sh &
```

4，tomcat配置证书。

```
vim  /root/chat-compose/tomcat/tomcat/conf/server.xml

<Connector port="8443" protocol="org.apache.coyote.http11.Http11Protocol"
               maxThreads="150" SSLEnabled="true" scheme="https" secure="true"
               clientAuth="false" sslProtocol="TLS" keystoreFile="conf/seeyou-icu-tomcat-1227125632.jks" keystorePass="123.shui" sslprotocol="TLS" />

```

![ssl.png](https://s2.ax1x.com/2019/12/28/leMunO.png)

5，www.js也需要打开https,并写上证书的路径

```
vim  /root/chat-compose/chat-web/RainbowChatServer_web/bin/www.js
```

![19D7JP.png](https://s2.ax1x.com/2020/01/19/19D7JP.png)

然后重启

6, 更新apk包，需要修改一个文件apk_version.properties 

```
find / -name apk_version.properties

```

[![3r4gdx.png](https://s2.ax1x.com/2020/02/29/3r4gdx.png)](https://imgchr.com/i/3r4gdx)



```
docker-compose down
修改了什么最好就先删除镜像
docker images
docker rmi tomcat_chatweb-server


docker-compose up -d --build
数据库
MYSQL_ROOT_PASSWORD: 123.Shui!.shui123
```

**后期更新部署注意事项**

1，更新app ,可以不用停docker-compose down  ,直接去tomcat替换就可以，然后重启容器





最后的画面

![image-20191216003724192](https://s2.ax1x.com/2019/12/16/QhJ654.png)



![注册](https://s2.ax1x.com/2019/12/16/QhYfYQ.png)

![liantian](https://s2.ax1x.com/2019/12/16/QhUSZ6.png)



