[toc]




先运行如下语句获取国内IP网段，会保存为/root/china_ssr.txt
```
wget -q --timeout=60 -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > /root/china_ssr.txt
```




防火墙


业界常见个人电脑防火墙软件
瑞星  卡巴斯基  360   金山    江民     腾讯管家	诺顿       天网   ......

概念：
在网络中，所谓“防火墙”，是指一种将内部网和公众访问网(如Internet)分开的方法，它实际上是一种隔离技术。防火墙是 在两个网络通讯时执行的一种访问控制尺度，它能允许你“同意”的人和数据进入你的网络，同时将你“不同意”的人和数据拒之门外，最大限度地阻止网络中的非法访问。

# 1.iptables 

centos7以后都是默认`firewalld`

所以需要先停掉`firewalld`

```
systemctl stop firewalld
systemctl disable firewalld
```

准备虚拟机，安装下面的软件包，并启动服务

```
yum install iptables\*  -y	  #CentOS7已经自带，可以不用装。

yum install -y iptables-services     #自带需要下载这个，要不然不能启动iptables
```

查看相关软件包

```
rpm -qa |grep iptables

iptables-devel-1.4.21-28.el7.x86_64
iptables-services-1.4.21-28.el7.x86_64
iptables-utils-1.4.21-28.el7.x86_64
iptables-1.4.21-28.el7.x86_64
```

启动服务

```
systemctl start iptables.service

systemctl enable iptables.service

systemctl status iptables.service

```



iptables  基本概念  (4张表5链(chain))

`filter` :  	用来进行包过滤：  `INPUT`   `OUTPUT`  `FORWARD`   
`nat` :   		用来网络地址转换：   `network  address translation` ,允许一个内网地址块，通过NAT转换成公网IP，实现对公网的访问，解决IP地址不足
​				PREROUTING  INPUT   POSTROUTING	OUTPUT
​                                源地址发送数据--> {PREROUTING-->路由规则-->POSTROUTING} -->目的地址接收到数据

​      `POSTROUTING`    //路由判断之后的`nat`   `SNAT`  内网访问外网

​      `PREROUTING`    //路由判断之前的`nat`   `DNAT`    外网访问内网

`mangle`  :	用来对数据包标记	
​	 			PREROUTING INPUT OUTPUT  FORWARD  POSTROUTING
`raw` :		对原始数据包的处理
​				PREROUTING	OUTPUT

```


Incoming                 /     \         Outgoing
       -->[Routing ]--->|FORWARD|------->
          [Decision]     \_____/        ^
               |                        |
               |                      ____
              ___                    /    \
             /   \                  |OUTPUT|
            |INPUT|                  \____/
             \___/                      ^
               |                        |
                ----> Local Process ----

 
```

## **1.iptables语法结构** 



```
iptables -h 列出帮助信息。

iptables -t 类型     指令    chain名称  选项   参数  
          -t nat
             filter
             mangle
             raw
指令
    -A --append   追加一条规则，后接链名，默认是加到规则的最后面
    -I --insert   插入规则  chain   编号
	-D --delete   删除     chain   编号
	-R --replace  替换     chain   编号
	-F --flush    清空链规则
	-N --new      自定义链
	-X --delete-chain    删除自定义的空链
	-P --policy    修改默认策略  chain
	
	-L   列出规则 
	-n   以数值显示 
	-v   显示统计数据，与－L一起用，看到的信息更多
    -nL  --line 查看信息，并显示行号

chain(链)
  PREROUTING  //路由判断之前的nat   DNAT    外网访问内网
  POSTROUTING  //路由判断之后的nat  SNAT    内网访问外网
  INPUT       进
  FORWARD     过滤经过防火墙的流量
  OUTPUT      出
  
选项     参数  

来源
  -s --source  地址  		    子网                  网段
              192.168.224.11  192.168.224.32/27   192.168.224.0/24
  -i 进接口 例如: -i ens37 
  
目标
  -d --destnaiton  地址      子网      网段
  -o 出接口  例如:  -o ens37
  
  协议
    -p   tcp --dport  --sport   
         udp --dport  --sport 
         icmp --icmptype  echo-request
                         echo-reply
动作                     
	-j  后接动作
	
	动作的分类：
	
	ACCEPT    接收数据包
	DROP	   丢弃数据包
	REJECT   拒绝数据包，和DROP的区别就是REJECT会返回错误信息，DROP不会
	MASQUERADE  IP地址伪装，使用NAT转换成外网IP，可以PPP拔号（外网IP不固定情况）
	SNAT   源地址转换，它与MASQUERADE的区别是SNAT是接一个固定IP
	DNAT	目标地址转换
	LOG    记录日志

```

