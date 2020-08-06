[toc]



## haproxy概述

haproxy	   支持4层，7层负载均衡，反向代理,会话保持，大并发。
LVS	   稳定，效率高，四层调度。不支持7层的内容分发或过滤。不支持会话保持。
nginx	   支持七层调度，现在也有开发的新的模块来扩展调度相关的功能。在会话保持，内容分发过滤方面比haproxy相比要差

1. HAProxy 是一款提供高可用性、负载均衡以及基于TCP（第四层）和HTTP（第七层）应用的代理软件，支持虚拟主机，它是免费、快速并且可靠的一种解决方案。 HAProxy特别适用于那些负载特大的web站点，这些站点通常又需要会话保持或七层处理。HAProxy运行在时下的硬件上，完全可以支持数以万计的 并发连接。并且它的运行模式使得它可以很简单安全的整合进您当前的架构中， 同时可以保护你的web服务器不被暴露到网络上。
2. HAProxy 实现了一种事件驱动、单一进程模型，此模型支持非常大的并发连接数。多进程或多线程模型受内存限制 、系统调度器限制以及无处不在的锁限制，很少能处理数千并发连接。事件驱动模型因为在有更好的资源和时间管理的用户端(User-Space) 实现所有这些任务，所以没有这些问题。此模型的弊端是，在多核系统上，这些程序通常扩展性较差。这就是为什么他们必须进行优化以 使每个CPU时间片(Cycle)做更多的工作。
3. HAProxy 支持连接拒绝 : 因为维护一个连接的打开的开销是很低的，有时我们很需要限制攻击蠕虫（attack bots），也就是说限制它们的连接打开从而限制它们的危害。 这个已经为一个陷于小型DDoS攻击的网站开发了而且已经拯救了很多站点，这个优点也是其它负载均衡器没有的。
4. HAProxy 支持全透明代理（已具备硬件防火墙的典型特点）: 可以用客户端IP地址或者任何其他地址来连接后端服务器. 这个特性仅在Linux 2.4/2.6内核打了cttproxy补丁后才可以使用. 这个特性也使得为某特殊服务器处理部分流量同时又不修改服务器的地址成为可能。

```
http://www.haproxy.org/#docs   #haproxy官方社区
www.haproxy.com

http://cbonte.github.io/haproxy-dconv/2.1/configuration.html#2  #文档配置
```

```
wget http://www.haproxy.org/download/2.2/src/haproxy-2.2.0.tar.gz  #下载源码 这个版本编译会报错。
wget http://www.haproxy.org/download/1.8/src/haproxy-1.8.25.tar.gz  #下载稳定版本
```

## 开始部署haproxy

##  编译安装

```
打开IP转发
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf && sysctl -p

 安装依赖
yum install -y gcc gcc-c++ pcre pcre-devel openssl openssl-devel systemd-devel


tar xf haproxy-1.8.25.tar.gz #解压
cd haproxy-1.8.25/
uname -r   #查询系统内核版本
make TARGET=linux31 PREFIX=/usr/local/haproxy

make install PREFIX=/usr/local/haproxy

可执行文件拷贝一份到系统执行文件目录，该目录在path变量里面，可以直接使用haproxy命令
cp /usr/local/haproxy/sbin/haproxy /usr/sbin/
cp ./examples/haproxy.init /etc/init.d/haproxy
chmod 755 /etc/init.d/haproxy

useradd -r haproxy
mkdir /etc/haproxy　
```

编写配置文件

