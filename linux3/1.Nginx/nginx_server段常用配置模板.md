[toc]

## 一，常规简单的

### 1, 配置域名可以正常访问80端口

```
server {
    listen 80;
    server_name wohenliu.com www.wohenliu.com;
    root        /software/web目录/wohenliu.com;
    index index.html index.htm;
    charset utf-8;
}

```

### 2，配置域名正常访问80端口自动跳转443端口家目录(有几种方式参考)

**这种需要提前申请ssl证书**

- 第一种

```
server {
    listen 80;
    listen 443 ssl;
    server_name wohenliu.com www.wohenliu.com;
    root        /software/web家目录/wohenliu.com;
    index index.html index.htm;
    charset utf-8;
        # HSTS
        add_header  Strict-Transport-Security  "max-age=31536000";
        add_header  X-Frame-Options  deny;
        add_header  X-XSS-Protection "1";

    ssl_certificate_key /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.key;
    ssl_certificate /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.nginx.crt;
    
    if ($scheme = http ) {
        return 301 https://$host$request_uri;
    }
}

```

- 第二种

```
server {
    listen       80;
    server_name  wohenliu.com www.wohenliu.com;
    
    return 301 https://$host$request_uri;
}   
server {
    listen 443 ssl http2; 
    server_name wohenliu.com www.wohenliu.com;
    root        /software/web家目录/wohenliu.com;
    index index.html index.htm;
        charset utf-8;
        # HSTS
        add_header  Strict-Transport-Security  "max-age=31536000";
        add_header  X-Frame-Options  deny;
        add_header  X-XSS-Protection "1";
        
    ssl_certificate_key /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.key;
    ssl_certificate /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.nginx.crt;
}



```