nat操作实例

实现内网访问互联网

```
iptables -t nat -A POSTROUTING -s 192.168.224.0/24 -o ens33 -j  MASQUERADE
只要源地址是192.168.224.0网段的 出去任何外网都做源地址转发。都能访问外网。
```

实现外网访问内网

```
iptables -t nat -A PREROUTING -d 192.168.224.12 -i ens33 -p tcp --dport 8080 -j DNAT --to 172.30.0.3:80

只要访问192.168.224.12的8080端口，就转发到内网的172.30.0.3:80端口
```



例1，列规则

```
	iptables -L 	 #默认看的就是filter表
	iptables -t filter -L
	
	iptables -t  nat -L 
	iptables -t  mangle -L 
	iptables -t  raw -L 


 iptables -t filter -F    清除规则
 iptables -t nat -F
 iptables -t mangle -F		这三张表有些默认的规则，我们把规则都清掉
```


例2,控制ping


		192.168.224.x/24   －－－－－－》    192.168.224.10
		  客户端				                 服务器
			               《－－－－－－	


192.168.224.0/24网段ping本机，会被拒绝（客户端会收到拒绝信息)
ping 是icmp协议，ssh,是tcp协议
拒绝来自224.0网段的请求
```
 iptables -t filter -A INPUT -p icmp -s 192.168.224.0/24 -j REJECT
```

抛弃来自224.0网段的请求，不做回应
```
 iptables -t filter -A INPUT -p icmp -s 192.168.224.0/24 -j DROP
```

拒绝通往224.0网段的通讯
```
 iptables -t filter -A OUTPUT -p icmp -d 192.168.224.0/24 -j REJECT

```
抛弃通往224.0网段的通讯
```
 iptables -t filter -A OUTPUT -p icmp -d 192.168.224.0/24 -j DROP
```
参数D删除规则
```
 iptables -t filter -D INPUT -p icmp -s 192.168.224.0/24 -j REJECT
 iptables -t filter -D INPUT -p icmp -s 192.168.224.0/24 -j DROP
 iptables -t filter -D OUTPUT -p icmp -d 192.168.224.0/24 -j REJECT
 iptables -t filter -D OUTPUT -p icmp -d 192.168.224.0/24 -j DROP
```

上面四种方法都可以控制拒绝192.168.224.0/24网段ping本机。前2种是不允许进入，后两种是不做回应。

```
 iptables -t filter -A INPUT -p icmp  -j REJECT   如果不写-s或-d，默认代表所有人
```






扩展:
我想实现所有人都ping不通我，但是192.168.224.11这个IP能ping通我

--提示:iptables的匹配规则:读取的顺序是从上往下一条一条匹配，匹配一条就不继续往下匹配，都没有匹配，则最后匹配默认策略
```
 iptables -t filter -A INPUT -p icmp -j REJECT
 iptables -t filter -A INPUT -p icmp -s 192.168.224.11 -j ACCEPT
```
--此写法错误的,因为默认拒绝所有的策略在前边。

```
 iptables -t filter -I INPUT -p icmp -s 192.168.224.11 -j ACCEPT       -I 在最前面插入规则
 iptables -t filter -A INPUT -p icmp -j REJECT

正确写法，把第二条加到第一条前面。使用I参数加入到第一条规则之前。


iptables -t filter -I INPUT 2 -p icmp -s 192.168.224.13 -j ACCEPT
链后面接数字2，表示插入到原来第二条的上面，成为新的第2条

```



删除的方法：
方法一：

```
 iptables -t filter -D  INPUT -s 192.168.224.11  -p icmp -j ACCEPT
```


加的时候怎么写，删除时就要怎么写  A 参数换成 D就可以

方法二;

```
 iptables -L -n --line  在规则输出的格式上加入行号。		
 iptables  -D INPUT  2   在INPUT组中，删除第二条规则。
```

在规则比较多或者不好写规则的情况下，可以先用--line或者--line-number列出行号，再用行号删除

方法三：

```
 iptables -F   
```


直接清空filter表的所有规则

修改操作:

```
 iptables -t filter -R INPUT 3 -p icmp -s 192.168.224.100 -j ACCEPT
```


把filter表INPUT链第三行，修改成上面的命令的内容



