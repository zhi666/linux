 phpstudy-web面板linux脚本一键安装

要求环境是没有安装docker

使用 SSH 连接工具 连接到您的 Linux服务器后，根据系统执行相应命令开始安装（大约2分钟完成面板安装）：

Centos安装脚本

```

yum install -y wget && wget -O install.sh https://download.xp.cn/install.sh && sh install.sh
```

=================安装完成==================

请用浏览器访问面板`http://192.168.224.11:9080/B90794` 
系统初始账号:admin
系统初始密码:vFzuqTwRC5
官网`https://www.xp.cn`
如果使用的是云服务器，请至安全组开放9080端口
如果使用ftp，请开放21以及30000-30050端口
如果在虚拟机安装，请将ip换成虚拟机内网ip

安装成功后的登录 `http://192.168.224.11:9080/  `这是默认端口

安装成功后需要卸载firewalld,用iptables

```

systemctl stop  firewalld
systemctl disable  firewalld
systemctl restart  iptables
```



### 升级方法

> 进入phpstudy for linux面板后台首页，找到右上角“系统信息”一栏，版本信息中的“检查更新”按钮，点击即可更新