```
vim /etc/haproxy/haproxy.cfg
# Global settings
#---------------------------------------------------------------------
global #全局配置
 log 127.0.0.1 local3 info #指定服务器的日志级别
 chroot /usr/local/haproxy #改变工作目录
 user haproxy #用户组和用户
 group haproxy
 daemon #以守护进程的方式运行
 maxconn 4000 #最大连接数
defaults #默认配置
 log global
 mode http #7层http;4层tcp 如果要让haproxy支持虚拟主机，mode 必须设为http
 option httplog #http日志格式
 timeout connect 5000 #连接超时(毫秒)
        timeout client 50000 #客户端超时(毫秒)
        timeout server 50000 #服务器超时(毫秒)
 listen stats
 mode http
 bind 192.168.224.11:1080
 stats enable             
 stats hide-version
 stats uri /stats
 stats admin if TRUE
frontend web_front #前端配置 web_front名称可自定义
 bind 192.168.224.11:80 #发起的http请求到80端口，会转发到设置的ip及端口
 mode http
 log global
 option httplog # 启用http日志
        default_backend http_back
backend http_back #后端配置，http_back名称可自定义
 option httpchk GET /index.html #设置健康检查页面
 option forwardfor header X-Forwarded-For #传递客户端真实IP
 balance roundrobin #roundrobin 轮询方式
# 需要转发的ip及端口
 server client2.com 192.168.224.12:80 check inter 2000 rise 3 fall 3 weight 30
 server client3.com 192.168.224.13:80 check inter 2000 rise 3 fall 3 weight 30
 server client4.com 192.168.224.14:80 check inter 2000 rise 3 fall 3 weight 30
```

日志配置

```
打开rsyslog配置：
vi /etc/rsyslog.conf
去掉下面两行前面的#号
$ModLoad imudp
$UDPServerRun 514
并添加下面一行
local3.* /var/log/haproxy.log  
重启rsyslog
systemctl restart rsyslog

```

启动haproxy

```
service haproxy start
```

代理段配置

```
defaults <name> #为frontend, backend, listen提供默认配置
 frontend <name> # 前端，相当于nginx, server {}
 backend <name> #后端，相当于nginx, upstream {}
 listen <name>同时拥有前端和后端,适用于一对一环境
 mode http #默认的模式mode { tcp|http|health }，tcp是4层，http是7层，health只会返回OK
 log global #应用全局的日志配置
 option httplog # 启用日志记录HTTP请求，默认haproxy日志记录是不记录HTTP请求日志
 option dontlognull # 启用该项，日志中将不会记录空连接。所谓空连接就是在上游的负载均衡器或者监控系统为了探测该服务是否存活可用时，需要定期的连接或者获取某一固定的组件或页面，或者探测扫描端口是否在监听或开放等动作被称为空连接；官方文档中标注，如果该服务上游没有其他的负载均衡器的话，建议不要使用该参数，因为互联网上的恶意扫描或其他动作就不会被记录下来
 option http-server-close #每次请求完毕后主动关闭http通道
 option forwardfor except 127.0.0.0/8 #如果服务器上的应用程序想记录发起请求的客户端的IP地址，需要在HAProxy上配置此选项， 这样 HAProxy会把客户端的IP信息发送给服务器，在HTTP请求中添加"X-Forwarded-For"字段。启用X-Forwarded-For，在requests头部插入客户端IP发送给后端的server，使后端server获取到客户端的真实IP。
 option redispatch #当使用了cookie时，haproxy将会将其请求的后端服务器的serverID插入到cookie中，以保证会话的SESSION持久性；而此时，如果后端的服务器宕掉了， 但是客户端的cookie是不会刷新的，如果设置此参数，将会将客户的请求强制定向到另外一个后端server上，以保证服务的正常。
 retries 3 # 定义连接后端服务器的失败重连次数，连接失败次数超过此值后将会将对应后端服务器标记为不可用
 timeout http-request 10s #http请求超时时间
 timeout queue 1m #一个请求在队列里的超时时间
 timeout connect 10s #连接超时时间
 timeout client 1m #客户端超时时间
 timeout server 1m #服务器端超时时间
 timeout http-keep-alive 10s #设置http-keep-alive的超时时间
 timeout check 10s #检测超时时间
 maxconn 3000 #每个进程可用的最大连接数
 frontend main *:80 #监听地址为80
 acl url_static path_beg -i /static /images /javascript /stylesheets
 acl url_static path_end -i .jpg .gif .png .css .js
 use_backend static if url_static
 default_backend my_webserver #定义一个名为my_app前端部分。此处将对应的请求转发给后端
 backend static #使用了静态动态分离（如果url_path匹配 .jpg .gif .png .css .js静态文件则访问此后端）
 balance roundrobin #负载均衡算法（#banlance roundrobin 轮询，balance source 保存session值，支持static-rr，leastconn，first，uri等参数）
 server static 127.0.0.1:80 check #静态文件部署在本机（也可以部署在其他机器或者squid缓存服务器）
 backend my_webserver #定义一个名为my_webserver后端部分。PS：此处my_webserver只是一个自定义名字而已，但是需要与frontend里面配置项default_backend 值相一致
 balance roundrobin #负载均衡算法
 server web01 172.31.2.33:80 check inter 2000 fall 3 weight 30 #定义的多个后端
 server web02 172.31.2.34:80 check inter 2000 fall 3 weight 30 #定义的多个后端
 server web03 172.31.2.35:80 check inter 2000 fall 3 weight 30 #定义的多个后端
```



