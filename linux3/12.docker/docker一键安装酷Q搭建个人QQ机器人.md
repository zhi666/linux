# docker一键安装酷Q搭建个人QQ机器人

## 一，通过docker 运行容器

1. 先下载coolq镜像

   ```
   docker pull coolq/wine-coolq
   
   mkdir /data/coolq/coolq-data/ -p
   ```

2.  创建一个nginx.conf文件

   ```
vim /data/coolq/coolq-data/nginx.conf
   
   user user user;
worker_processes 1;
   pid /var/run/nginx.pid;
   
   events {
       worker_connections 768;
       multi_accept on;
   }
   
   http {
       sendfile on;
       tcp_nopush on;
       tcp_nodelay on;
       keepalive_timeout 65;
       types_hash_max_size 2048;
       server_tokens off;
   
       set_real_ip_from  10.0.0.0/8;
       set_real_ip_from  100.64.0.0/10;
       set_real_ip_from  169.254.0.0/16;
       set_real_ip_from  172.16.0.0/12;
       set_real_ip_from  192.168.0.0/16;
   
       real_ip_header    X-Forwarded-For;
       real_ip_recursive off;
   
       server_names_hash_bucket_size 64;
       server_name_in_redirect off;
   
       include /etc/nginx/mime.types;
       default_type application/octet-stream;
   
       ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
       ssl_prefer_server_ciphers on;
   
       access_log /dev/stdout;
       error_log /dev/stderr;
   
       gzip on;
       gzip_disable "msie6";
   
       gzip_vary on;
       gzip_proxied any;
       gzip_comp_level 6;
       gzip_buffers 16 8k;
       gzip_http_version 1.1;
       gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
   
       map $http_x_forwarded_proto $upstream_https {
           default "$https";
           "https" "on";
           "http" "";
       }
   
       map $http_x_forwarded_proto $upstream_scheme {
           default "$scheme";
           "https" "https";
           "http" "http";
       }
   
       map $http_x_forwarded_host $upstream_server_name {
           "" "$server_name";
           default "$http_x_forwarded_host";
       }
   
       server {
           listen 9000 default_server;
   
           root /app/src/novnc;
           index index.html index.htm;
   
           server_name _;
   
           location / {
               index vnc.html index.html index.htm;
           }
   
           location /websockify {
               proxy_connect_timeout 7d;
               proxy_send_timeout 7d;
               proxy_read_timeout 7d;
               proxy_http_version 1.1;
               proxy_pass http://localhost:9001/;
               proxy_set_header Upgrade $http_upgrade;
               proxy_set_header Connection "upgrade";
           }
   
           location ~ /\. {
               deny all;
           }
       }
      } 
   ```
   
   
   
3. 运行容器

   ```
   docker run --name=coolq -it -d  --restart=always -p 88:9000 -v /data/cooclq/coolq-data:/home/user/coolq  -v /data/coolq/coolq-data/nginx.conf:/etc/nginx/nginx.conf -e VNC_PASSWD="123456" -e COOLQ_ACCOUNT="1234567" coolq/wine-coolq
   
   ```


3.  输入IP加88端口访问:密码就输入123456

   然后登陆小号QQ进行测试

## 二，通过docker-compose.yml一键启动

```
mkdir /data/coolq/coolq-data/ -p && cd /data/coolq/ && mkdir ./ssl/certs/wohenliu.com/ -p 

```

把上面的nginx.conf文件拷贝到/data/coolq/目录下

编辑 vim docker-compose.yml 文件

```
vim docker-compose.yml

version: '2'
services:
  coolq:
    image: coolq/wine-coolq
    container_name: coolq
    ports:
      - "82:9000"
      - "83:443"
    restart: always
    volumes:
      - ./coolq-data:/home/user/coolq
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
    environment:
      VNC_PASSWD: "123456"
      COOLQ_ACCOUNT: "123456"

```

然后执行命令

```
docker-compose up -d 
```

最后配置域名ssl访问，编辑nginx.conf文件

```
增加
server {
        listen 443 ssl;

        root /app/src/novnc;
        index index.html index.htm;

        server_name  www.wohenliu.com wohenliu.com;

ssl_certificate      /etc/ssl/certs/wohenliu.com/wohenliu.com.nginx.crt;
   ssl_certificate_key  /etc/ssl/certs/wohenliu.com/wohenliu.com.key;
        location / {
            index vnc.html index.html index.htm;
        }

        location /websockify {
            proxy_connect_timeout 7d;
            proxy_send_timeout 7d;
            proxy_read_timeout 7d;
            proxy_http_version 1.1;
            proxy_pass http://localhost:9001/;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }


```



改好了后就重启容器

然后登陆小号QQ进行测试