例3，规则的保存与还原

```

iptables-save > /etc/sysconfig/iptables   --将当前规则保存到这个文件，文件可以自定义
iptables-restore < /etc/sysconfig/iptables --把保存的规则还原回去
```

Note:
`/etc/sysconfig/iptables`文件为默认保存文件，重启iptables服务会默认把此文件里的规则还原。当然也可以手工保存到另一个文件，就需要iptables-restore手工还原了。
如果要永久保留此规则，则先`iptables-save > /etc/sysconfig/iptables` 保存,再 `systemctl enable iptables.service` 做成开机自动启动就可以了
如果你想做成开机自动空规则（没有任何iptables策略)，你可以把`etc/sysconfig/iptables`保存为空规则，然后`systemctl enable iptables.service`　

例4，每个链的默认策略的修改 不要用Xshell 连接  想连接也可以，先把配置改下 
                            `192.168.224.1/32`代表宿主机连上虚拟机的网关地址

```

iptables -A INPUT -p tcp -s 192.168.224.1/32 -m mulitiport --dports 22 -j ACCEPT 
iptables -A INPUT -p tcp -d 192.168.224.11/32 -m multiport --sports 22 -j ACCEPT 
iptables -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT
iptables  -A OUTPUT -p icmp -j ACCEPT
```

然后在把默认策略修改为drop,

```
 iptables -P INPUT DROP	      INPUT链默认策略改为DROP，改回来把DROP换成ACCEPT就行了
 iptables -P OUTPUT DROP	  OUTPUT链默认策略改为DROP
```



例5，实现允许ssh过来（代表本机为服务器身份），ssh出去（代表本机为客户端身份），别的任何访问都拒绝  （要求,INPUT和OUTPUT双链默认策略都为DROP）。设置策略后，本机无法作为ssh客户端访问出去。

tcp/22

			三次握手，数据传输，四次挥手 （tcp/ip)
			－－－－－－－－－－－－－》
	
		client				server
			
			<－－－－－－－－－－－－－
	
		192.168.224.11		192.168.224.10
	
		  OUTPUT		     INPUT
		客户端 随机端口 －－－》  服务器  22
		　　　(1024-65535)　	
		客户端 随机端口 《－－－  服务器  22
		  INPUT		           OUTPUT

服务器端防火墙
```
iptables -F
iptables -A INPUT -p tcp --dport 22  -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT
iptables -P INPUT DROP
iptables -P OUTPUT DROP

```

客户端防火墙
```
iptables -F
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22  -j ACCEPT
```

执行上面的语句后，本地就无法连接自己了。执行下面的命令，可以实现本地访问
```
iptables -A INPUT  -i lo  -j ACCEPT
iptables -A OUTPUT -o lo  -j ACCEPT
参数解释：
	-i 表示Input进接口，进入的请求
	-o 表示Output出接口，出去的请求
	lo 表示localhost，也就是本机自己连接自己，localhost对应的IP是127.0.0.1
```

结论：
	在设置白名单运行22号端口通讯后，那么本机作为ssh服务器可以正常提供ssh服务，但是在本机应用了上面的规则以后，本机无法作为SSH客户端去连接出去，因为SSH客户端使用1024-65535的端口范围去连接远程SSH服务器。

练习：
只允许特定的IP访问本地的80端口，其他的主机发来的请求忽略。

答案:和上面做法一样，把22换成80就ok了

===================================

例子：
如果要让本机作为客户端访问SSH，那么需要允许1024-65535端口进来。 这样可以允许本地在双链默认拒绝的情况下，同时提供SSH服务以及作为SSH客户端来使用。
在server执行

```
iptables -F
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 1024:65535 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 1024:65535 -j ACCEPT
```

验证： server可以作为SSH客户端连接远程。



==============================================================================

例子： 如何查询出本机用哪个端口来连接远程的ssh服务

```
yum  install -y net-tools 下载软件netstat

 netstat -ntp  | grep 192.168.224.10
 
tcp        0      0 192.168.224.12:33228    192.168.224.10:22       ESTABLISHED 4506/ssh  
```

参数解释：
	-n 端口使用数字来表示，例如SSH端口使用数字22。
	-p 显示进行PID
	-l 显示监听状态的连接
	-t 显示TCP连接
	-u 显示udp连接

按照上面的查询结果，本机使用60864来连接远程端口。


 lsof -i:33228