## haproxy部署方式

下图中haproxy用了两个网段(这里模拟内外网),实际时也可以只用一个网卡(只有内网网卡),公网IP在前端就可以了.这里尽量用两个内网来做，防止桥接网络IP冲突. 



			   客户端（宿主机) 192.168.2.x	
			     |			
			     |	
		外网	     |		192.168.2.65
			  haproxy   
		内网	     |		192.168.224.10
			     |			   
			     |
			web1     	 web2
		192.168.224.11	       192.168.224.12



实验前准备: (centos7.3平台)
1，配置主机名和主机名互相绑定

```
hostnamectl set-hostname --static server.com

vim /etc/hosts
192.168.224.10	server.com
192.168.224.11	server1.com
192.168.224.12   server2.com
```

2,静态ip
3,关闭iptables，selinux




第一步：
1,客户端准备
客户端有firefox和curl就可以了


2,后台web服务器准备　
把web1和web2装好httpd，然后启动起来，分别做一个不同内容的主页方便验证
web1上做：
```
yum install httpd httpd-devel -y
systemctl start httpd
systemctl enable httpd
echo web1 > /var/www/html/index.html
```
web2上做：
```
yum install httpd* -y
systemctl start httpd
systemctl enable httpd
echo web2 > /var/www/html/index.html

```

第二步：
在haproxy服务器上安装haproxy

```
 yum install haproxy -y

/usr/share/doc/haproxy-1.5.18/haproxy-en.txt	#参数文档
/etc/haproxy/haproxy.cfg	#主配置文件

```

第三步:

配置haproxy

配置结构介绍:
global 
	全局配置参数（主要配置服务用户，pid,socket,进程，chroot等)

defaults
	负载调度相关的全局配置　（调度模式，调度超时时间，调度算法，健康检查等等。配置在这个段，那么就默认对后面的listen,frontend,backend都生效)

frontend	
	处理前台接收的请求，可以在这个段配置acl进行七层调度等，指定调到对应的backend
backend
	最终调度的realserver相关配置

listen (就是frontend和backend的综合体)

先备份
```
cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak
 grep -v '#' /etc/haproxy/haproxy.cfg	 #下面是我的配置示例（global,defaults都基本没有调整，优化相关参数请参考文档和实际生产环境做调整)
 
```
```
global
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
    
    stats socket /var/lib/haproxy/stats

defaults
    mode                    http			#支持7层负载均衡，如果改成tcp就只支持4层负载均衡
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s


listen  192.168.2.65 *:80
        balance roundrobin    #roundrobin 轮询方式
        server server1.com 192.168.224.11:80
        server server2.com 192.168.224.12:80
```
启动haproxy
```
systemctl start haproxy
systemctl enable haproxy
```
客户端　curl 192.168.2.65 测试

把上面的listen配置段改成下面的frontend和backend，效果一样
```
frontend  192.168.2.65 *:80
        default_backend webs

backend webs
	balance roundrobin
        server server1.com 192.168.224.11:80
        server server2.com 192.168.224.12:80
```
--------------------------------------------------------

```
systemctl restart haproxy
systemctl enable haproxy
```

第四步:
客户端　curl 192.168.2.65 测试

结果为rr轮循web1,web2


========================================================================
查看haproxy状态页面，
实际这个页面显示的内容为haproxy的状态页面，不是后台web的显示内容。下面参数中之所以有两台web服务器，是为了统计web服务器的状态。

#配置文件listen配置段加上stats的四行(将listen替换为下面)

