[toc]



## fastdFS介绍

**FastDFS开源地址**

```
https://github.com/happyfish100
https://github.com/happyfish100/fastdfs/wiki
```

**同类的go-fastdfs开源地址**

```
https://sjqzhang.github.io/go-fastdfs/#what
```



**封装的FastDFS Java API：**

```
https://github.com/bojiangzhou/lyyzoo-fastdfs-java
```

**1、简介**

FastDFS 是一个开源的高性能分布式文件系统（DFS）。 它的主要功能包括：文件存储，文件同步和文件访问，以及高容量和负载平衡。主要解决了海量数据存储问题，特别适合以中小文件（建议范围：4KB < file_size <500MB）为载体的在线服务。

FastDFS 系统有三个角色：跟踪服务器(Tracker Server)、存储服务器(Storage Server)和客户端(Client)。

　　Tracker Server：跟踪服务器，主要做调度工作，起到均衡的作用；负责管理所有的 storage server和 group，每个 storage 在启动后会连接 Tracker，告知自己所属 group 等信息，并保持周期性心跳。

　　Storage Server：存储服务器，主要提供容量和备份服务；以 group 为单位，每个 group 内可以有多台 storage server，数据互为备份。

　　Client：客户端，上传下载数据的服务器，也就是我们自己的项目所部署在的服务器。