[root@client2 ~]# lsof -i:33228
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
ssh     4506 root    3u  IPv4  38908      0t0  TCP client2.example.com:33228->server.example.com:ssh (ESTABLISHED)
lsof命令显示本机33228端口，被ssh客户端占用

由上一条命令查询得知33228端口，被进程4506进程使用。 使用ps命令，查询此端口被哪个应用所占用。

```
ps -ef|grep 4506
root       4506   4420  0 23:20 pts/0    00:00:00 ssh 192.168.224.10
root       5287   3055  0 23:24 pts/1    00:00:00 grep --color=auto 4506

[root@client2 ~]# 
```



## **2.iptables 常用模块**

```
ls /usr/lib64/xtables/   #这里面全是iptables的模块。
```



### multiport模块



连续端口或多端口写法

```
iptables -A INPUT -p tcp --dport 1:1000 -j ACCEPT
iptables -A INPUT -p tcp -m multiport  --dport 25,110 -j ACCEPT
iptables -A INPUT -p tcp -m multiport  --dport 22,28,44:66,80:90 -j ACCEPT
```

例子：
按照MAC硬件地址进行访问控制

```

iptables -F
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT

iptables -A INPUT -m mac --mac-source 00:0c:29:4e:51:b0 -p all -j ACCEPT
```




例子:

ftp实现双链拒绝的情况下，客户端通过主动和被动都能访问进来

准备 （在服务器端和客户端都要清空防火墙规则，最好使用新的规则）:
清空iptables规则

```
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
iptables -F -t nat 
iptables -F -t mangle
iptables -F -t raw


 yum install vsftpd -y
systemctl restart vsftpd
```




客户端下载ftp

```
yum install -y ftp
```


客户端测试方法:
1,命令连接测试，能成功连接上就表示命令端口连接没问题
 ftp 192.168.224.10 (服务器的ip,账号密码就是服务器端已有的用户的)
2,数据传输测试，用上面的命令登录成功后，在客户端使用passive指令转换你的主动和被动模式，
(服务器端不用转换，因为服务器端默认就是主动和被动都支持的)
然后使用ls指令能看到目录就表示数据传输OK了（因为默认是登录到服务器的用户HOME目录)

```
 vim /etc/vsftpd/vsftpd.conf	--直接在配置文件最后加上这两句就可以
pasv_min_port=3000
pasv_max_port=3005

systemctl restart vsftpd
iptables -P INPUT DROP
iptables -P OUTPUT DROP
```
设置双链拒绝后，客户端无法访问FTP
 ftp 192.168.224.10


ftp有主动和被动的连接两种
1，为什么有主动和被动两种连接方式呢?
因为这是一种比较古老的设计方式，它是假设客户端用户有防火墙并且还不会配置防火墙的情况下，才设计出两种模式。
防火墙默认只会拒绝进来的包，而不会拒绝出去或出去回来的包。
2,一般用主动好还是被动好?
用被动比较常见，（原因参考问题一）
3，主动和被动在使用时的区别?
没有防火墙，那么使用起来没什么区别，只是底层传输包的方式不一样
有防火墙，那么防火墙的规则写法也不一样




例子一：FTP主动模式  #客户端用随机端口访问server21端口，20端口处理后返回随机端口
主动：
		server			client

	  20  21			 n	m	
			<-------------		
			-------------->
	
	   ---------------------------------------->	
	   <---------------------------------------
在服务器端执行：
```
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -A INPUT -p tcp --dport 21 -j ACCEPT
iptables -A INPUT -p tcp --dport 20 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 21 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 20 -j ACCEPT
```

在客户端执行：
ftp 192.168.224.10
ftp> ls  (可以正常运行)
ftp> passive （切换为被动模式）
ftp> ls (出现问题，无法正常运行)

Note： passive on --此命令用来切换主动模式。然后执行ls就可以了。但是被动模式不行。


例子二：FTP被动模式     #客户端用随机端口访问server21端口，3000-3005端口处理后返回client
随机端口。
被动：
		server			    client
	随机端口	     21			n	m
	3000－3005	 <---------------
			    ---------------->
			
	 <--------------------------------------------	
	--------------------------------------------->

```
iptables -F
iptables -F -t nat 
iptables -F -t mangle
iptables -F -t raw

iptables -A INPUT -p tcp --dport 21 -j ACCEPT
iptables -A INPUT -p tcp --dport 20 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 20 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 21 -j ACCEPT

iptables -A INPUT -p tcp --dport 3000:3005 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 3000:3005 -j ACCEPT

```
合到一起，两条直接搞定
```
iptables -A INPUT -p tcp -m multiport --dport 20,21,3000:3005 -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --sport 20,21,3000:3005 -j ACCEPT

```
### iprange模块

