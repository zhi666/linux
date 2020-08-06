[toc]
# 目录

## 1，开源的分布式日志系统

elk(elasticsearch+logstash+Kibana)
efk(elasticsearch+filebeat+Kibana)

Elasticsearch是个开源分布式搜索引擎，提供搜集、分析、存储数据三大功能 www.elastic.co
Logstash 主要是用来日志的搜集、分析、过滤日志的工具
Kibana可以为 Logstash 和 ElasticSearch 提供的日志分析友好的 Web 界面，可以帮助汇总、分析和搜索重要数据日志


新版本加了beats(轻量级的日志收集处理工具(Agent)，Beats占用资源少

				kibana		(日志web展示)
				  |
				  |
				  |
				  |
	elasticsearch1	 elasticsearch2	   elasticsearch3	(elasticsearch集群，日志分析存储）
				  |
				  |
				  |
				  | 
				　|
			   logstash		(收集或过滤日志)			
				  |
				  |
				  |
	   业务服务器1	业务服务器2	业务服务器3	业务服务器4
	    beats	   beats	  beats		 beats		(filebeats收集日志传给elasticsearch,或者传给logstash过滤)





## 2，实验准备
我这里只用三台虚拟机来模拟
192.168.224.10	kibana+elasticsearch主节点
192.168.224.11	elasticsearch数据节点1+logstash或filebeats
192.168.224.12	elasticsearch数据节点2+logstash或filebeats	

环境配置要求：
内存：2G以上
CPU：单核以上，不然后面elasticsearch可能启动不起来

1. 主机名及主机名绑定

``` vim /etc/hosts
192.168.224.10	server.com
192.168.224.11	server1.com
192.168.224.12	server2.com
```
2. 时间同步
3. 静态ip绑定
4. 关闭防火墙,selinux
5. 配置yum源(本地源加下面的源) 3台都要同步进行。
   下面这段是公网的源路径，但elk相关的rpm包比较大，网速不行的话，建议用下面的我配置好的yum
   [elk]
   name=elk
   baseurl=https://artifacts.elastic.co/packages/7.x/yum
   enabled=1
   gpgcheck=0
   

==========================================================
更新yum仓库
yum makecache

## 3,搭建elasticsearch集群

### **第一步**
三台elasticsearch机器确认有jdk,然后安装elasticsearch
 java -version
openjdk version "1.8.0_102"
OpenJDK Runtime Environment (build 1.8.0_102-b14)
OpenJDK 64-Bit Server VM (build 25.102-b14, mixed mode)

没有就需要安装
yum install -y java

[root@vm1 ~]# yum install elasticsearch -y
[root@vm2 ~]# yum install elasticsearch -y
[root@vm3 ~]# yum install elasticsearch -y

也可以本地上传rpm 包然后安装

​     rpm -ivh elasticsearch-6.3.0.rpm

**第二步**
三台上配置elasticsearch（三台的配置有少许不同），然后启动服务，组建elasticsearch集群

[root@vm1 ~]# vim /etc/elasticsearch/elasticsearch.yml     #清空里面的内容
cluster.name: elk-cluster			--集群名
node.name: server.com				--本节点主机名
node.master: true					--定义此节点为master节点
node.data: false					--定义此节点不为数据节点
path.data: /var/lib/elasticsearch	--数据目录
path.logs: /var/log/elasticsearch	--日志目录
network.host: 0.0.0.0				--监听地址
http.port: 9200						--监听端口
discovery.zen.ping.unicast.hosts: ["192.168.224.10", "192.168.224.11","192.168.224.12"]	--加入集群的所有节点IP

cluster.name: elk-cluster
node.name: server.com
node.master: true
node.data: false
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
http.port: 9200
discovery.zen.ping.unicast.hosts: ["192.168.224.10", "192.168.224.11", "192.168.224.12"]

[root@vm2 ~]# vim /etc/elasticsearch/elasticsearch.yml
cluster.name: elk-cluster
node.name: server1.com
node.master: false				#定义此节点不为master节点
node.data: true					#定义此节点为数据节点
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
http.port: 9200
discovery.zen.ping.unicast.hosts: ["192.168.224.10", "192.168.224.11", "192.168.224.12"]

[root@vm3 ~]# vim /etc/elasticsearch/elasticsearch.yml
cluster.name: elk-cluster
node.name: server2.com
node.master: false			#定义此节点不为master节点
node.data: true				#定义此节点为数据节点
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
http.port: 9200
discovery.zen.ping.unicast.hosts: ["192.168.224.10", "192.168.224.11", "192.168.224.12"]

[root@vm1 ~]# systemctl start elasticsearch
[root@vm1 ~]# systemctl enable elasticsearch
[root@vm2 ~]# systemctl start elasticsearch
[root@vm2 ~]# systemctl enable elasticsearch
[root@vm3 ~]# systemctl start elasticsearch
[root@vm3 ~]# systemctl enable elasticsearch

启动成功后（虚拟模拟比较卡，启动并建立集群会有一点慢），一台一台启动，查看端口
yum  install -y net-tools 下载软件netstat
 netstat -ntlup |grep java 	--所有节点查看都可以看到启动了下面的端口

![aa2ZFJ.png](https://s1.ax1x.com/2020/08/03/aa2ZFJ.png)

9200则是数据传输端口
9300端口是集群通信端口

启动不了：
 ulimit -n  		--检查系统最大打开文件数值是否太小
 1024

 vim /etc/security/limits.conf		--在文件尾部加上下面两行，并重启系统即可
* soft nofile 10240
* hard nofile 10240

或者关机后重启一台一台启，不要三台同时启动。
**第三步**：检查elasticsearch集群是否OK

**开通防火墙**

```
iptables -A INPUT -p tcp -m multiport --dports 9200,9300,5601,9600,10514 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --sports 9200,9300,5601,9600,10514 -j ACCEPT
```

使用firefox查看下面的路径(健康检查)：
http://192.168.224.10:9200/_cluster/health?pretty	--访问的ip为elasticsearch主节点的IP；或者使用curl http://192.168.224.10:9200/_cluster/health?pretty 命令查看
{
  "cluster_name" : "elk-cluster",
  "status" : "green",			--状态green
  "timed_out" : false,
  "number_of_nodes" : 3,		--三个节点
  "number_of_data_nodes" : 2,		--只有两个为数据节点，另一个为master
  "active_primary_shards" : 0,
  "active_shards" : 0,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}



使用firefox查看下面的路径(集群详细信息)


```
http://192.168.224.10:9200/_cluster/state?pretty

	--或者# curl http://192.168.224.10:9200/_cluster/state?pretty命令查看

```

### **第四步**: 在主节点上安装kibana，并启动服务
  在主节点上安装kibana，并启动服务(这里kibana我是和elasticsearch主节点模拟的同一台机器)：

  [root@vm1 ~]# yum install kibana  -y

   rpm -ihv kibana-6.3.0-x86_64.rpm    #这样本地上传

 [root@vm1 ~]# vim /etc/kibana/kibana.yml 
  server.port: 5601  		#kibana监听端口   :2
  server.host: 192.168.224.10  		#配置监听ip,允许elasticsearch的master能被访问 :7
  elasticsearch.url: "http://192.168.224.10:9200"      :28行 --配置elasticsearch服务器的ip，如果是集群则配置该集群中master的ip
  logging.dest: /var/log/kibana.log  	  :96  #kibana的日志文件路径,自己指定日志，方便排错和调试

   touch /var/log/kibana.log
   chown kibana.kibana /var/log/kibana.log
   systemctl restart kibana
   systemctl enable kibana
   lsof -i:5601

  使用firefox浏览器访问
  http://192.168.224.10:5601    --IP为kibana服务器的ip

#### 自定义安装版本kibana

```csharp
wget https://artifacts.elastic.co/downloads/kibana/kibana-7.2.0-linux-x86_64.tar.gz
```

===============================================================

### ELK

### **第五步**:
在node1(server1.com)上安装logstash，配置并启动(这一台是elasticsearch集群节点之一，也模拟logstash节点)

 yum install logstash -y

```
rpm -ivh logstash-6.3.0.rpm  #本地上传rpm 安装
```



 vim /etc/rsyslog.conf  	(添加在文件末尾)

```
  *.* 	@@192.168.224.11:10514			#IP写node1的IP地址（本机的IP）
```
systemctl restart rsyslog
 grep -Ev "^#|^$" /etc/logstash/logstash.yml                         #注意yml格式

vim /etc/logstash/logstash.yml

:28行    path.data: /var/lib/logstash
:190行  http.host: "192.168.224.11"		--配置成node1的ip
:208行  path.logs: /var/log/logstash

![aa2ykQ.png](https://s1.ax1x.com/2020/08/03/aa2ykQ.png)

 vim /etc/logstash/conf.d/syslog.conf 	--编辑一个配置文件，把本地的系统日志收集并发送给elasticsearch集群
input {				#输入，也就是日志源
  syslog {
    type => "system-syslog"
    port => 10514		#端口，和上面在rsyslog里配置的端口对应
  }
}
output {			#输出，这里定义输出到elasticsearch集群
  elasticsearch {
    hosts => ["192.168.224.10:9200"]  	#elasticsearch集群的master节点
    index => "system-syslog-%{+YYYY.MM}"	#定义日志索引
  }
 }

纯文件内容：
input {                         
  syslog {
    type => "system-syslog"
    port => 10514               
  }
}
output {                        
  elasticsearch {
    hosts => ["192.168.224.10:9200"]    
    index => "system-syslog-%{+YYYY.MM}"        
  }
 }

启动logstash服务
 cd /usr/share/logstash/bin
 ./logstash --path.settings /etc/logstash/ -f /etc/logstash/conf.d/syslog.conf &	--等待时间比较久(我这里虚拟机实验环境2－3分钟),在这期间屏幕会陆续有输出。
 netstat -ntlup |grep 9600
 netstat -ntlup |grep 10514

**第六步**:测试
回到kibana服务器(192.168.224.10)查看日志，执行以下命令查看获取的索引信息：

 curl '192.168.224.10:9200/_cat/indices?v'
health status index                 uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   system-syslog-2018.11 tTNC6tV_RoqYSHLtlCAG-A   5   1          3            0     58.8kb         29.4kb

![aaRQ9s.png](https://s1.ax1x.com/2020/08/03/aaRQ9s.png)

如果没有出现日志索引信息就开通防火墙，

```
iptables -A INPUT -p udp -m multiport --sports 10514 -j ACCEPT
```



firefox访问http://192.168.224.10:5601

  1. 点management－－》点Index Patterns－－》

  2. 在Index pattern里填写索引名称（system-syslog-2018.11或者system-syslog-*）－－》点Next step －－》

     ![aaR03R.png](https://s1.ax1x.com/2020/08/03/aaR03R.png)

     ---》在Time Filter field name下拉菜单选择@timestamp－－》点Create Index Patterns

     ![aaRR4H.png](https://s1.ax1x.com/2020/08/03/aaRR4H.png)
     
**3.点discover查看**
     
     ![aaWzJH.png](https://s1.ax1x.com/2020/08/03/aaWzJH.png)
     
     

 

![aafuSs.png](https://s1.ax1x.com/2020/08/03/aafuSs.png)

**不行可以重启kibana服务器**



## EFK

**第一步:**
在node1和node2上安装filebeat,两台都要操作
 yum install filebeat -y

```
rpm -ivh filebeat-6.3.0-x86_64.rpm
```



**第二步:** 修改filebeat配置文件，两台都要操作
 vim /etc/filebeat/filebeat.yml
  filebeat.inputs:

  - type: log

    enabled: false	--注释这一句
    paths:
    
      - /var/log/yum.log	 --这里改成你要测试的日志(也可以写成/var/log/*.log这种，我这里使用yum.log测试比较简单方便）


  output.elasticsearch:                       #:144

    hosts: ["192.168.224.10:9200"]	#指定输出给elasticsearch集群的master:9200

![aafHhQ.png](https://s1.ax1x.com/2020/08/03/aafHhQ.png)

也可以自定义日志

![aahCh4.png](https://s1.ax1x.com/2020/08/03/aahCh4.png)

**第三步:**启动服务，两台都要操作
 systemctl start  filebeat
 systemctl enable filebeat
 systemctl status filebeat

**第四步:** 回到kibana服 务器上操作
 curl '192.168.224.10:9200/_cat/indices?v'	--使用此命令确认有filebeat-*的索引
![aahAj1.png](https://s1.ax1x.com/2020/08/03/aahAj1.png)

**第五步:**使用firefox操作kibana图形界面
http://192.168.224.10:5061

点management－－》点Index Patterns－－》在Index pattern里填写索引名称（filebeat-6.3.0-2018.07.05或者filebeat-*）
－－》点Next step －－》

![aahQ9H.png](https://s1.ax1x.com/2020/08/03/aahQ9H.png)

在Time Filter field name下拉菜单选择@timestamp－－》点Create Index Patterns



点discover查看.如果没有日志输出尝试在yum.log中加入新日志。
添加 message   主看信息



```
 grep -Ev "#|^$" /etc/filebeat/filebeat.yml 
 
filebeat.inputs:

- type: log
  paths:
    - /var/log/yum.log
      paths:
  - /var/log/nginx.log
    filebeat.config.modules:
    path: ${path.config}/modules.d/*.yml
    reload.enabled: false
    setup.template.settings:
    index.number_of_shards: 3
    setup.kibana:
    output.elasticsearch:
    hosts: ["192.168.224.10:9200"]
    index: "yum-%{+yyyy.MM.dd}"
    setup.template.name: "yum-nginx"
    setup.template.pattern: "yum-nginx-*"
```



删除索引
 curl -XDELETE '192.168.224.10:9200/.kibana'

GET索引
curl -XGET '192.168.224.10:9200/yum-2018.07.06'

==================================================

更多功能，请自行查阅资料