![adEYUP.png](https://s1.ax1x.com/2020/08/03/adEYUP.png)



### 3,配置域名直接跳转到其他域名不设置自己的家目录

**同样有多种方式**

- 第一种

```
server {
        listen       80;
        listen       443 ssl;
        server_name  wohenliu.com www.wohenliu.com;
        add_header Strict-Transport-Security "max-age=15768000; includeSubDomains" always;
        charset      utf-8;

        if ($scheme = http ) {
        return 301 https://$host$request_uri;
        }
        return 301 https://baidu.com:2019$request_uri;

        ssl_certificate_key /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.key;
        ssl_certificate /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.nginx.crt;

}

```

![adEa8S.png](https://s1.ax1x.com/2020/08/03/adEa8S.png)

### 4,配置域名通过自己家目录html跳转

```
server {
    listen 80;
    listen 443 ssl;
    server_name wohenliu.com www.wohenliu.com;
    root        /software/web家目录/wohenliu.com;
    index index.html index.htm;
    charset utf-8;
        # HSTS
        add_header  Strict-Transport-Security  "max-age=31536000";
        add_header  X-Frame-Options  deny;
        add_header  X-XSS-Protection "1";

    ssl_certificate_key /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.key;
    ssl_certificate /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.nginx.crt;
    
    if ($scheme = http ) {
        return 301 https://$host$request_uri;
    }
}
```

**和上面一样，只是需要增加html代码内容**

## 二，需要统计代理线参数的location配置

###  1, 不同的域名使用同样的家目录后面增加共享名参数80端口

```
server {
        listen       80;
        server_name  wohenliu.com;
        charset      utf-8;
        root         /software/web家目录/wohenliu.com;
        index        index.html;

        location =/ {
            if ($arg_shareName = ""){
                rewrite ^ http://$host/index.html?shareName=qptg9 break;
            }
        }
}

```

**这段代表如果只要本条域名共享名为空的话，就会跳转访问家目录且后面的参数是qptg9**

### 2，域名跳转其他域名且后面跟对应的参数和设置默认的跳转

```
server {
        listen       80;
        listen       443 ssl;
        server_name  wohenliu.com www.wohenliu.com;
        # HSTS
        add_header  Strict-Transport-Security  "max-age=31536000";
        add_header  X-Frame-Options  deny;
        add_header  X-XSS-Protection "1";

        ssl_certificate_key /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.key;
        ssl_certificate /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.nginx.crt;

        if ($arg_channelCode != "") {
            rewrite ^/(.*) https://www.qita.com/$1 break;
        }

        rewrite ^/(.*) https://www.qita.com/?channelCode=1020 break;
}

```

**这种只要输入域名，就会跳转其他域名，且默认跳后面参数为channelCode=1020, brak代表停止执行后面的rewrite指令集**

### 3，设置匹配到域名后面的参数就跳转不同的家目录

```
server {
        listen       80;
        listen       443 ssl;
        server_name  wohenliu.com www.wohenliu.com;
        root         /software/web家目录/wohenliu.com;
        charset      utf-8;
        index        index.html;

        if ($server_port = 80 ) {
            return 301 https://$host$request_uri;
        }
        location / {
        if ($arg_shareName = gdx26) {
            root /software/web家目录/wohenliu.com_gdx26;
        }
        if ($arg_shareName = gdx27) {
            root /software/web家目录/wohenliu.com_gdx27;
        }
        if ($arg_shareName = gdx28) {
            root /software/web家目录/wohenliu.com_gdx28;
        }
        }
        ssl_certificate_key /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.key;
        ssl_certificate /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.nginx.crt;
}

```

**这种只要输入域名时后面加入其他指定参数就会跳转到对应的家目录**

### 4, 配置？后面的固定参数访问指定家目录，同时指定跳转指定参数，同时其他参数也可以访问

```
server { 
        listen       80;
        listen       443 ssl;
        server_name  wohenliu.com www.wohenliu.com;
        # HSTS
        add_header  Strict-Transport-Security  "max-age=31536000";
        add_header  X-Frame-Options  deny;
        add_header  X-XSS-Protection "1";
        ssl_certificate_key /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.key;
        ssl_certificate /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.nginx.crt;

         if ($server_port = 80  ) {
        return 301 https://$host$request_uri;
    }


   location / {
        if ($arg_channelCode = 10028) {
        root /software/web家目录/wohenliu.com ;

       }

    }

        if ($arg_channelCode = "") {
            rewrite ^/(.*) https://www.qitayuming.com/?channelCode=1005 break;
        }

          if ($arg_channelCode != "10028") {
        rewrite ^/(.*) https://www.qitayuming.com/$1 break;
}

}

```

![adErbn.png](https://s1.ax1x.com/2020/08/03/adErbn.png)

**这种家目录也可以指定跳转其他域名并获取后面的参数字符串**

相关html代码

```
<html>
<head>
<title>正在跳转</title>
<meta http-equiv="Content-Language" content="zh-CN">
<meta HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=gb2312">
<!-- <meta http-equiv="refresh" content="1;url=https://www.cq88xz.com/"> -->
<script>
  var argsStr = location.search;
  var oMeta = document.createElement('meta');
    oMeta.httpEquiv = 'refresh';
    oMeta.content = '1;url=https://www.qitayuming.com/'+argsStr;

    document.getElementsByTagName('head')[0].appendChild(oMeta);
</script>
</head>
<body>
</body>
</html>

```

### 5, location 配置轮询访问

**访问 woheliu.com就会跳自己的家目录，访问www.wohenliu.com 就会跳转到webzu轮询**

**而轮询定义的又是几个端口，每个端口跳转的域名也分别不同，注意轮询的端口不能和其他配置端口一样，要不然会报400错误**

```
upstream webzu {
        server localhost:81;
        server localhost:82;
        server localhost:83;
    }
server {
        listen       80 ;
        listen       443 ssl;
        server_name  wohenliu.com;
        root         /software/web家目录/wohenliu.com;
        charset      utf-8;
        index        index.html index.htm;
        if ($scheme = http ) {
        return 301 https://$host$request_uri;
        }
        ssl_certificate_key /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.key;
        ssl_certificate /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.nginx.crt;
}

server {
        listen       80 ;
        listen       443 ssl;
        server_name  www.wohenliu.com;
        if ($scheme = http ) {
        return 301 https://$host$request_uri;
        }
        location /zimuliu1044 {
                alias   /software/web家目录/wohenliu.com/zimuliu1044;
                index        index.html index.htm;
        }
        location / {
                proxy_pass http://webzu;
        }
        ssl_certificate_key /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.key;
        ssl_certificate /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.nginx.crt;
}

server {
        listen       81;
        server_name  localhost;
        if ($arg_c != '' ){
                rewrite ^/ https://qitayuming1.com/register.html?c=$arg_c? permanent;
        }
        location /zimuliu1044 {
                alias   /software/web家目录/wohenliu.com/zimuliu1044;
                index        index.html index.htm;
        }
        location / {
                rewrite ^/ https://qitayuming/? permanent;
        }
}

server {
        listen       82;
        server_name  localhost;
        if ($arg_c != '' ){
                rewrite ^/ https://www.qitayuming2.com/register.html?c=$arg_c? permanent;
        }
        location /zimuliu1044 {
                alias   /software/web家目录/wohenliu.com/zimuliu1044;
                index        index.html index.htm;
        }
        location / {
                rewrite ^/ https://qitayuming.com/? permanent;
        }
}

server {
        listen       83;
        server_name  localhost;
        if ($arg_c != '' ){
                rewrite ^/ https://www.qitayuming3.com/register.html?c=$arg_c? permanent;
        }
        location /zimuliu1044 {
                alias   /software/web家目录/wohenliu.com/zimuliu1044;
                index        index.html index.htm;
        }
        location / {
                rewrite ^/ https://qitayuming.com/? permanent;
        }
}


```

![adE6U0.png](https://s1.ax1x.com/2020/08/03/adE6U0.png)

一般后?c后面的参数由域名管理者进行设置的，

下面是示列


```
https://www.wohenliu.com/?c=9YPXQ&type=NewBET365

```

#### 6 ，配置代理线 域名指定的？后面的参数，跳转其他域名，其他？后面的参数就跳转默认其他代理域名

```
server {
        listen  80;
        listen  443 ssl;
        server_name     yichenxiu.com www.yichenxiu.com;
        root /software/tx棋牌落地站点/yichenxiu.com;
        #HSTS
        add_header Strict-Transport-Security  "max-age=31536000";
        add_header X-Frame-Options deny;
        add_header X-XSS-Protection "1";

        ssl_certificate_key /etc/nginx/conf/域名证书/yichenxiu.com/Nginx/yichenxiu.com.key;
        ssl_certificate /etc/nginx/conf/域名证书/yichenxiu.com/Nginx/yichenxiu.com.nginx.crt;

        if ($scheme = http) {

                return 301 https://$host$request_uri;
        }
        if ($arg_c = 'QS3KC') {

            rewrite ^/(.*) https://www.www-yichenxiu.com:2020/?c=$arg_c? permanent;
        }

        if ($arg_c = 'ZY4SX'){

            rewrite ^/(.*) https://www.www-yichenxiu.com:2020/?c=$arg_c? permanent;
        }

        if ($arg_c != '') {
                rewrite ^/(.*) https://qita.com:8989/?c=$arg_c? permanent;
        }

        location / {

                rewrite ^/ https://qita.com:8989 permanent;
        }

}

```





# 三，Nginx区分PC或手机访问不同网站

### 1， 简单的服务器端实现方法直接配置
```
server {
        listen       80;
        listen       443  ssl;
        listen       2021 ssl;
        server_name  wohenliu.com;
        add_header Strict-Transport-Security "max-age=15768000; includeSubDomains" always;
        charset      utf-8;


        if ($scheme = http ) {
        return 301 https://$host$request_uri;
        }

        location / {
                root /software/web家目录/wohenliu.com;

                if ( $http_user_agent ~ "(MIDP)|(WAP)|(UP.Browser)|(Smartphone)|(Obigo)|(Mobile)|(AU.Browser)|(wxd.Mms)|(WxdB.Browser)|(CLDC)|(UP.Link)|(KM.Browser)|(UCWEB)|(SEMC\-Browser)|(Mini)|(Symbian)|(Palm)|(Nokia)|(Panasonic)|(MOT\-)|(SonyEricsson)|(NEC\-)|(Alcatel)|(Ericsson)|(BENQ)|(BenQ)|(Amoisonic)|(Amoi\-)|(Capitel)|(PHILIPS)|(SAMSUNG)|(Lenovo)|(Mitsu)|(Motorola)|(SHARP)|(WAPPER)|(LG\-)|(LG/)|(EG900)|(CECT)|(Compal)|(kejian)|(Bird)|(BIRD)|(G900/V1.0)|(Arima)|(CTL)|(TDG)|(Daxian)|(DAXIAN)|(DBTEL)|(Eastcom)|(EASTCOM)|(PANTECH)|(Dopod)|(Haier)|(HAIER)|(KONKA)|(KEJIAN)|(LENOVO)|(Soutec)|(SOUTEC)|(SAGEM)|(SEC\-)|(SED\-)|(EMOL\-)|(INNO55)|(ZTE)|(iPhone)|(Android)|(Windows CE)|(Wget)|(Java)|(curl)|(Opera)" )
        {
                root /software/web家目录/wohenliu.com/mobile;
        }
                index index.html index.htm;}

        ssl_certificate_key /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.key;
        ssl_certificate /etc/nginx/conf/域名证书/wohenliu.com/Nginx/wohenliu.com.nginx.crt;

}
```

配置好后就去家目录创建一个移动端的目录，名为mobile，这样只要客户用手机访问就可以直接访问指定目录下的内容了，默认是访问正常的Pc页面，

### 2. 直接跳转其他地址，不用配置家目录

```
server {
        listen       80; 
        listen       443 ssl;
        server_name  yichenxiu.com www.yichenxiu.com;
        add_header Strict-Transport-Security "max-age=15768000; includeSubDomains" always;
        charset      utf-8;
        
        if ($scheme = http ) {
        return 301 https://$host$request_uri;
        }        if  ( $http_user_agent ~ "(MIDP)|(WAP)|(UP.Browser)|(Smartphone)|(Obigo)|(Mobile)|(AU.Browser)|(wxd.Mms)|(WxdB.Browser)|(CLDC)|(UP.Link)|(KM.Browser)|(UCWEB)|(SEMC\-Browser)|(Mini)|(Symbian)|(Palm)|(Nokia)|(Panasonic)|(MOT\-)|(SonyEricsson)|(NEC\-)|(Alcatel)|(Ericsson)|(BENQ)|(BenQ)|(Amoisonic)|(Amoi\-)|(Capitel)|(PHILIPS)|(SAMSUNG)|(Lenovo)|(Mitsu)|(Motorola)|(SHARP)|(WAPPER)|(LG\-)|(LG/)|(EG900)|(CECT)|(Compal)|(kejian)|(Bird)|(BIRD)|(G900/V1.0)|(Arima)|(CTL)|(TDG)|(Daxian)|(DAXIAN)|(DBTEL)|(Eastcom)|(EASTCOM)|(PANTECH)|(Dopod)|(Haier)|(HAIER)|(KONKA)|(KEJIAN)|(LENOVO)|(Soutec)|(SOUTEC)|(SAGEM)|(SEC\-)|(SED\-)|(EMOL\-)|(INNO55)|(ZTE)|(iPhone)|(Android)|(Windows CE)|(Wget)|(Java)|(curl)|(Opera)" ) {
                rewrite ^/(.*)  https://yichenxiu.com/xiazai.html break;
                }
        location / {
                rewrite ^/(.*) https://baidu.com$1 break;
}

        
        ssl_certificate_key /etc/nginx/conf/域名证书/yichenxiu.com/Nginx/yichenxiu.com.key;
        ssl_certificate /etc/nginx/conf/域名证书/yichenxiu.com/Nginx/yichenxiu.com.nginx.crt;

}


```

这样配置手机端访问就跳转到 手机端访问的域名，电脑就跳转到其他PC页面

### 3, 访问手机端跳转默认页面，访问电脑端轮询跳转其他h5页面

```

upstream  chuan {
    server localhost:1024 weight=1;
    server localhost:1025 weight=1;
}
server {
        listen       80; 
        listen       443 ssl;
        server_name  yichenxiu.com www.yichenxiu.com;
        root /software/落地站点/yichenxiu.com;
        # HSTS
        add_header  Strict-Transport-Security  "max-age=31536000";
        add_header  X-Frame-Options  deny;
        add_header  X-XSS-Protection "1";

        
        ssl_certificate_key /etc/nginx/conf/域名证书/yichenxiu.com/Nginx/yichenxiu.com.key;
        ssl_certificate /etc/nginx/conf/域名证书/yichenxiu.com/Nginx/yichenxiu.com.nginx.crt;
        
        if ( $server_port = 80 ){
          rewrite ^/(.*) https://www.yichenxiu.com  permanent;
     }  
        location / {
        if ($http_user_agent !~* (mobile|nokia|iphone|ipad|android|samsung|htc|blackberry)) {
                proxy_pass http://chuan;
    }
  }

}
server {
        listen       1024;
        server_name  localhost;
        location / {
                rewrite ^/ https://yichenh5.cc:8989 permanent;
        }
}
server {
        listen       1025;
        server_name  localhost;
        location / {
                rewrite ^/ https://yichenh5.net:8989 permanent;
}
}
```

这样手机访问就是下载落地页，电脑访问就是pc页域名

#### 4， 配置域名指定代理链接统计网站访问

```

        if ($scheme = http) {

                return 301 https://$host$request_uri;

        }

        location /QS3KC {

          alias /software/tx棋牌落地站点/cq88ad.com;
          index index.html;


        }

        location / {

        if ($arg_c = 'QS3KC') {

            rewrite ^/(.*) https://cq88ad.com/QS3KC permanent;
        }

        if ($arg_c = 'ZY4SX'){

            rewrite ^/(.*) https://www.www-8cq88.com/?c=$arg_c? permanent;
        }

        if ($arg_c = 'ZEUN1'){

            rewrite ^/(.*) https://www.www-8cq88.com/?c=$arg_c? permanent;
        }
        if ($arg_c = 'RQPOC'){

            rewrite ^/(.*) https://www.www-8cq88.com/?c=$arg_c? permanent;
        }

                rewrite ^/ https://cq88ad1.com:8989 permanent;
        }

}

```