以ip范围进行过滤

如： 来自192.168.224.8到224.15ip的网络流量都允许通过。

```
iptables -t filter -A FORWARD -m  iprange --src-range 192.168.224.8-192.168.224.15 -o ens33 -j ACCEPT
```



### string模块

以关键字来进行网络流量过滤

只要是经过的流量有baidu关机字的都丢掉。

```
iptables -t filter -A FORWARD -s 192.168.224.0/24 -o ens33 -m string --string baidu --algo kmp -j DROP
```

参数

```
string match options:
--algo                       Algorithm  算法
--icase                      Ignore case (default: 0) 忽略大小写
[!] --string string          Match a string in a packet 字符串匹配数据包中的字符串

```

### time模块

以时间段来过滤

周一到周五早上10点到下午6点经过ens33网卡的流量都丢掉。

```
iptables -t filter -A FORWARD -s 192.168.224.0/24 -m time --timestart 00:00 --timestop 10:00 --weekdays 1,2,3,4,5 -o ens33 -j DROP

```

### connlimit模块

**用于限制同一IP可建立的连接数目**

　　--connlimit-upto n

　　--connlimit-above n

同一时刻只能有3台ip建立ssh连接。

```
iptables -I INPUT -d 192.168.224.12 -p tcp --syn --dport 22   -m connlimit --connlimit-above 2 -j REJECT
```





### state模块

包过滤的条件:
如: 
-p 协议  
-sport/dport xxx   
-s/-d xxxx   
-m state --state 状态



如果按照tcp/ip来划分连接状态，有11种之多(课后可以自己去读一下相关知识)
但iptables里只有4种状态；ESTABLISHED、NEW、RELATED及INVALID

这两个分类是两个不相干的定义。例如在TCP/IP标准描述下UDP及ICMP数据包是没有连接状态的，但在state模块的描述下，任何数据包都有连接状态。

    1、ESTABLISHED（已建立）
       
    (1)与TCP数据包的关系：首先在防火墙主机上执行SSH Client，并且对网络上的SSH服务器提出服务请求，而这时送出的第一个数据包就是服务请求的数据包，如果这个数据包能够成功的穿越防火墙，那么接下来SSH Server与SSH Client之间的所有SSH数据包的状态都会是ESTABLISHED。
    
    (2)与UDP数据包的关系：假设我们在防火墙主机上用firefox应用程序来浏览网页（通过域名方式），而浏览网页的动作需要DNS服务器的帮助才能完成，因此firefox会送出一个UDP数据包给DNS Server，以请求名称解析服务，如果这个数据包能够成功的穿越防火墙，那么接下来DNS Server与firefox之间的所有数据包的状态都会是ESTABLISHED。
    (3)与ICMP数据包的关系：假设我们在防火墙主机ping指令来检测网络上的其他主机时，ping指令所送出的第一个ICMP数据包如果能够成功的穿越防火墙，那么接下来刚才ping的那个主机与防火墙主机之间的所有ICMP数据包的状态都会是ESTABLISHED。
    由以上的解释可知，只要第一个数据包能够成功的穿越防火墙，那么之后的所有数据包（包含反向的所有数据包）状态都会是ESTABLISHED。
    
    2、NEW（新建立）
       
    首先我们知道，NEW与协议无关，其所指的是每一条连接中的第一个数据包，假如我们使用SSH client连接SSH server时，这条连接中的第一个数据包的状态就是NEW。
    
    3、RELATED（相关的）
    
    RELATED状态的数据包是指被动产生的数据包。而且这个连接是不属于现在任何连接的。RELATED状态的数据包与协议无关，只要回应回来的数据包是因为本机送出一个数据包导致另一个连接的产生，而这一条新连接上的所有数据包都是属于RELATED状态的数据包。
    
    4、INVALID
    
    INVALID状态是指状态不明的数据包，也就是不属于以上三种状态的封包。凡是属于INVALID状态的数据包都视为恶意的数据包，因此所有INVALID状态的数据包都应丢弃掉，匹配INVALID状态的数据包的方法如下：
    iptables -A INPUT -p all -m state INVALID -j DROP
    我们应将INVALID状态的数据包放在第一条。



					|
			随机		|            80  web
			－－－－－－－－－ －》		
	client			|                server		
	　　　　《－－－－－－－－－－－
			随机		|             80	
					|