```
listen  192.168.2.65 *:80
	stats uri /haproxy-stats 	#指定访问的路径	
        stats realm Haproxy\ statistics	#指定统计信息提示
        stats auth name:123		#需要验证的用户名和密码才能登录查看
	stats hide-version		#隐藏客户端访问统计页面时的haproxy版本号
        balance roundrobin   
        server server1.com 192.168.224.11:80
        server server2.com 192.168.224.12:80

systemctl reload haproxy.service
```

#客户端使用下面的去访问
`http://192.168.2.65/haproxy-stats`

```
输入名字 name
密码    123
```

![adeQvF.png](https://s1.ax1x.com/2020/08/03/adeQvF.png)



或者换成下面的配置，效果一样

```
frontend  192.168.2.65 *:80
	  default_backend servers

backend servers
	stats uri /haproxy-stats
        stats realm Haproxy\ statistics
        stats auth li:li123
	stats hide-version	
        balance roundrobin
        server server1.com 192.168.224.11:80
        server server2.com 192.168.224.12:80

```
-客户端使用下面的去访问
`http://192.168.2.65/haproxy-stats`

＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

### 关于haproxy日志


vim /etc/rsyslog.conf
```
$ModLoad imudp
$UDPServerRun 514	#打开这两句的注释，表示udp协议514端口接收远程日志（haproxy日志做到127.0.0.1的本地，也要按远程日志做法来做)

local2.*      /var/log/haproxy.log	#加上这一句，表示local2日志设备的所有级别日志都会记录到后面的文件路径中(local2是和haproxy里的配置对应的。这条语句加在“$UDPServerRun 514”之后）
local2  指的是 /etc/haproxy/haproxy.cfg 里面 26 行

systemctl restart rsyslog.service
tail -f /var/log/haproxy.log (默认此文件不存在，但是有用户访问网站，日志文件就开始生成，并开始输出日志)

```
＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

### haproxy的健康检查功能和日志处理。

 原理是在指定位置放置文件，如果文件存在则认为服务器是健康，否则认为web服务不可用。

vim /etc/haproxy/haproxy.cfg 替换listen整段
```
listen  192.168.2.65 *:80
    stats uri /haproxy-stats
        stats realm Haproxy\ statistics
        stats auth li:li123
    stats hide-version
        balance roundrobin
        option forwardfor		#日志forward，让后台web记录客户端的IP，而不是haproxy的IP
        option httpchk HEAD /check.txt HTTP/1.0	#健康检查功能如果后台web服务器家目录中没有check.txt文件，则表示后台web挂掉；此版本要使用http的1.0版，1.1版还不支持
        server server1.com 192.168.224.11:80 check inter 2000 rise 2 fall 5
        server server2.com 192.168.224.12:80 check inter 2000 rise 2 fall 5	#加上检查的间隔2秒，rise 2, 是2次正确表示服务器可用；fall 5表示5次失败表示服务器不可用

```


创建健康检查文件
On Web1
touch /var/www/html/check.txt

On Web2:
touch /var/www/html/check.txt

重新加载

`systemctl reload haproxy `  
服务正常
curl 192.168.224.10  正常显示

客户端验证健康检查：
尝试删除文件/var/www/html/check.txt，然后运行命令 curl 192.168.224.10，观察结果变化.结果为有check.txt文件的则可以被调，没有的就不可以.

**日志问题1**
在web服务器端
vim /var/log/httpd/access_log 
后台web里每２秒都会有一句healthcheck的日志，想删除他，方法如下


方法一:
写一个脚本就如下两句，定时去执行一次就可以了
```
sed -i '/check.txt\ HTTP\/1.0/d' /var/log/httpd/access_log 
note: sed -i 配合字符串末尾的‘d’，实现删除特定字符串

kill -HUP `cat /var/run/httpd/httpd.pid`   
(sed命令修改access_log会导致文件被httpd进程无法持续写入日志 kill -HUP让httpd重启服务)
(如果想要更改配置而不需停止并重新启动服务，请使用该命令。在对配置文件作必要的更改后，发出该命令以动态更新服务配置)
```

方法二: (推荐)
httpd不记录检测日志:	#健康检查有大量的日志，指定不记录它. 

```
vim /etc/httpd/conf/httpd.conf, 搜索'CustomLog'，然后修改。(或者注释217行增加下面2行)

SetEnvIf Request_URI "^/check\.txt$" dontlog
CustomLog logs/access_log combined env=!dontlog

只要匹配到请求uri为 check.txt 就不记录日志。
```
重启后端的web服务器
systemctl restart httpd



**日志问题２:**
查看后端web的access.log，客户端的正常访问日志的IP并不是实际客户端IP，而是haproxy的内网IP

解决方法如下：
方法一：
直接使用前端haproxy的日志

方法二：
后端apache日志处理  #为了让access.log显示客户端的IP，而不是haproxy调度器的IP
配置

```
vim /etc/httpd/conf/httpd.conf                   #196行

LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b " combined   #加这行  
#把原来的combined条目替换 (或者增加这行)

    
```

![ade8b9.png](https://s1.ax1x.com/2020/08/03/ade8b9.png)



========================================================================



### haproxy会话保持

1,source算法（类似nginx的ip_hash算法或lvs的sh算法)
```

vim /etc/haproxy/haproxy.cfg 替换 listen段

listen  192.168.2.65 *:80
    stats uri /haproxy-stats
        stats realm Haproxy\ statistics
        stats auth li:li123
    stats hide-version
        balance source			  #把roundrobin改为source
        option forwardfor
        option httpchk HEAD /check.txt HTTP/1.0
        server server1.com 192.168.224.11:80 check inter 2000 rise 2 fall 5
        server server2.com 192.168.224.12:80 check inter 2000 rise 2 fall 5

```

`systemctl reload haproxy `   #reload后客户端测试
测试结果为一个客户端的请求会转发到同一个web服务器上。（亲缘性保持）


2,使用cookie(对浏览器有效，对elinks无效）

vim /etc/haproxy/haproxy.cfg

```
listen  192.168.2.65 *:80
    stats uri /haproxy-stats
        stats realm Haproxy\ statistics
        stats auth li:li123
    stats hide-version
        balance roundrobin
        option forwardfor
        option httpchk HEAD /check.txt HTTP/1.0
        cookie web_cookie insert nocache     #web_cookie为名称；当客户端和HAProxy之间存在缓存时，建议将insert配合nocache一起使用
        server server1.com 192.168.224.11:80 cookie web1 check inter 2000 rise 2 fall 5
        server server2.com 192.168.224.12:80 cookie web2 check inter 2000 rise 2 fall 5	 web1和 web2为后端web的cookie名称，不要一样

```

systemctl reload haproxy  reload后客户端测试
测试结果为：使用浏览器访问可以保持亲缘性会话，但是用curl工具则无法保持，因为curl不支持session



3,利用haproxy内置的`stick table` 来实现会话保持。
`stick table` 是haproxy的一个非常优秀的特性，这个表里面存储的是stickiness记录，stickiness记录了客户端和服务端1:1对应的引用关系。通过这个关系，haproxy可以将客户端的请求引导到之前为它服务过的后端服务器上，也就是实现了会话保持的功能。这种记录方式，俗称会话粘性(stickiness)，即将客户端和服务端粘连起来。

stick table中使用key/value的方式映射客户端和后端服务器，key是客户端的标识符，可以使用客户端的源ip(50字节)、cookie以及从报文中过滤出来的部分String。value部分是服务端的标识符。


由于每条stickiness记录占用空间都很小(平均最小50字节，最大166字节，由是否记录额外统计数据以及记录多少来决定占用空间大小)，使得即使在非常繁忙的环境下多个节点之间推送都不会出现压力瓶颈和网络阻塞(可以按节点数量、stickiness记录的大小和平均并发量来计算每秒在网络间推送的数据流量)。

它不像被人诟病的session复制(copy)，因为session复制的数据量比较大，而且是在各应用程序服务器之间进行的。而一个稍大一点的核心应用，提供服务的应用程序服务器数量都不会小，这样复制起来很容出现网络阻塞。

此外，`stick table` 还可以在haproxy重启时，在同一个机器内新旧两个进程间进行复制，这是本地复制。当haproxy重启时，旧haproxy进程会和新haproxy进程建立TCP连接，将其维护的`stick table` 推送给新进程。这样新进程不会丢失粘性信息，和其他节点也能最大程度地保持同步，使得其他节点只需要推送该节点重启过程中新增加的stickiness记录就能完全保持同步。

vim /etc/haproxy/haproxy.cfg    (替换listen块)
```
listen  192.168.2.65 *:80
	stick-table type ip size 1m expire 1m
        stick on src         #以源ip为key进行粘贴，size 1m表示能记录100W条，1分钟没请求粘贴过期					
        stats uri /haproxy-stats
        stats realm Haproxy\ statistics
        stats auth li:li123
        stats hide-version
    balance roundrobin
        option forwardfor
        option httpchk HEAD /check.txt HTTP/1.0
        server server1.com 192.168.224.11:80 check inter 2000 rise 2 fall 5
        server server2.com 192.168.224.12:80 check inter 2000 rise 2 fall 5

```
`systemctl reload haproxy `   重新加载后客户端测试
注意：这里最好用listen格式写，用frontend,backend格式写的话，以源ip为key的参数不生效。

验证：
无论使用Curl还是浏览器都可以保持亲缘性会话。

第二次做实验用frontend,backend格式写，以源ip为key的参数可以生效。测试时间(2020-7-13)

```
frontend  192.168.224.10 *:80
         fefault_backend servers

backend servers
        stick-table type ip size 1m expire 1m
        stick on src

        stats uri /haproxy-stats
        stats realm Haproxy\ statistics
        stats auth li:li123
        stats hide-version

        balance roundrobin
        option forwardfor
        option httpchk HEAD /check.txt HTTP/1.0
        server server1.com 192.168.224.11:80  check inter 2000 rise 2 fall 5
        server server2.com 192.168.224.12:80  check inter 2000 rise 2 fall 5

listen statspage           # 定义监控管理接口的界面
    bind *:8888            # 定义访问页面端口
    stats enable           # 启用管理界面
    stats hide-version     # 隐藏版本
    stats uri /admin?stats    # 访问路径
    stats auth li:li123    # 访问时需要验证登录
    stats admin if TRUE    # 如果登录成功就可以管理在线服务器
```



==============================================================



### 使用haproxy做动静分离或网站数据切分（七层调度)

**通过HAProxy的ACL规则实现智能负载均衡**

**由于HAProxy可以工作在七层模型下， 因此，要实现HAProxy的强大功能，一定要使用强大灵活的ACL规则，通过ACL规则可以实现基于HAProxy的智能负载均衡系统。HAProxy通过ACL规则完成两种主要的功能，分别是：
**

1）通过设置的ACL规则检查客户端请求是否合法。如果符合ACL规则要求，那么就将放行，反正，如果不符合规则，则直接中断请求。

2）符合ACL规则要求的请求将被提交到后端的backend服务器集群，进而实现基于ACL规则的负载均衡。

HAProxy中的ACL规则经常使用在frontend段中，使用方法如下：

acl 自定义的acl名称 acl方法 -i [匹配的路径或文件]

其中：

acl：是一个关键字，表示定义ACL规则的开始。后面需要跟上自定义的ACL名称 。

acl方法:这个字段用来定义实现ACL的方法，HAProxy定义了很多ACL方法，经常使用的方法有hdr_reg(host)、hdr_dom(host)、hdr_beg(host)、url_sub、url_dir、path_beg、path_end等。

-i：表示忽略大小写，后面需要跟上匹配的路径或文件或正则表达式。

与ACL规则一起使用的HAProxy参数还有use_backend，use_backend后面需要跟上一个backend实例名，表示在满足ACL规则后去请求哪个backend实例，与use_backend对应的还有default_backend参数，它表示在没有满足ACL条件的时候默认使用哪个后端backend。

下面列举几个常见的ACL规则例子：

```
acl www_policy hdr_reg(host) -i ^(www.z.cn|z.cn)

acl bbs_policy hdr_dom(host) -i bbs.z.cn

acl url_policy url_sub -i buy_sid=

use_backend server_wwwifwww_policy

use_backend server_appifurl_policy

use_backend server_bbsifbbs_policy

default_backend server_cache
```

一个动静分离的例子

```
acl url_static path_beg -i /data/static/images/javascript/stylesheets #url开头为这些的静态内容

acl url_static path_end -i .jpg .gif .png .css .js .html .ico #url结尾带为这些的静态内容

use_backend staser if url_static #如果静态内容符合url_static的条件，就调度到staser中的服务器

default_backend      dyser  #其他默认调度到dyser中的服务器
```



实例

```
vim /etc/haproxy/haproxy.cfg    (替换listen块)

frontend 192.168.2.65 *:80
   # acl invalid_src src 192.168.2.x    #如果你要拒绝它访问，就把注释打开   
      block if invalid_src 

      acl url_static path_end .html .png .jpg .css .js      #url_static相当于变量名   		#path_end表示以什么结束的文件，表示以.html .png .jpg .css .js 结尾的uri 都是url_static
     
        use_backend static if url_static          #static 为自定义名，
        # usr_backend表示使用backend服务，if表示如果满足url_static这个条件就调度到static这台服务器上也就是server1.com  
       default_backend dynamic                       #dynamic  为自定义名 其他类型转发给dynamic 

backend static  # 定义调用后端的静态页面的服务器上
    balance roundrobin
    server server1.com 192.168.224.11:80 check inter 2000 rise 2 fall 5
	    
backend dynamic
    balance roundrobin
    server server2.com 192.168.224.12:80 check inter 2000 rise 2 fall 5

```
![adea8K.png](https://s1.ax1x.com/2020/08/03/adea8K.png)



 `systemctl restart haproxy` 

测试结果：
    .html .png .jpg .css .js 被认为是静态文件，都会转发到 224.11, 其他类型的文件请求都会被转发到224.12
测试方法：
    在web服务器上建立.txt类型的文件测试是否请求会被转发到224.12. 也可以请求不存在的文件，haproxy仍然会将请求转发到后台web。通过查看后台web日志可以判定请求被转发到了那个web. web日志查看命令： tail -f /var/log/httpd/access_log

```
echo web1-html > /var/www/html/1.html
echo web1-txt > /var/www/html/1.txt

echo web2-html > /var/www/html/1.html
echo web2-txt > /var/www/html/1.txt

curl 192.168.224.10/1.html
web1-html
curl 192.168.224.10/1.txt
web2-txt
```



### 实现网站切分

 vim /etc/haproxy/haproxy.cfg    (替换listen块)

```
frontend 192.168.2.65 *:80
	acl url_static  path_beg    /static /images /img  
    acl url_static  path_end .html .png .jpg .css .js         #url_static相当于变量名
    
    acl host_static hdr_beg(host) -i img. video. download.    #host_static相当于变量名
    acl host_www    hdr_beg(host) -i www       #定义ACL名称为host_www,对应的请求的主机头是www

  use_backend static if url_static               #满足条件就调度到static中的服务器中
  use_backend static if host_static    #主机头包含host_static定义的内容就调度到static中             
  use_backend dynamic if host_www 

backend static                                              #定义static服务器。
    balance roundrobin
    server server1.com 192.168.224.11:80 check inter 2000 rise 2 fall 5

backend dynamic
    balance roundrobin
    server server2.com 192.168.224.12:80 check inter 2000 rise 2 fall 5
```



在客户端编辑hosts

vim /etc/hosts
```
192.168.2.65    www.abc.com
192.168.2.65    img.abc.com
```
测试结果：

```
curl http://www.abc.com                  -> Web2
curl http://www.abc.com/static/abc.abc   -> Web1
curl http://192.168.2.65/1.html          -> Web1
curl http://img.abc.com/static/abc.abc   -> Web1
```

重点：
`http://www.abc.com`  因为是www开头，所以定义为动态内容
`http://www.abc.com/static/abc.abc ` 尽管/www开头，但是由web1处理，

如果URL同时命中了多条ACL规则，那URL结尾所访问的文件类型优先级别最高

Lvs, Haproxy, Nginx这几种软件的特点。

squid,,nginx cache可以做缓存加速

开源负载均衡
nginx
harpoxy
lvs

lvs  四层
nginx,haproxy  七层

抗并发   lvs >  haproxy  > nginx
应用范围 lvs最广
网络复杂度 lvs复杂
会话保持  haproxy会话保持的方式较多
负载均衡算法   lvs最多



========================================================================