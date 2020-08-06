#!/bin/bash

#开始确定需要下载镜像的名字
echo "请输入需要下载的镜像"

read -p "请输入例如(nginx):  " images

image=$(docker search $images | awk -F ' '  'NR == 2 {print $2}')

echo "镜像的名字是: ${image}"

#导入163镜像配置 现在不需要导入了，会出bug
#echo '{
# "registry-mirrors": ["http://hub-mirror.c.163.com"]}' > /etc/docker/daemon.json

systemctl  restart docker
# 下载官网nginx镜像
 docker pull $image
#运行镜像，产生容器
docker run -d --name nginxtest -p 8081:80 $image 

#开始部署nginx
#拷贝容器内 Nginx 默认配置文件到本地/nginx/目录下，容器 ID 可以查看 docker ps 命令输入中的第一列,或者使用容器名ngnxtest
docker cp nginxtest:/etc/nginx/ /nginx/
#bash -x 2证书软链接.sh
#bash -x 3站点配置文件软链接.sh

#导入nginx主配置

echo "# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
# Load dynamic modules. See /usr/share/nginx/README.dynamic.
worker_rlimit_nofile 65535;
include /usr/share/nginx/modules/*.conf;
events {
    use epoll;
    multi_accept on;
    worker_connections 65535;
}
http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] \"\$request\" '
                      '\$status \$body_bytes_sent \"\$http_referer\" '
                      '\"\$http_user_agent\" \"\$http_x_forwarded_for\"';
    access_log  /var/log/nginx/access.log  main;
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;
    proxy_connect_timeout 300;
    proxy_send_timeout 300;
    proxy_read_timeout 300;
    proxy_buffer_size 256k;
    proxy_buffers 128 32k;
    proxy_busy_buffers_size 512k;
    proxy_temp_file_write_size 256k;
    proxy_max_temp_file_size 128m;
    proxy_redirect off;
    proxy_headers_hash_max_size 51200;
    proxy_headers_hash_bucket_size 6400;
    proxy_next_upstream error timeout invalid_header http_500 http_503 http_404;


    proxy_temp_path  /dev/shm/proxy_temp;
    proxy_cache_path /dev/shm/proxy_cache levels=1:2 keys_zone=cache_one:300m inactive=1d max_size=1g;

    gzip  on;
    gzip_min_length  1k;
    gzip_buffers     16 16k;
    gzip_http_version 1.1;
    gzip_comp_level 2;
    gzip_types       text/plain application/x-javascript text/css application/xml; 
    gzip_vary on;
    
    limit_req_zone \$binary_remote_addr zone=one:10m rate=5r/s;
    limit_conn_zone \$binary_remote_addr zone=addr:10m;
    server_tokens off;  #隐藏nginx的版本号
    server_names_hash_bucket_size 512;

    client_header_buffer_size 256k;
    large_client_header_buffers 4 256k;

    #size limits
    client_max_body_size    50m;
    client_body_buffer_size 256k;
    client_header_timeout   3m;
    client_body_timeout 3m;
    send_timeout   3m;
    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/kis/站点配置文件/*.conf;  #导入相关子配置文件
    include /etc/nginx/kis/站点配置文件/qipaiguanwang/*.conf;  #导入相关子配置文件
}" > /nginx/nginx/nginx.conf

#删除之前的软连接
rm -rf /nginx/nginx/kis/* 
rm -rf /nginx/nginx/conf/*
#创建软连接
ln -s /software/站点配置文件/  /nginx/nginx/kis/
ln -s /software/域名证书/   /nginx/nginx/conf

#zabbix监控nginx

echo "server {
        listen       80 ;
        server_name  localhost;
        root         /usr/share/nginx/html;
        
        location /nginx_status {
          stub_status on;
          access_log off;
          allow 127.0.0.1;
          allow 58.82.238.95;
          }

        location /php-fpm_status {
          include       fastcgi_params;
          fastcgi_pass  127.0.0.1:9000;
          fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}" > /nginx/nginx/conf.d/nginx_status.conf


#准备再次启动镜像，运行容器

echo "请输入你运行容器的名字"
read -p "例如(nginx-web):  " name

docker run -d -p 2018:2018 -p 2019:2019 -p 2020:2020 -p 2021:2021 -p 2022:2022 -p 2030:2030 -p 8080:8080 -p 80:80 -p 81:81 -p 2097:2097 -p 2098:2098 -p 2099:2099 -p 82:82 -p 83:83 -p 86:86 -p 87:87 -p 888:888 -p 88:88 -p 89:89 -p 666:666 -p 91:91 -p 443:443 -p 92:92 -p 93:93 --name $name -v /software:/software -v /nginx/nginx:/etc/nginx -v /nginx/logs:/var/log/nginx $image