client访问server过去
第一个数据包（new状态），如果拒绝，那么后续包都会被拒绝（因为后面来的都会是第一个，都为new状态)
第一个数据包如果允许过去，那么后续包的状态为established

server返回给client
返回的所有包都为established




例1：
有下面两台机

		192.168.224.11		192.168.224.10
		 client			    server		



192.168.224.11是可以ssh访问192.168.224.10，也可以curl访问192.168.224.10

0，在Server上安装HTTPD服务，并启动

1，在192.168.224.10上
iptables -F 
iptables -F -t nat
iptables -P INPUT DROP
iptables -P OUTPUT DROP
这里就把双链都关掉，192.168.224.11任何访问都过不来了

2，
按以前的做法
在192.168.224.10上允许别人ssh进来

```
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -j ACCEP

T在192.168.224.10上允许别人curl进来
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT
```

或者把上面四条合下面两条

```
iptables -A INPUT -p tcp -m multiport  --dport 22,80 -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport  --sport 22,80 -j ACCEPT
```

注意：如果要想server 也能  ssh 客户端需要加上下面两条：

```
iptables -A INPUT  -p tcp -m multiport --sport 22,80 -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --dport 22,80 -j ACCEPT
```

下面两段等同于，上面所有语句的效果。
在Server上设置防火墙规则：
```
iptables -A INPUT -p tcp -m multiport  --dport 22,80 -j ACCEPT
iptables -A OUTPUT -p tcp -m state --state established -j ACCEPT
```
(后面一句可以翻译成tcp协议的连接只要你进得来，你就回得去）
(无论他是用哪个随机端口访问进来的;因为只要能进来，那么后续的包都属于ESTABLISHED状态)

验证：
在client1 访问 curl 192.168.224.10 可以正常访问

=============================================================
例2： 在默认INPUT DROP的防火墙规则下，如何保证由本机发出的请求正常使用

		192.168.224.11		
		 client			  

需求：client1为客户机器，要保证安全，所以INPUT默认为DROP，但是同时要保证由本机发出的请求正常使用。


在client1设置如下防火墙规则：
```
iptables -F
iptables -F -t NAT

iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -A INPUT -p all -m state --state established -j ACCEPT
```

验证：
1.client1，ssh到其他机器可以正常使用。

2.从server ping client1.结果为失败。

例2:
有些服务器，可能希望客户端ping不通此服务器，但是此服务器可以ping通客户端(前提是客户端没有防火墙限制)

方法一:修改系统配置
在服务器上把/proc/sys/net/ipv4/icmp_echo_ignore_all的值改为1
临时修改两种方式:
```
vim /proc/sys/net/ipv4/icmp_echo_ignore_all
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all
or
 sysctl -w net.ipv4.icmp_echo_ignore_all=1
 sysctl -p
```
永久修改
```
 vim /etc/sysctl.conf	--加上下面一句
net.ipv4.icmp_echo_ignore_all = 1
 sysctl -p	--使用此命令让其生效
```


方法二:
通过iptables的状态来实现
有下面两台机

192.168.224.11		192.168.224.10

实现192.168.224.10这个IP能ping通所有人.但所有人不能ping通192.168.224.10

					            |
		        --------------》|  ------->
		           client		|  server		
	     	     192.168.224.11		|  192.168.224.10
		          <-------------|  <--------   


				       NEW    ESTABLISHED
			INPUT	   拒绝	   允许
			OUTPUT	   允许	   允许


1，在192.168.224.10上
iptables -P INPUT DROP
iptables -P OUTPUT DROP
这里就把双链都关掉，192.168.224.11任何访问都过不来了

2,在192.168.224.10上

```
iptables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT           #NEW 小写也可以
```



--重点是INPUT那条不能允许NEW状态的;
--注意第二步的第二条(也就是output这条)，如果只写了NEW状态，那么192.168.224.10ping所有人，都只能通第一个包；加上ESTABLISHED状态，所有包都能通	



====================================================================
练习：
有一个服务器，搭建了http,ftp(主动和被动都要支持,被动端口为3000-3005）两个服务（需要开放给所有人访问)，还要开放ssh和ping（但只开放给一个管理ip访问，比如此IP为192.168.224.11)，其它任何进来的访问都拒绝
但此服务器要出去访问别的任何服务，自己的防火墙都要允许


