

### docker volume 持久化插件

```bash
vim /etc/systemd/system/docker-volume-local-persist.service
#文件内容为
[Unit]
Description=docker-volume-local-persist
Before=docker.service
Wants=docker.service

[Service]
TimeoutStartSec=0
ExecStart=/usr/bin/docker-volume-local-persist

[Install]
WantedBy=multi-user.target
```

```bash
wget https://github.com/MatchbookLab/local-persist/releases/download/v1.3.0/local-persist-linux-amd64
 
chmod +x local-persist-linux-amd64  && mv local-persist-linux-amd64 docker-volume-local-persist && mv docker-volume-local-persist /usr/bin/

systemctl daemon-reload && systemctl enable docker-volume-local-persist && systemctl start docker-volume-local-persist
```

**安装docker**

```
yum install -y yum-utils device-mapper-persistent-data lvm2

yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install  -y  docker-ce docker-ce-cli containerd.io
systemctl restart docker && systemctl enable docker
一、安装bash-complete
yum install -y bash-completion

二、刷新文件
source /usr/share/bash-completion/completions/docker && source /usr/share/bash-completion/bash_completion
```



/etc/sysctl.conf 添加
net.ipv4.ip_forward = 1
vm.max_map_count=262144

```
sysctl -p --system

yum -y remove firewall* && yum -y install lrzsz iptables* epel-release  python-pip && pip install docker-compose && systemctl enable iptables
```

```
mkdir -p /elk/logstash
vim  logstash-kafka.conf

```

 logstash-kafka.conf 文件内容为 

```
input {
#    # 来源beats
#    beats {
        # 端口
#        port => "5044"
#    }
  kafka {
    bootstrap_servers => "kafka1:9092"
    topics => ["all_logs"]
    group_id => "logstash"
    codec => json
  }

}
# 分析、过滤插件，可以多个
filter {
#    grok {
#        match => { "message" => "%{COMBINEDAPACHELOG}"}
#    }
#    geoip {
#        source => "clientip"
#    }
}
output {
    # 选择elasticsearch
    elasticsearch {
        hosts => ["http://elasticsearch:9200"]
        #index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
        index => "all-logs-%{+YYYY.MM.dd}"
        user => "elastic"
        password => "secret"

    }
}
```

```
mv logstash-kafka.conf /elk/logstash
```



 docker-compose.yml文件内容为 

```
version: '3'
services:
  elasticsearch:
    restart: always
    container_name: elasticsearch
    image: docker.elastic.co/elasticsearch/elasticsearch:7.4.2
    environment:
      - discovery.type=single-node
    ports:
      - "9200:9200"
      - "9300:9300"
    volumes:
      - elasticsearch:/usr/share/elasticsearch/data:rw
      - /etc/localtime:/etc/localtime
    networks:
      - elastic

  kibana:
    image: docker.elastic.co/kibana/kibana:7.4.2
    restart: always
    container_name: kibana
    volumes:
      - kibana:/usr/share/kibana/config:rw
      - /etc/localtime:/etc/localtime
    depends_on:
      - elasticsearch
    ports:
      - "5601:5601"
    environment:
      SERVER_NAME: kibana.example.org
      ELASTICSEARCH_HOSTS: http://elasticsearch:9200
    networks:
      - elastic


  logstash:
    image: docker.elastic.co/logstash/logstash:7.4.2
    container_name: logstach
    command: logstash -f /usr/share/logstash/conf/logstash-kafka.conf
    restart: always
    tty: true 
    ports:
      - "5044:5044"
    volumes:
      - /etc/localtime:/etc/localtime
      - logstash:/usr/share/logstash/conf/logstash-kafka.conf
    environment:
      - elasticsearch.hosts=http://elasticsearch:9200
      - xpack.monitoring.elasticsearch.hosts=http://elasticsearch:9200
    networks:
      - elastic
    links:
      - kafka1
      - zookeeper
    depends_on:
      - elasticsearch

  zookeeper:
    restart: always
    image: zookeeper:3.5.5
    restart: always
    container_name: zookeeper
    volumes:
      - /etc/localtime:/etc/localtime
      - zookeeper:/data
      - zookeeper1:/datalog
    networks:
      - elastic
    ports:
      - "2181:2181"
  kafka1:
    container_name: kafka1
    image: wurstmeister/kafka
    depends_on:
      - zookeeper
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - kafka:/kafka
      - /etc/localtime:/etc/localtime
    links:
      - zookeeper
    ports:
      - "9092:9092"
    networks:
      - elastic
    environment:
      - KAFKA_LISTENERS=PLAINTEXT://kafka1:9092
      - KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka1:9092
      - KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181
      - KAFKA_MESSAGE_MAX_BYTES=2000000
      - KAFKA_CREATE_TOPICS=all_logs:1:1

volumes:
  elasticsearch:
    driver: local-persist
    driver_opts:
      mountpoint: /elk/elasticsearch/
  kibana:
    driver: local-persist
    driver_opts:
      mountpoint: /elk/kibana/
  logstash:
    driver: local-persist
    driver_opts:
      mountpoint: /elk/logstash/
  zookeeper:
    driver: local-persist
    driver_opts:
      mountpoint: /elk/zookeeper/data/
  zookeeper1:
    driver: local-persist
    driver_opts:
      mountpoint: /elk/zookeeper/datalog/
  kafka:
    driver: local-persist
    driver_opts:
      mountpoint: /elk/kafka/

networks:
  elastic:
    driver: bridge

```

