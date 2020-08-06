# FastDFS部署

## 一、安装依赖

```bash
yum install git gcc gcc-c++ make automake autoconf libtool pcre pcre-devel zlib zlib-devel openssl-devel wget vim -y
```

## 二、安装FastDFS

```bash
mkdir /data/fdfs/{storage,client,tracker}/{data,logs} -p

mkdir /fdfs

cd /fdfs

git clone https://github.com/happyfish100/fastdfs

git clone https://github.com/happyfish100/libfastcommon

cd /fdfs/libfastcommon 

./make.sh && ./make.sh install

cd /fdfs/fastdfs

./make.sh && ./make.sh install

./setup.sh /etc/fdfs/

systemctl daemon-reload
```

### 1、配置Tracker

1. 编辑配置文件

vim /etc/fdfs/tracker.conf`

```bash
base_path=/home/yuqing/fastdfs # 基础路径  修改为/data/fdfs/tracker
reserved_storage_space = 20% # storage保留空间 修改为1%
```

2. 配置开机自启

`systemctl enable fdfs_trackerd`

3. 启动trakcer

`systemctl start fdfs_trackerd`

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

## 三、测试

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