准备干净的虚拟机
```
yum install vsftpd -y
vim /etc/vsftpd/vsftpd.conf	--直接在配置文件最后加上这两句就可以
pasv_min_port=3000
pasv_max_port=3005


systemctl restart vsftpd
systemctl enable vsftpd
yum -y install httpd
systemctl restart httpd
systemctl enable httpd

```
需求:一个一个的写
```
iptables -P INPUT DROP
iptables -P OUTPUT DROP

iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT

iptables -A INPUT -p tcp --dport 21 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 21 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 20 -j ACCEPT
iptables -A INPUT -p tcp --dport 20 -j ACCEPT

iptables -A INPUT -p tcp --dport 3000:3005 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 3000:3005 -j ACCEPT 

iptables -A INPUT -p tcp --dport 22 -s 192.168.224.11 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -d 192.168.224.11 -j ACCEPT

iptables -A INPUT -p icmp -s 192.168.224.11 -j ACCEPT
iptables -A OUTPUT -p icmp -d 192.168.224.11 -j ACCEPT

iptables -A OUTPUT -p all -m state --state new,established,related -j ACCEPT
iptables -A INPUT -p all -m state --state established,related -j ACCEPT
```

需求综合起来写
```
iptables -P INPUT DROP
iptables -P OUTPUT DROP

iptables -A INPUT -p tcp -m mutliport --dport 80,21,20,3000:3005 -j ACCEPT
iptables -A INPUT -p tcp --dport 22  -s 192.168.224.11 -j ACCEPT
iptables -A INPUT  -p icmp -s 192.168.224.11 -j ACCEPT
iptables -A OUTPUT -p all -m state --state new,established,related -j ACCEPT
iptables -A INPUT -p all -m state --state established,related -j ACCEPT
```

验证：
1.从client1访问 curl 192.168.224.10。结果正常
2.测试ftp主动/被动模式。从client1访问
ftp 192.168.224.10
ftp> ls  
ftp> passive （切换模式）
ftp> ls 


====

结束实验。清空iptables规则。最好重新准备干净的虚拟机继续做下面的实验。
```
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
iptables -F -t nat 
iptables -F -t mangle
iptables -F -t raw
systemctl restart iptables
systemctl stop iptables
systemctl disable iptables
```

=============================================================
端口转发
```
vim /etc/sysctl.conf	--加上下面一句
net.ipv4.ip_forward=1
```
 sysctl -p 使之生效
环境：
Server 
	外网IP 192.168.2.73
	内网IP 192.168.224.10 

Client3
	IP 192.168.224.13 


1. 在Client3安装HTTP

2. 在Server，设置入站规则：将来访问80端口的流量做DNAT，将目标地址改为192.168.224.13
```
iptables -t nat -A PREROUTING -p tcp --dport 80  -j DNAT --to-destination 192.168.224.13 
```

3. 在Server，设置出站规则，将从端口80发出的流量做SNAT，将源地址修改为192.168.224.10
```
iptables -t nat -A POSTROUTING -p tcp --dport 80 -j SNAT --to-source 192.168.224.10
```
验证：
1.在物理机访问`http://192.168.2.73`和`http://192.168.224.10` 可以显示client3上的web网页。

2.在server本机访问192.168.224.10以及192.168.2.73均无法访问。



# **2.firewalld**

rhel7和centos7的新防火墙软件　firewalld　　（但仍然可以使用iptables)	



Linux网络防火墙对比
 iptables
• iptables在rhel7之前是非常流行的，但是它对于firewalld来讲过于低级， 而且它自身只能编写IPV4的规则，IPV6则需要其他的程序实例来帮助完成。
• firewalld
• firewalld是rhel7引入的权限的netfilter子系统交互程序，确切的说它是一 个服务。并且它将网络划分为多个区域来进行管理。



官网地址

```
http://www.firewalld.org/
```



开始试验：准备干净的虚拟机
```
yum install firewalld firewall-config -y

systemctl restart firewalld	
systemctl status firewalld   
systemctl enable firewalld   


```

概念一 ZONE:
Zone  	简单来说就是防火墙方案,就是一套规则集，你可以切换使用哪一个zone

firewall-cmd --get-zones	--查看现在有哪些zone
block dmz drop external home internal public trusted work


