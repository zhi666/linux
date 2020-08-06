## LINUX系统搭建shadowsocks_VPN服务



一、连接上服务器之后，先安装Python包管理工具,

```
yum install -y python-setuptools && easy_install pip（已安装的忽略）
```

二、安装Shadowsocks

```
pip install shadowsocks
```



三、启动服务
(1)命令配置运行

```
 ssserver -p 443 -k password -m aes-256-cfb  // ssserver -p 服务器端口 -k 密码 -m 加密方法
 ssserver -p 443 -k password -m aes-256-cfb -d start // -d start 代表后台运行
```



(2)配置文件运行
①创建/etc/shadowsocks/目录

```
mkdir /etc/shadowsocks
```

②在/etc/shadowsocks/目录下创建配置文件

```
vim /etc/shadowsocks/conf.json
```

如果是用当前服务器做vpn，your_server_ip填写0.0.0.0
单用户配置：

```
// 单用户配置
{ 
  "server":"your_server_ip",     // 你的服务器ip
  "server_port":8388,            // 端口号（每一个账号都不能重复）
  "local_address": "127.0.0.1",  // 本地地址，一般不变
  "local_port":1080,             // 本地端口，一般不变
  "password":"*********",        // 连接密码
  "timeout":300,                 // 相应超时时间
  "method":"aes-256-cfb",        // 加密方式
  "fast_open": false             //  使用TCP_FASTOPEN, 参数选项true   false，一般保持默认即可
}
```



多用户配置：

```
// 多用户配置

{
    "server":"0.0.0.0",
    "local_address": "127.0.0.1",
    "local_port":1080,
    "port_password":{
         "30":"123.shui", // 左边是端口号，右边是密码
         "31":"123.shui",
         "32":"123.shui",
         "33":"123.shui",
         "34":"123.shui",
         "35":"123.shui",
         "36":"123.shui",
         "37":"123.shui",
         "38":"123.shui",
         "39":"123.shui",
         "8388":"123.shui"
     },
     "timeout":300,
     "method":"aes-256-cfb",
     "fast_open": false
}


```



```

配置说明：

字段  说明
server          ss服务监听地址
server_port     ss服务监听端口
local_address   本地的监听地址
local_port      本地的监听端口
password        密码
timeout         超时时间，单位秒
method          加密方法，默认是aes-256-cfb
fast_open       使用TCP_FASTOPEN, true / false
workers         workers数，只支持Unix/Linux系统
```

③根据配置文件启动

```
ssserver -c /etc/shadowsocks/conf.json start // 前台运行
ssserver -c /etc/shadowsocks/conf.json -d start // 后台运行
ssserver -c /etc/shadowsocks/conf.json -d stop // 停止服务
```

ps：如果出现错误的话，就先杀死进程，重新启动就可以了。

```
sudo kill -9 76031
```

开通防火墙

```
iptables -A INPUT -p tcp -m multiport --dports 30:39,8388 -j ACCEPT
iptables -A INPUT -p udp -m multiport --dports 30:39,8388 -j ACCEPT

```



客户端安装

windows下载

```
http://39.105.118.158:8083/ssr/windows/ShadowsocksR-win-4.9.2-tlanyan.zip
```

![aBZMad.png](https://s1.ax1x.com/2020/08/04/aBZMad.png)

ios下载地址

```
http://vipzsw.cn/
```

安卓版下载

```
http://39.105.118.158:8083/ssr/android/shadowsocksr-android-3.5.4.apk

https://tlanyan.me/download.php?filename=/ssr/android/shadowsocksr-android-3.5.4.apk

```



手机端连接的时候协议选择origin  混淆参数改为plain