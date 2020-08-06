[toc]



# linux搭建ipsec/xl2tpd

##### 1.先看看你的主机是否支持pptp，返回结果为yes就表示通过

```
modprobe ppp-compress-18 && echo yes
yes
```

##### 2.是否开启了TUN

```
cat /dev/net/tun
#返回结果为cat: /dev/net/tun: File descriptor in bad state。就表示通过

```

##### 3.安装EPEL源

```
yum install -y epel-release

```

##### 4.安装xl2tpd和libreswan

```
yum install -y xl2tpd libreswan lsof

```

##### 5.编辑xl2tpd配置文件 

```
vim /etc/xl2tpd/xl2tpd.conf

[global]
port = 1701

[lns default]
ip range = 192.168.18.2-192.168.18.254
local ip = 192.168.18.1
require chap = yes
refuse pap = yes
require authentication = yes
name = l2tpd
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes

```

##### 6.编辑pppoptfile文件

```
vim /etc/ppp/options.xl2tpd

ipcp-accept-local
ipcp-accept-remote
require-mschap-v2
ms-dns 8.8.8.8
ms-dns 8.8.4.4
noccp
auth
hide-password
idle 1800
mtu 1410
mru 1410
nodefaultroute
debug
proxyarp
connect-delay 5000
```

##### 7.编辑ipsec配置文件 ipse.conf文件和/etc/ipsec.d/l2tp-ipsec.conf文件合在一起了

```
vim /etc/ipsec.conf  主要修改leftid="自己的IP"

version 2.0

config setup
    protostack=netkey
    nhelpers=0
    uniqueids=no
    interfaces=%defaultroute
    virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12,%v4:!192.168.18.0/24

conn l2tp-psk
    rightsubnet=vhost:%priv
    also=l2tp-psk-nonat

conn l2tp-psk-nonat
    authby=secret
    pfs=no
    auto=add
    keyingtries=3
    rekey=no
    ikelifetime=8h
    keylife=1h
    type=transport
    left=%defaultroute
    leftid=192.107.147.140
    leftprotoport=17/1701
    right=%any
    rightprotoport=17/%any
    dpddelay=40
    dpdtimeout=130
    dpdaction=clear
    sha2-truncbug=yes

```



##### 8.编辑include的conf文件

```
vim /etc/ipsec.d/l2tp-ipsec.conf
# 新建如下配置文文件，直接复制的话，前面是很多空格，在启动的时候会报错，需要将空格删除，换成tab的距离，距离相同。不能用空格！
```



##### 9.设置用户名密码

```
vim /etc/ppp/chap-secrets
# Secrets for authentication using CHAP
# client    server    secret    IP addresses
xiaobai    l2tpd      123.yichen        *
gnvpn      pptpd      123.yi          *
wnvpn      *          123.yi          *

```

vpnuser * pass *
说明：用户名[空格]  service[空格]   密码[空格]      指定IP

##### 10.设置预共享密钥PSK   **新建如下文件**

```
vim /etc/ipsec.d/default.secrets

本机IP %any: PSK "123.yi"
```

192.168.11.95 %any: PSK “xxxxxxx”

##### 11.CentOS7防火墙设置(重要)

```

iptables  -t nat  -A POSTROUTING -s 192.168.18.0/24 -j MASQUERADE
iptables -t nat -A POSTROUTING -m policy --dir out --pol none -j MASQUERADE

iptables  -A INPUT -p udp -m multiport --dports 17,25,53,68,1701,500,4500  -j ACCEPT
iptables  -A INPUT -p udp -m multiport --sports 17,25,53,68,1701,500,4500  -j ACCEPT
iptables  -A INPUT -p tcp -m multiport --dports 1701,1723,500,4500  -j ACCEPT
iptables  -A INPUT -p tcp -m multiport --sports 1701,1723,500,4500  -j ACCEPT
```



##### 12.IP_FORWARD 设置

```
vim /etc/sysctl.d/66-sysctl.conf
```

```
vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time=120
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.all.arp_announce=2
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
net.ipv4.conf.lo.arp_announce=2
net.ipv4.ip_forward = 1
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.default.accept_source_route = 0

```

##### 13.ipsec启动&检查

```
systemctl enable ipsec
systemctl restart ipsec
```

##### 14.检查

```
ipsec verify

# 可能会出现类似如下情况：
Checking rp_filter                                  [ENABLED]
 /proc/sys/net/ipv4/conf/ens160/rp_filter           [ENABLED]
 /proc/sys/net/ipv4/conf/ens192/rp_filter           [ENABLED]
# 这是内核参数没有生效，直接依次手动打开这些文件，将 1 改为 0
# 然后重新执行检查，输出如下内容则OK：
```

![aBmIKK.png](https://s1.ax1x.com/2020/08/04/aBmIKK.png)

##### 15.xl2tpd启动

```
systemctl enable xl2tpd
systemctl restart xl2tpd
```

到此，服务端的搭建已经完成，然后就是使用客户端进行连接

#### 二、问题总结

##### 1.以上步骤搭建好，账号密码生成之后连接上，但是无法上外网，也无法上内网，只能ping通vpn所在内网服务器

##### 注意第11步防火墙转发，一定要执行。自作聪明把防火墙关闭了。具体可查看/var/log/messages

#### 三、win7 X64位操作系统拨 L2TP VPN遇到的一点问题（788、789错误）

在网上鼓捣了很久发现win7 x64位的操作系统拨L2tp总是出问题，不是788错误就是789 错误。总结一下网上的一些方法

windows+r 运行 输入 services.msc，查找ipsec policy agent

1.services.msc组策略里面的 IPsec Policy Agent 开机启动

注册表编辑器

2.注册表里面的 HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Rasman\Parameters.新建如下两个项（注意，如果已经有了，就直接修改值）

1）名称：ProhibitIpSec 值：1，

2）名称：AllowL2TPWeakCrypto 值：1。

我遇到的是788错误，修改完这些之后又显示是789错误，一直都没有好。这个方法2有个小选项大家得注意，网上很多人都没有指出这个小小的细节，

那就是新建ProhibitIpSec值的时候右键有两个选项，一个是DWORD（32位），一个是QWORD（64位），我的x64位的操作系统，必须得新建DWORD（32位）的这个，要不然随便怎么折腾，都不会成功的，这研究了大概好几天，翻阅了大量资料，看到的这个选项，希望可以帮助大家。