drop：拒绝所有外部连接请求。
block：拒绝所有外部连接(with an icmp-host-prohibited message for IPv4 and icmp6-adm-prohibited for IPv6)，允许内部发起的连接
public：适用公共环境，拒绝所有外部连接请求，但指定外部连接可以进入
external：特别适用路由器启用了伪装功能的外部网。拒绝所有外部连接请求，只能接收经过选择的连接。
dmz：用于您的非军事区内的电脑，此区域内可公开访问，可以有限地进入您的内部网络，仅仅接收经过选择的连接。（受限制的公共连接可以进入）
work：适用于工作网络环境，概念和workgoup一样，也是指定的外部连接允许用于工作区。
home：类似家庭组,用于家庭网络。您可以基本信任网络内的其他计算机不会危害您的计算机。仅仅接收经过选择的连接
internal：用于内部网络。您可以基本上信任网络内的其他计算机不会威胁您的计算机。仅仅接受经过选择的连接
trusted：可接受所有的网络连接。（最不安全）


firewall-cmd --get-default-zone 　--查看当前使用的zone
public

firewall-cmd --set-default-zone=work
firewall-cmd --set-default-zone=public	--修改当前使用的zone

firewall-cmd --list-all　--查看当前使用的zone的规则集
firewall-cmd --zone=work --list-all	--指定查看work这个zone的规则集

vim /etc/firewalld/zones/public.xml"。firewall的默认模式"public"的配置文件，如下图所示，可以看到添加的服务都在里面，如果在其中按照格式添加"ftp"，重新加载后就添加了这个服务了。

cd /usr/lib/firewalld/services/
进入这个目录后，如下图所示，输入"ls"，就可以看到可以添加哪些服务，并且可以看到这些服务的名称了。

概念二:网卡接口
```
firewall-cmd --zone=public --add-interface=eth0	--指定网卡加入到哪个zone

firewall-cmd --get-zone-of-interface=eth0		--查看网卡加入到哪个zone
```


常用命令：
firewall‐cmd ‐‐reload //重新载入防火墙策略，未设置为永久策略的规则会丢失。
firewall‐cmd ‐‐permanent //永久策略属性
firewall‐cmd ‐‐add‐ //添加一条策略
			 ‐‐add‐source=source[/mask]
			 ‐‐add‐service=http
firewall‐cmd ‐‐remove‐ //删除一条策略
firewall-cmd --list-all 查询已有防火墙规则 

概念三:服务于端口
```
port,service  分别表示端口和服务
firewall-cmd  --add-port=80/tcp　　--允许tcp的80端口进来的通迅（类似iptables的INPUT)
firewall-cmd  --remove-port=80/tcp --删除上面的规则

firewall-cmd  --add-service=http	--允许http服务进来的通迅（不用管它是什么端口，只记住服务就好了)
firewall-cmd  --remove-service=http

firewall-cmd  --add-service=ftp	--允许ftp服务进来的通迅（无论主动还是被动都可以，这样就把iptables的写法简单化了)
firewall-cmd  --remove-service=ftp
```



概念四:富规则
rich-rule复杂规则（富规则）
富规则中可以包含很多网络元素，比如:IP地址、端口、以及处
理动作、记录日志等操作。我们可以使用富规则来精确控制我们
的访问流量，而不是粗放的。
```

firewall-cmd  --add-rich-rule="rule family='ipv4' source address=192.168.224.11 service name='ssh' accept"
```
下面两条合起来实现允许所有人访问我的http,但drop掉192.168.224.11的访问我的http的包
```
firewall-cmd  --add-service=http	
firewall-cmd  --add-rich-rule="rule family="ipv4" source address=192.168.224.11 service name="http" drop"
firewall-cmd  --list-rich-rule  （查询现有的富规则）
```


概念五:关于立即生效与永久生效

立即生效：上面的练习都是立刻生效，但是无法永久保存，重新防火墙服务，重启机器，以及执行--realod参数都会导致规则被覆盖。

永久生效： 在命令行中加入参数 --permanent 为永久保存，但是运行时不会立即生效，需要执行 firewall --reload命令才会让规则立刻生效。

firewall-cmd  --permanent --add-service=ftp　　--加了一个--permanent参数后，立即不生效，需要reload后才能生效
实际写规则时，建议直接写（不加--permanent参数)，所有规则写完，测试完成后，再使用
firewall-cmd --runtime-to-permanent 全部转成permanent规则



概念六:
panic模式,在遭受攻击的时候进入紧急模式，以保护服务器。
```
firewall-cmd --panic-on
firewall-cmd --panic-off
```

概念七:
图形配置
```
firewall-config
```
=======================================================================================