![awrZWt.png](https://s1.ax1x.com/2020/08/04/awrZWt.png)



**2、FastDFS的存储策略**

为了支持大容量，存储节点（服务器）采用了分卷（或分组）的组织方式。存储系统由一个或多个卷组成，卷与卷之间的文件是相互独立的，所有卷的文件容量累加就是整个存储系统中的文件容量。一个卷可以由一台或多台存储服务器组成，一个卷下的存储服务器中的文件都是相同的，卷中的多台存储服务器起到了冗余备份和负载均衡的作用。

在卷中增加服务器时，同步已有的文件由系统自动完成，同步完成后，系统自动将新增服务器切换到线上提供服务。当存储空间不足或即将耗尽时，可以动态添加卷。只需要增加一台或多台服务器，并将它们配置为一个新的卷，这样就扩大了存储系统的容量。

**3、FastDFS的上传过程**

FastDFS向使用者提供基本文件访问接口，比如upload、download、append、delete等，以客户端库的方式提供给用户使用。

Storage Server会定期的向Tracker Server发送自己的存储信息。当Tracker Server Cluster中的Tracker Server不止一个时，各个Tracker之间的关系是对等的，所以客户端上传时可以选择任意一个Tracker。

当Tracker收到客户端上传文件的请求时，会为该文件分配一个可以存储文件的group，当选定了group后就要决定给客户端分配group中的哪一个storage server。当分配好storage server后，客户端向storage发送写文件请求，storage将会为文件分配一个数据存储目录。然后为文件分配一个fileid，最后根据以上的信息生成文件名存储文件。

![awrmSP.png](https://s1.ax1x.com/2020/08/04/awrmSP.png)





**4、FastDFS的文件同步**

写文件时，客户端将文件写至group内一个storage server即认为写文件成功，storage server写完文件后，会由后台线程将文件同步至同group内其他的storage server。

每个storage写文件后，同时会写一份binlog，binlog里不包含文件数据，只包含文件名等元信息，这份binlog用于后台同步，storage会记录向group内其他storage同步的进度，以便重启后能接上次的进度继续同步；进度以时间戳的方式进行记录，所以最好能保证集群内所有server的时钟保持同步。

storage的同步进度会作为元数据的一部分汇报到tracker上，tracke在选择读storage的时候会以同步进度作为参考。

**5、FastDFS的文件下载**

客户端uploadfile成功后，会拿到一个storage生成的文件名，接下来客户端根据这个文件名即可访问到该文件。

![awrKOS.png](https://s1.ax1x.com/2020/08/04/awrKOS.png)

跟upload file一样，在downloadfile时客户端可以选择任意tracker server。tracker发送download请求给某个tracker，必须带上文件名信息，tracke从文件名中解析出文件的group、大小、创建时间等信息，然后为该请求选择一个storage用来服务读请求。

## FastDFS部署 两台服务器



在server.com 和server1.com同时运行装机脚本，bushu_openresty.sh

先做一件事，修改hosts，将文件服务器的ip与域名映射(单机TrackerServer环境)，因为后面很多配置里面都需要去配置服务器地址，ip变了，就只需要修改hosts即可。

### 一、安装依赖

```
yum install git gcc gcc-c++ make automake autoconf libtool pcre pcre-devel zlib zlib-devel openssl openssl-devel wget vim -y
```

### 二、安装FastDFS

```
mkdir /data/fdfs/{storage,client,tracker}/{data,logs} -p

mkdir /fdfs

cd /fdfs

git clone https://github.com/happyfish100/fastdfs


#下载安装 libfastcommon
#libfastcommon是从 FastDFS 和 FastDHT 中提取出来的公共 C 函数库，基础环境，安装即可
git clone https://github.com/happyfish100/libfastcommon


cd /fdfs/libfastcommon 

./make.sh && ./make.sh install

cd /fdfs/fastdfs

./make.sh && ./make.sh install

./setup.sh /etc/fdfs/      #也可以不带后面的/etc/fdfs/默认的就是cp到这个路径。

systemctl daemon-reload
```

### 1、配置Tracker

1. 编辑配置文件

`vim /etc/fdfs/tracker.conf`

```bash
base_path=/home/yuqing/fastdfs # 基础路径  修改为/data/fdfs/tracker
reserved_storage_space = 20% # storage保留空间 修改为1%
```

2. 配置开机自启

`systemctl enable fdfs_trackerd`

3. 启动trakcer

`systemctl start fdfs_trackerd`

启动成功后会自动创建data、logs两个目录。

```
ls /data/fdfs/tracker/data/
```



4. 查看tracker日志

`tailf /data/fdfs/tracker/logs/trackerd.log`

5. 配置openresty

```bash
mkdir /software/站点配置文件/ -p
cat <<EOF >/software/站点配置文件/fdfs.conf
upstream fdfs_group1 {
    # 修改为对应storage
    server 47.56.185.141:8888 weight=1 max_fails=2 fail_timeout=30s;
}
server {
    listen 80;
    server_name 47.75.70.29; # 修改为对应值
    add_header Access-Control-Allow-Origin *;
    add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS';
    add_header Access-Control-Allow-Headers 'content-type,token,version,DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization';
    if (\$request_method = 'OPTIONS') {
        return 204;
    }
    location /group1/M00 {
        proxy_next_upstream http_502 http_504 error timeout invalid_header;
        proxy_pass http://fdfs_group1;
        expires 30d;
    }
}
EOF

openresty -s reload
```

5.1.配置ssl证书集群版本

```
upstream fdfs_group1 {
    server 107.148.217.22:8888 weight=1 max_fails=2 fail_timeout=30s;
    server 198.2.202.222:8888 weight=1 max_fails=2 fail_timeout=30s;
}
server {
    listen 80;
    server_name ludobe.com www.ludobe.com;

    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ludobe.com www.ludobe.com;
    add_header Access-Control-Allow-Origin *;
    add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS';
    add_header Access-Control-Allow-Headers 'content-type,token,version,DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization';
    if ($request_method = 'OPTIONS') {
        return 204;
    }
    location /group1/M00 {
        proxy_next_upstream http_502 http_504 error timeout invalid_header;
        proxy_pass http://fdfs_group1;
        expires 30d;
    }
    ssl_certificate_key /software/域名证书/ludobe.com/ludobe.com.key;
    ssl_certificate /software/域名证书/ludobe.com/ludobe.com.nginx.crt;
}

# 阿里云回源
server {
    listen 88;
    server_name ludobe.com www.ludobe.com;

    add_header Access-Control-Allow-Origin *;
    add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS';
    add_header Access-Control-Allow-Headers 'content-type,token,version,DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization';
    if ($request_method = 'OPTIONS') {
        return 204;
    }
    location /group1/M00 {
        proxy_next_upstream http_502 http_504 error timeout invalid_header;
        proxy_pass http://fdfs_group1;
        expires 30d;
    }
}

```





配置防火墙

```
iptables -A INPUT -p tcp -m state --state NEW -m  tcp --dport 22122 -j ACCEPT
iptables -A INPUT -m state --state NEW -p tcp -m tcp --dport 23000 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --sports 22122 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,8888 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --sports 80,8888 -j ACCEPT

```



### 2、配置Storage

1. 编辑配置文件

`vim /etc/fdfs/storage.conf`

主要配置以下几项

```shell
group_name=group1 # 组名
base_path=/home/yuqing/fastdfs # 基础路径  修改为/data/fdfs/storage
store_path0=/home/yuqing/fastdfs # 存储路径 修改为/data/fdfs/storage
tracker_server=192.168.209.121:22122 # tracker地址 修改为对应地址
tracker_server=192.168.209.122:22122 # 若单tracker 可注释
```

2. 编译安装openresty及fastdfs-nginx-module

```bash
mkdir /usr/local/openresty/nginx/ -p   #有就不用创建了


git clone https://github.com/happyfish100/fastdfs-nginx-module

wget https://openresty.org/download/openresty-1.17.8.2.tar.gz

tar xf openresty-1.17.8.2.tar.gz

cd openresty-1.17.8.2/

./configure --prefix=/usr/local/openresty --with-pcre-jit --with-stream --with-stream_ssl_module --with-stream_ssl_preread_module --with-http_v2_module --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module --with-http_stub_status_module --with-http_realip_module --with-http_addition_module --with-http_auth_request_module --with-http_secure_link_module --with-http_random_index_module --with-http_gzip_static_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-threads  --with-stream --with-stream_ssl_preread_module --with-http_ssl_module --add-module=/fdfs/fastdfs-nginx-module/src/

gmake && gmake install

systemctl restart openresty
```

3. 配置开机自启

`systemctl enable fdfs_storaged`

4. 启动storage

`systemctl start fdfs_storaged`

5. 查看storage日志

`tailf /data/fdfs/storage/logs/storaged.log`

这时候存储目录已经自动创建好了

6. 配置mod_fastdfs.conf

`cp /fdfs/fastdfs-nginx-module/src/mod_fastdfs.conf /etc/fdfs/`

`vim /etc/fdfs/mod_fastdfs.conf`

主要配置以下几项

```shell
tracker_server=tracker:22122 # tracker地址 修改为对应地址
group_name=group1 # 组名
url_have_group_name = false # url是否包含组名 修改为true
store_path0=/home/yuqing/fastdfs # storage存储路径 修改为/data/fdfs/storage
```

7. 配置openresty

```bash
mkdir /software/站点配置文件/ -p
cat <<EOF >/software/站点配置文件/fdfs.conf
server {
    listen 8888;
    server_name 47.56.185.141; # 此处进行对应修改
    location /group1/M00 {
        ngx_fastdfs_module;
    }
}
EOF
openresty -s reload
```



### 3、配置client

`vim /etc/fdfs/client.conf`

主要配置以下几项

```shell
base_path=/home/yuqing/fastdfs # 基础路径  修改为/data/fdfs/client
tracker_server=192.168.209.121:22122 # tracker地址 修改为对应地址
tracker_server=192.168.209.122:22122 # 若单tracker 可注释
```

### 三、测试

### 1、查看FastDFS集群状态

`fdfs_monitor /etc/fdfs/client.conf`

### 2、上传文件测试

```bash
[root@Tracker ~]$ fdfs_upload_file /etc/fdfs/client.conf /fdfs/fastdfs/README_zh.md 

group1/M00/00/00/Lzi5jV3hBsGAB4RaAAAGpOD9zYI2054.md
```

若返回 fid 则上传成功

### 3、文件访问测试

使用浏览器访问`http://47.75.70.29/group1/M00/00/00/Lzi5jV3hBsGAB4RaAAAGpOD9zYI2054.md`若能正常下载，即集群正常工作。