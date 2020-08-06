

[toc]

## 1.配置telegram机器人

环境安装好的 zabbix-server 和 zabbix-agent



先去注册一个机器人获取api接口
![aa45FS.png](https://s1.ax1x.com/2020/08/03/aa45FS.png)


创建个群组 把机器人拉进去



第一次获取ok信息，
![aa4HQs.png](https://s1.ax1x.com/2020/08/03/aa4HQs.png)





![aa5SW4.png](https://s1.ax1x.com/2020/08/03/aa5SW4.png)



群组中发条消息 重新打开 获取相关信息

![aaI9N8.png](https://s1.ax1x.com/2020/08/03/aaI9N8.png)

刷新获取信息

![aaInEV.png](https://s1.ax1x.com/2020/08/03/aaInEV.png)



## 2.进入容器配置python脚本

```
[root@localhost ~]# docker exec -it -u root  zabbix-server-mysql bash

#查看脚本路径位置
bash-5.0# cat /etc/zabbix/zabbix_server.conf |grep AlertScriptsPath=
 AlertScriptsPath=${datadir}/zabbix/alertscripts
AlertScriptsPath=/usr/lib/zabbix/alertscripts
```

![aaIa4O.png](https://s1.ax1x.com/2020/08/03/aaIa4O.png)

下载依赖工具

```
bash-5.0# apk add git
bash-5.0# apk update
bash-5.0# apk add python
bash-5.0# apk add py2-pip
```

这段忽略

```
<< -- 没有相关文件可以先复制
docker cp /root/Zabbix-in-Telegram zabbix-server-mysql:/usr/lib/zabbix/alertscripts/
以root权限进入
docker exec -it -u root zabbix-server-mysql bash
ln -s /usr/lib/zabbix/alertscripts/Zabbix-in-Telegram/zbxtg.py /usr/lib/zabbix/alertscripts/Zabbix-in-Telegram/zbxtg_group.py
创建软连接


bash-5.0# pwd
/usr/lib/zabbix/alertscripts/Zabbix-in-Telegram

 -->>
```

下载telegram脚本

```

bash-5.0# cd /usr/lib/zabbix/alertscripts/
bash-5.0# git clone https://github.com/ableev/Zabbix-in-Telegram.git
bash-5.0# cd Zabbix-in-Telegram/

bash-5.0# pip install -r requirements.txt  
bash-5.0# cp zbxtg.py zbxtg_settings.example.py zbxtg_group.py ../
bash-5.0# pwd
/usr/lib/zabbix/alertscripts

bash-5.0# mv zbxtg_settings.example.py zbxtg_settings.py

bash-5.0# vi zbxtg_settings.py 
```

主要以下几部分

```
tg_key = "709759784:AAF2Tff_lKOBLIXHPzfoM1WHQkXt-SqkAqo"  # telegram bot api key

zbx_server = "http://www.linuxea.com/zabbix/"  # zabbix server full url
zbx_api_user = "Admin"
zbx_api_pass = "zabbix"
```



如果显示不了图形
把这个修改为zabbix-web-nginx-mysql的地址，现在的端口改为8080了，需要添加端口
![aaX5xf.png](https://s1.ax1x.com/2020/08/03/aaX5xf.png)

```
zbx_server = "http://192.168.224.11:8080"
```



## 3.配置zabbix web 报警媒介类型。

```
zbxtg_group.py

{ALERT.SENDTO}
{ALERT.SUBJECT}
{ALERT.MESSAGE}
--group
```

![aajnsO.png](https://s1.ax1x.com/2020/08/03/aajnsO.png)



配置用户，报警媒介。

![aajof1.png](https://s1.ax1x.com/2020/08/03/aajof1.png)

测试消息能否正常发出
![aajqOO.png](https://s1.ax1x.com/2020/08/03/aajqOO.png)

**注意，收件人填写bot机器人在的群名字，否者消息会发送不成功。**

![aav9pt.png](https://s1.ax1x.com/2020/08/03/aav9pt.png)



配置动作，选择触发器 新版zabbix已经可以不用这样配置了。
![aavZkj.png](https://s1.ax1x.com/2020/08/03/aavZkj.png)







![aavMcV.png](https://s1.ax1x.com/2020/08/03/aavMcV.png)



配置操作。

![aava1x.png](https://s1.ax1x.com/2020/08/03/aava1x.png)





```
{{fire}}{{fire}}{{fire}} 报警节点：{TRIGGER.NAME}
报警信息：{TRIGGER.NAME}
问题详情：{ITEM.NAME}:{ITEM.VALUE}
报警主机：{HOST.NAME}
报警时间：{EVENT.DATE} {EVENT.TIME}
报警等级：{TRIGGER.SEVERITY}
报警项目：{TRIGGER.KEY1}
当前状态：{TRIGGER.STATUS}:{ITEM.VALUE}
事件ID： {EVENT.ID}
zbxtg;graphs
zbxtg;graphs_period=10800
zbxtg;itemid:{ITEM.ID1}
zbxtg;title:{TRIGGER.NAME}
```

![aavrHe.png](https://s1.ax1x.com/2020/08/03/aavrHe.png)





```
恢复操作
{{OK}}{{OK}}{{OK}}: 恢复节点 : {TRIGGER.NAME}

报警信息：{TRIGGER.NAME}
问题详情：{ITEM.NAME}:{ITEM.VALUE}
报警主机：{HOST.NAME}
报警时间：{EVENT.DATE} {EVENT.TIME}
报警等级：{TRIGGER.SEVERITY}
报警项目：{TRIGGER.KEY1}
当前状态：{TRIGGER.STATUS}:{ITEM.VALUE}
事件ID： {EVENT.ID}
zbxtg;graphs
zbxtg;graphs_period=10800
zbxtg;itemid:{ITEM.ID1}
zbxtg;title:{TRIGGER.NAME}
```

![aavWgP.png](https://s1.ax1x.com/2020/08/03/aavWgP.png)



新版本直接在报警媒介类型里添加就可以了。

![aavIHg.png](https://s1.ax1x.com/2020/08/03/aavIHg.png)

```
[root@localhost yum.repos.d]# systemctl start sshd
[root@localhost yum.repos.d]# systemctl start httpd




#客户端安装zabbix源
rpm -Uvh https://repo.zabbix.com/zabbix/4.4/rhel/7/x86_64/zabbix-release-4.4-1.el7
```