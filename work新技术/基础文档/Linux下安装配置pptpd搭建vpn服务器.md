#### **Linux下安装配置pptpd搭建vpn服务器，组建局域网实现内网互连互通**

**1、安装pptpd**

yum  install pptpd  -y 



**2、配置vpn服务器的内网ip和客户机的内网ip段**

vi /etc/pptpd.conf

修改localip和remoteip，注意选一些冷门一点的ip段

```text
localip 192.168.224.1    //***服务器的外网IP 也可以
remoteip 192.168.224.10-250
```

**3、配置vpn账号密码**

vim /etc/ppp/chap-secrets

按此格式添加：用户名 pptpd "密码" *

```

# client    server    secret    IP addresses
xiaobai    l2tpd    123.shui       *
gnvpn   pptpd           123.sh          *

```







**4、开启内核IP转发**

vi /etc/sysctl.conf

取消掉net.ipv4.ip_forward=1 这一行的注释

然后执行sysctl -p 让上面的修改立即生效



**5、检查iptables的FORWARD功能有没有开启**

iptables -L -n，如果FORWARD的功能是ACCEPT则正常，否则请执行

iptables -P FORWARD ACCEPT



**6、重启pptpd服务**

service pptpd restart



做完以上步骤就可以实现了互连互通了，这里要注意：

1、在客户机上添加拨号连接时，协议需要选择pptp

 2、ipv4的网络要取消【在远程网络上使用默认网关】，否则本地网络会断线 

如果我们想使用vpn服务器的IP和流量来进行上网，那么我们需要继续做以下几个步骤

**1、设置pptpd的dns**

vim /etc/ppp/options.pptpd

找到ms-dns，取消注释，并改成你喜欢的DNS，比如：8.8.8.8和8.8.4.4

```
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
ms-dns 8.8.8.8
ms-dns 8.8.4.4
proxyarp
lock
nobsdcomp 
novj
novjccomp
nologfd

```



**2、安装iptables并设置NAT转发**

安装iptables

yum  install iptables



查询上网的网卡编号

ifconfig

我这里查出来是eth0



添加转发规则

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

开放防火墙

 开53端口是为了给客户机提供dns服务，网上的说法大多是dns同时使用udp & tcp，所以我两个协议都开了。但经我测试，绝大多数情况下都只用了udp；
开68端口是为了给客户机分配vpn内网ip地址，据我测试，基本上也只走udp，但我两个协议也都开了；
至于1723，这是pptp的端口，只开了tcp 

```
iptables -t nat -A POSTROUTING -m policy --dir out --pol none -j MASQUERADE

iptables  -A INPUT -p udp -m multiport --dports 17,25,53,68,1701,500,4500  -j ACCEPT
iptables  -A INPUT -p udp -m multiport --sports 17,25,53,68,1701,500,4500  -j ACCEPT
iptables  -A INPUT -p tcp -m multiport --dports 1701,1723,500,4500  -j ACCEPT
iptables  -A INPUT -p tcp -m multiport --sports 1701,1723,500,4500  -j ACCEPT
```



**3、重启pptpd并测试连接**

service pptpd restart

 尝试连接vpn，成功后打开查ip的网站，会发现自己的ip变成了服务器的ip。此时所有的上网流量都会使用vpn服务器的流量。 