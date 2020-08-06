[toc]

## 概述

lamp
lnmp		php

windows server+ IIS + sqlserver + .net

linux + apache/nginx + mysql + php. (LAMP/LNMP)

linux + tomcat/jboss/weblogic/websphere/resin +  mysql/oracle/db2 + java



=======================================================================================


名词
jdk-Java开发包 (jre-Java运行时环境,jvm-Java虚拟机)       (跑任何java程序或软件，都需要先安装jdk)
j2ee	javaee  Enterprise Edition - Java企业级版本 
j2se    javase  Standard Edition   - Java标准版本
j2me    javame  Micro Edition  - Java微型版本（用于手机等运算能力/电量有限的设备）




j2ee平台由一整套服务，应用程序接口和协议规范组成

Java 2 Platform,Enterprise Edition

Java应用程序服务器-application server
tomcat  (apache软件基金会)
jboss	wildfly　　（redhat)
weblogic  (oracle）
websphere	(IBM)
resin		(CAUCHO)

=======================================================================================



	tomcat   
	   
	apache + tomcat  

官网地址:

```
http://tomcat.apache.org/
```



JDK  （java   development  kit）  ，JDK是整个JAVA的核心，包括了JAVA运行环境，JAVA工具和基础类库等。



## tomcat的安装过程

在client1执行Java安装

```
java官方下载地址 下载需要oracle账户。
https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html#license-lightbox

1,解压安装jdk

 tar xf jdk-8u45-linux-x64.tar.gz -C /usr/local/
 重命名
mv /usr/local/jdk1.8.0_45 /usr/local/jdk1.8

 ls /usr/local/jdk1.8/		确认解压成功
 
bin        javafx-src.zip  man          THIRDPARTYLICENSEREADME-JAVAFX.txt
COPYRIGHT  jre             README.html  THIRDPARTYLICENSEREADME.txt
db         lib             release
include    LICENSE         src.zip


```
2,解压安装新版本tomcat

官方下载地址

```
https://downloads.apache.org/tomcat/

wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.37/bin/apache-tomcat-9.0.37.tar.gz
```

解压

```

tar xf apache-tomcat-8.0.20.tar.gz -C /usr/local/
mv /usr/local/apache-tomcat-8.0.20/ /usr/local/tomcat
```

3,tomcat的环境变量的定义

定义在单个tomcat的启动和关闭程序里

```
vim /usr/local/tomcat/bin/startup.sh 
vim /usr/local/tomcat/bin/shutdown.sh  
```

把`startup.sh` 和`shutdown.sh` 这两个脚本里的最前面(但要在#!/bin/bash下在)加上下面一段

```
export JAVA_HOME=/usr/local/jdk1.8/
export TOMCAT_HOME=/usr/local/tomcat
export CATALINA_HOME=/usr/local/tomcat
export CLASS_PATH=$JAVA_HOME/bin/lib:$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tool.jar
export PATH=$PATH:/usr/local/jdk1.8/bin:/usr/local/tomcat/bin
```

启动方法
可以把启动文件加入环境变量

```
vim /etc/profile
在最后一行加上
export PATH=$PATH:/usr/local/tomcat/bin/

执行一下profile文件,使配置生效   
source   /etc/profile
```

启动：   `startup.sh` 

```
 /usr/local/tomcat/bin/startup.sh

Using CATALINA_BASE:   /usr/local/tomcat
Using CATALINA_HOME:   /usr/local/tomcat
Using CATALINA_TMPDIR: /usr/local/tomcat/temp
Using JRE_HOME:        /usr/local/jdk1.8/
Using CLASSPATH:       /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar
Tomcat started.
```



` lsof -i:8080`		#端口还是8080

```
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
java    4224 root   44u  IPv6  40596      0t0  TCP *:webcache (LISTEN)
```



使用firefox访问
`http://IP:8080` 

可以加到rc.local里做成开机自动启动
 `echo /usr/local/tomcat/bin/startup.sh >> /etc/rc.local` 

关闭方法
 `/usr/local/tomcat/bin/shutdown.sh` 

家目录路径:
` /usr/local/tomcat/webapps/ROOT/` 

`tail -f /usr/local/tomcat/logs/catalina.out` 	 #启动和关闭时，通过查看这个日志来确认是否OK

### 修改监听端口

```
 vim /usr/local/tomcat/conf/server.xml


:69    <Connector port="80" protocol="HTTP/1.1"  #把8080改成80的话重启后就监听80
               connectionTimeout="20000" 
               redirectPort="8443" />
```



2、进入tomcat安装目录中的conf文件夹，并用记事本打开server.xml文件，然后做出如下修改：
（1）修改访问端口，将8080修改为80，80为windows访问http协议的默认端口。修改后的配置如下：
```
 <Connector port="80" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
```
（2）修改访问域名，将原`localhost` 修改为`www.seeyou88.cn` 。修改后的配置如下：
```
 <Host name="www.seeyou88.cn"  appBase="webapps"
            unpackWARs="true" autoDeploy="true"> 

```
（3）在Host标签中添加\<Context>标签，内容如下：
```
<Host name="www.seeyou8.cn"  appBase="webapps"
            unpackWARs="true" autoDeploy="true">
    <Valve .../>
    <Context path="" docBase="RainbowChatServer" debug="0" reloadable="true"></Context> 
</Host>
```
其中：`path` 指定要访问项目的物理路径，可相对路径，也可绝对路径。

`docBase`指定浏览器地址栏中要输入的项目名称，空字符串表示不用输入项目名称； 在此处`RainbowChatServer`，表示的是要访问的项目是`webapps` 下的`RainbowChatServer` 项目。


测试后再改回8080端口

总结一个小错误:
在执行`/usr/local/tomcat/bin/shutdown.sh`关闭时，如果有下面的错误信息
...... 
Jul 28, 2017 11:56:26 AM org.apache.catalina.startup.Catalina stopServer
SEVERE: Could not contact localhost:8005. Tomcat may not be running.
Jul 28, 2017 11:56:26 AM org.apache.catalina.startup.Catalina stopServer
SEVERE: Catalina.stop: 
......

解决方法:

```
 vim /usr/local/jdk1.8/jre/lib/security/java.security 

117 securerandom.source=file:/dev/urandom	#找到这一行，把random改成urandom

再kill杀掉进程重启测试


/dev/random		#用这个设备产生随机数，需要借助外部中断事件（如，动鼠标，敲键盘等）。这样的话在产生大量随机数时有可能会ang住
/dev/urandom		#相对/dev/random来说，不需要借助外部中断事件，产生大量随机数比较快
```



### 目录布署

` mkdir /usr/local/tomcat/webapps/abc` 
把abc目录与ROOT同级或者是在ROOT的下一级都是可行的

```
vim /usr/local/tomcat/webapps/abc/time.jsp


<html>
<body>
<center>
<H1><%=new java.util.Date()%></H1>
</center>
</body>
</html>
```
访问URL：`http://192.168.224.10/abc/time.jsp`  可以看到运行结果。

安装完tomcat后，就可以将开发的java应用装上进行测试了
因为java开发的开源应用非常少，并且很多不支持较新版本的tomcat，我们这里又是实验环境，所以这里简单安装一个jspxcms让大家看下效果

一个开源的java cms系统jspxcms（java内容管理系统）
软件包：jspxcms-5.2.4-release.zip

```
http://www.jspxcms.com/download/  (新版的安装方式会有些不同，可以参考Jspxcms安装手册.pdf)
```


步骤：

1.部署

```
 rm /usr/local/tomcat/webapps/ROOT/*  -rf   #解压之前先删除原来家目录里的文件
 unzip jspxcms-5.2.4-release.zip -d /usr/local/tomcat/webapps/  #(解压jspxcms).
 
 yum install mariadb mariadb-server -y
 systemctl restart mariadb.service
 systemctl status mariadb.service
 systemctl enable mariadb.service
```

2,去mysql建一个库，进行授权

```
 mysql
MariaDB [(none)]> create database jspxcms;
MariaDB [(none)]> grant all on jspxcms.* to 'li'@'localhost' identified by '123';
MariaDB [(none)]> flush privileges;
```



3,访问`http://IP:8080/`按照它的步骤进行安装
	数据库名：jspxcms
	数据库用户名：li
	数据库密码: 123
	是否创建数据库:否
	管理员密码：123



4,重启tomcat后，再使用下面路径访问就可以了（不能通过Xshell启动，要在VMware里面启动）(新版tomcat已经可以通过xshell启动了) 

`/usr/local/tomcat/bin/shutdown.sh `
`/usr/local/tomcat/bin/startup.sh `
前台访问地址:
`http://IP:8080/`
后台访问地址:(需要admin用户和其密码登录才有权限）
`http://IP:8080/cmscp/index.do` 



部署shop

 ls $software/shop
sp.sql  sp.war


简单过程

rm /usr/local/tomcat/webapps/ROOT/*  -rf

把sp.war拷贝到/usr/local/tomcat/webapps/下

然后客户端浏览器使用`http://IP/sp`来访问

 `cat sp.sql | mysql `	 #导入应用需要的库和表

访问：`http://192.168.224.11:8080/sp`

===================================================================



如果一台tomcat顶不住，怎么办?
三个办法:
1，微调(内存，并发数，IO，网络，内核参数等)
2，换更好的硬件，成本高，提升仍然有限
3，架构   （单打独斗转为团队作战） 避免单点故障




以前apache+tomcat+mod_jk进行整合


​				

			apache1	  apache2
			mod_jk	  mod_jk
			  |	     	|	
			  |---------|			
					|
	                |
			tomcat1	   tomcat2


========================================================

现在nginx替代apache，也不需要mod_jk模块


				client


				dns	www.itjiangshi.com


​										
​			nginx1		nginx2  (处理静态)
​			
​			ip_hash
​				
​			tomcat1		tomcat2 (处理动态)  RR
​	
​			1.jsp		
​			2.jsp
​			3.jsp
​			4.jsp


​			
​				dns
​	
​			nginx1		nginx2  	
​	
​			squid1		squid2  (处理静态)
​				
​			tomcat1		tomcat2 (处理动态)  RR
​	
​			memcached1 	memcached2 
​	
​			mariadb1	mariadb2








由于http是无状态的协议，你访问了页面A，然后在访问B，http无法确定这2个访问来自一个人
，因此要用cookie或session来跟踪用户，根据授权和用户身份来显示不同的页面。
比如用户A登陆了，那么能看到自己的个人信息，而B没登陆，无法看到个人信息。
还有A可能在购物，把商品放入购物车，此时B也有这个过程，你无法确定A，B的身份和购物信息，所以需要一个session ID来维持这个过程。



cookie是服务器发给客户端，并且保持在客户端的一个文件，里面包含了用户的访问信息（账户密码等），可以手动删除或设置有效期，在下次访问的时候，会返给服务器。
注意：cookie可以被禁用，所以要想其他办法，这就是session。
比如：你去商场购物，商场会给你办一张会员卡，下次你来出示该卡，会有打折优惠.该卡可以自己保存（cookie），或是商场代为保管，由于会员太多，个人需要保存卡号信息（session ID)



--------------------------------------------------------


一、Session Replication 方式管理 (即session复制)

        简介：将一台机器上的Session数据广播（组播)复制到集群中其余机器上
    
        使用场景：机器较少，网络流量较小
    
        优点：实现简单、配置较少、当网络中有机器Down掉时不影响用户访问
    
        缺点：广播式复制到其余机器有一定廷时，带来一定网络开销


​			
​			300			500
​			张三  		李四		
​	
​		   今天满600块就返100块



二、Session Sticky 方式管理

        简介：即粘性Session、当用户访问集群中某台机器后，强制指定后续所有请求均落到此机器上
    
        使用场景：机器数适中、对稳定性要求不是非常苛刻
    
        优点：实现简单、配置方便、没有额外网络开销
    
        缺点：网络中有机器Down掉时、用户Session会丢失、容易造成单点故障




三、缓存集中式管理

       简介：将Session存入分布式缓存集群中的某台机器上，当用户访问不同节点时先从缓存中拿Session信息
    
       使用场景：集群中机器数多、网络环境复杂
    
       优点：可靠性好
    
       缺点：实现复杂、稳定性依赖于缓存的稳定性、Session信息放入缓存时要有合理的策略写入



			300			    500
			张三  			李四


				 会员卡
	
			今天满600块就返100块


=======================================================================================

## 部署tomcat集群

下面就配置nginx+tomcat+msm(memcached-session-manager)做综合应用.
这里因为有负载均衡，为了让tomcat1和2能够共享session，所以使用msm



下图中:
192.168.2.x/24网络我模拟外网(这里我用kvm的桥接来模拟)
192.168.224.0/24网络我模拟内网(这里我用kvm的virbr1网络来模拟)
	

nginx解析静态页面并将动态负载均衡调度给后面多个tomcat
tomcat解析java动态程序




				client  192.168.2.x
				  |
				  |	    192.168.2.51
			    nginx
				  |     192.168.224.10
				  |
		  |－－－－－－－－－－|
	    tomcat1          tomcat2
	
	 192.168.224.11	  192.168.224.12
	
	               |		 |
		  |------------------|
			       |
			       |		
	     192.168.224.13  memcached服务器

实验前准备:
1,主机名三步绑定
192.168.224.10	nginx.cluster.com
192.168.224.11	tomcat1.cluster.com
192.168.224.12	tomcat2.cluster.com
192.168.224.13	memcached.cluster.com

创建3台centos容器安装

```
创建网络
docker network create -d bridge mytomcat

centos1容器tomcat1
docker run -it --restart=always  --privileged=true --name centos1 -p 8080:8080 -h centos1 --network mytomcat  -v /etc/localtime:/etc/localtime -d centos:7 /usr/sbin/init

centos2容器tomecat2
docker run -it --restart=always  --privileged=true --name centos2 -p 8090:8080 -h centos2 --network mytomcat  -v /etc/localtime:/etc/localtime -d centos:7 /usr/sbin/init

centos3容器memcached
docker run -it --restart=always --privileged=true --name centos3 -p 11211:11211 -h centos3 --network mytomcat  -v /etc/localtime:/etc/localtime -d centos:7 /usr/sbin/init
```

分别进去容器测试是否正常ping通

```

docker exec -it centos1 /bin/bash

docker exec -it centos2 /bin/bash

docker exec -it centos3 /bin/bash

安装相关命令
yum provides ip

yum install -y iproute net-tools vim

ping centos1
ping centos2
ping centos3

vim /etc/hosts
增加


172.19.0.2      centos1 centos1.com
172.19.0.3     centos2 centos2.com
172.19.0.4     centos3 centos3.com

```

给tomcat容器放入软件

```
docker cp jdk-8u45-linux-x64.tar.gz centos1:/root/
docker cp jdk-8u45-linux-x64.tar.gz centos2:/root/
docker cp apache-tomcat-8.0.20.tar.gz centos1:/root  #亲测tomcat9.0的不能和msm配置有冲突。
docker cp apache-tomcat-8.0.20.tar.gz centos2:/root
docker cp msm centos1:/root/
docker cp msm centos2:/root/
```

**开始部署**



2,时间同步
3,关闭iptables,selinux
4,配置yum 

第一步:
1，在192.168.224.10上安装nginx(需要epel源)
 yum install epel-release -y
 yum install nginx -y

2，配置nginx
 `cat /etc/nginx/nginx.conf |grep -v '#' ` 

```

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;
    
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;
    
    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    
    include /etc/nginx/conf.d/*.conf;

upstream tomcat {
	server 192.168.224.11:8080 weight=1;
	server 192.168.224.12:8080 weight=1;
}


    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  192.168.2.51;
        root         /usr/share/nginx/html;
    
        include /etc/nginx/default.d/*.conf;


	location ~ .*\.jsp$ {
	    proxy_pass   http://tomcat;
	        proxy_set_header Host $host;
	        proxy_set_header X-Forwarded-For $remote_addr;
	}


        error_page 404 /404.html;
            location = /40x.html {
        }
    
        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
}

```
 systemctl start nginx
 systemctl status nginx
 systemctl enable nginx

 lsof -i:80

第二步:

在192.168.224.11和192.168.224.12上安装两台tomcat（过程省略,建议tomcat重新安装，因为如果前面tomcat安装了jspxcms这个应用的话，会对后面的测试造成影响)


tomcat1和tomcat2上把下面的软件包都scp到/usr/local/tomcat/lib/目录下

$software/msm/    #这些软件包是针对tomcat8的，如果你是tomcat6或者tomcat7你需要自行网上下载,tomcat9也是不行。

```
 ls $software/msm
asm-3.2.jar                              msm-kryo-serializer-1.8.1.jar
kryo-1.04.jar                            reflectasm-1.01.jar
memcached-session-manager-1.8.1.jar      serializers-0.11.jar
memcached-session-manager-tc8-1.8.1.jar  spymemcached-2.11.1.jar
minlog-1.2.jar
```



` cp *.jar /usr/local/tomcat/lib`  

***
Jar包的作用是进行Class文件的打包管理。里面包含class文件。
***

### 部署msm

第三步:在tomcat部署msm
在tomcat1和tomcat2上操作
 vim /usr/local/tomcat/conf/context.xml  (在此文件的\<Context>和\</Context>里面加上下面一段）

```
<Manager className="de.javakaffee.web.msm.MemcachedBackupSessionManager"
  memcachedNodes="n1:192.168.224.13:11211" 	  #这里的ip为memcached服务器的IP,如果有多个memcached服务器，用逗号隔开
  lockingMode="auto"
  sticky="false"
  requestUriIgnorePattern= ".*\.(png|gif|jpg|css|js)$"  
  sessionBackupAsync= "false"  
  sessionBackupTimeout= "100"  
  copyCollectionsForSerialization="true"  
  transcoderFactoryClass="de.javakaffee.web.msm.serializer.kryo.KryoTranscoderFactory" />
```

并把两台tomcat分别启动（如果你先前启动了要重启)
 /usr/local/tomcat/bin/shutdown.sh
 /usr/local/tomcat/bin/startup.sh
 lsof -i:8080



第四步:
在192.168.224.13上安装并启动memcached(本地yum源就OK)

```
yum install memcached -y
systemctl start memcached.service 	
systemctl status memcached.service
systemctl enable memcached.service
```

` lsof -i:11211` 


第五步:
我这里nginx,tomcat1,tomcat2是合起来做一个应用，所以它们的家目录里的内容应该是一样的，如何让一个应用内容在它们那里一致?
方法1:远程实时rsync同步
方法2:drbd,共享存储或分布式存储(后面课程会讲,但现在也可以使用nfs来模拟共享存储)

在nginx的家目录/usr/share/nginx/html里,并且在tomcat1和tomcat2的家目录`/usr/local/tomcat/webapps/ROOT/`里建立一个测试文件（如果有nfs做共享存储，则只需要建立一次就可以了)

```
 vim session.jsp
web1
SessionID:<%=session.getId()%> <BR>
SessionIP:<%=request.getServerName()%> <BR>
SessionPort:<%=request.getServerPort()%>

```



第六步:
确认nginx和tomcat1和tomcat2和memcached都是启动状态，客户端使用firefox来测试

测试一：
分别在nginx，tomcat1，tomcat2的家目录中创建文件1.html，内容为标识本机的信息.用来测试集群环境下的目标机器。
访问`http://192.168.2.51/1.html`浏览器会显示字符串'nginx',因为在nginx的转发规则中，只有JSP才会被转到后台tomcat服务器
Nginx document root:/usr/share/nginx/htm

测试二：
分别在nginx，tomcat1，tomcat2的家目录中创建文件1.jsp，内容 为机器名称.用来测试集群环境下的目标机器。
访问`http://192.168.2.51/1.jsp `浏览器会显示字符串'tomcat1'，‘tomcat2’ 交替显示。因为在nginx的转发规则中，所有JSP请求都会被转发到后台。

测试三:
`http://192.168.2.51/session.jsp  `  #不断F5刷新，sessionID是不变的

`curl http://192.168.2.51/session.jsp `   #不要使用这种方式来测，这样测试session id是会变的（curl不能像firefox那样存放session id)，但也会存储到memcache中

在memcache服务器上进行下面的操作

```
echo "stats cachedump 3 0" | nc 192.168.224.13 11211 > /tmp/session.txt
 cat /tmp/session.txt |head -1	  #导出的第一行的session ID就等于上面页面刷新时的session id,说明session id  确实存放在memcache里
 
 ITEM validity:A8F853F36B9931DD5ADF51DFB806A0CF-n1 [20 b; 1442225217 s]
```

缓存内容解释：
ITEM validity:
B671A8EAB6A358CD3FB73DA58C76685B-n1 
20 b：Session过期时间
1545374604 s：访问时间

测试四：

客户端自己清除缓存

清除浏览器缓存，session ID会发生改变 



服务端清空缓存的方法：
方法一：交互式命令模式

```
[root@client3 tmp]# nc 192.168.224.13 11211

>flush_all
>quit
>[root@client3 tmp]# 
```

方法二：命令行模式

```
echo "flush_all" | nc localhost 11211
```

这时候去浏览器查看.session ID也会发生改变。