```
mkdir -p /root/elk
mv docker-compose.yml /root/elk &&  cd /root/elk && docker-compose up -d
```

  

开通防火墙对应的端口

```
iptables -A INPUT -p tcp -m multiport --dports 9200:9400,5601,9092,9600,2181,10514 -j  ACCEPT
 iptables -A INPUT -p tcp -m multiport --sports 9200:9400,5601,9092,2181,9600,10514 -j  ACCEPT
 iptables-save > /etc/sysconfig/iptables
```





centos 客户端安装filebeat可以

```
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.4.2-linux-x86_64.tar.gz
tar xzvf filebeat-7.4.2-linux-x86_64.tar.gz
```

改下filebeat.yml配置文件直接启动就行

 修改filebeat.yml文件内容 

```yaml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/nginx/*.log


filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false

setup.template.settings:
  index.number_of_shards: 1

setup.dashboards.enabled: false

setup.kibana:
  host: "http://kibana1:5601"
output.kafka:
    hosts: ["kafka1:9092"]
    topic: 'all_logs'
    codec.json:
      pretty: false
```

 **注意 客户端hosts 添加 kafka1 对应server的ip地址 以及filebeat 配置建议使用ansible** 

```bash
#客户端启动服务
./filebeat &
```



**第二步:** 修改filebeat配置文件，所有客户机都要操作
 vim /etc/filebeat/filebeat.yml
  filebeat.inputs:

  - type: log

    enabled: false	--注释这一句
    paths:

      - /var/log/yum.log	 --这里改成你要测试的日志(也可以写成/var/log/*.log这种，我这里使用yum.log测试比较简单方便）


  output.elasticsearch:                       #:144

    hosts: ["192.168.224.10:9200"]	#指定输出给elasticsearch集群的master:9200

![aacL59.png](https://s1.ax1x.com/2020/08/03/aacL59.png)

也可以自定义日志

[![aag8Gn.png](https://s1.ax1x.com/2020/08/03/aag8Gn.png)](https://imgchr.com/i/aag8Gn)

**第三步:**启动服务，两台都要操作
./filebeat &    启动

开通防火墙对应的端口

```
iptables -A INPUT -p tcp -m multiport --dports 9200:9400,5601,9600,2181,10514 -j  ACCEPT
 iptables -A INPUT -p tcp -m multiport --sports 9200:9400,5601,9600,2181,10514 -j  ACCEPT
 iptables-save > /etc/sysconfig/iptables
```

回到kibana服务器(192.168.224.10)查看日志，执行以下命令查看获取的索引信息：

 curl '192.168.224.11:9200/_cat/indices?v'

![aagrGR.png](https://s1.ax1x.com/2020/08/03/aagrGR.png)



firefox访问`http://192.168.224.11:5601` 

![aag2qO.png](https://s1.ax1x.com/2020/08/03/aag2qO.png)



![aagIJA.png](https://s1.ax1x.com/2020/08/03/aagIJA.png)

这里可以查看信息