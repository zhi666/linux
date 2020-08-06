[toc]



### **HTTP跳转HTTPS协议几种方式性能对比**

我这里已`http://yichen2.com` 为例，要求所有访问该页面的请求全部跳转至`https://yichen2.com`,

并请求的`uri` 和参数`$query_string` 要保留下来。

常见的几种方法:

#### **1.使用if进行协议判断   -- 最差**

这种情况下，多为把`http`和`https`写在同一个`server`中，配置如下:

```
   server {

        listen 80 default_server;
        listen 443 ssl;
        server_name  yichen2.com;
        root /usr/share/nginx/html;
        index  test.html ;
        ssl_certificate  /root/ssl/yichen2.crt;
        ssl_certificate_key /root/ssl/yichen2.key;
        charset  utf-8;
        if ( $scheme = http ) {
        rewrite ^/(.*)$ https://yichen2.com/$1 permanent ;
}
        location / {

}

}

```

这种配置看起来简洁很多，但是性能是最差的，首先每次连接进来都需要`nginx` 进行协议判断，其次判断`http` 协议时进行地址匹配、重写、返回、再次判断，最后还有正则表达式的处理... .... 所以，生产上我们极不建议 这种写法。另外，能少用`if` 的尽量不用，如果一定要使用，也最好在`location` 段，并且结合`ruturn`  或者`rewrite ... last` 来使用。

#### **2.rewrite 方法1           -- 差**

一般80端口 443 ssl端口不要写在同一个`server` 中，这样虽然代码简洁了一些，但是性能并不是很好。

```
   server {

        listen 80 default_server;
        listen 443 ssl;
        server_name  yichen2.com;
        root /usr/share/nginx/html;
        index  test.html ;
        ssl_certificate  /root/ssl/yichen2.crt;
        ssl_certificate_key /root/ssl/yichen2.key;
        charset  utf-8;
        rewrite ^/(.*)$ https://yichen2.com/$1 permanent;
        location / {

}

}
```

测试

```
curl -k -I yichen2.com/a.html?a=3

HTTP/1.1 301 Moved Permanently
Server: nginx/1.16.1
Date: Mon, 29 Jun 2020 22:10:12 GMT
Content-Type: text/html
Content-Length: 169
Connection: keep-alive
Location: https://yichen2.com/a.html?a=3
```

可以看到实现了`http` 到`https`的跳转。并且保留了参数

#### **3.rewrite 方法2           -- 好**

不使用正则表达式。而使用变量来提升性能:

```
server {
        listen       80;
        server_name  yichen2.com;
        rewrite      ^ https://yichen2.com$request_uri? permanent;

}
server {

        listen       443 ssl;
        server_name  yichen2.com;
        root /usr/share/nginx/html;
        index  test.html ;
        ssl_certificate  /root/ssl/yichen2.crt;
        ssl_certificate_key /root/ssl/yichen2.key;
        charset  utf-8;
        location / {

}
}
```

**注意**: `$request_uri` 已经包含了查询参数，所以要在其重写规则后面加上`?` 以禁止再次传递参数，这种方法避免了`nginx` 内部处理正则的性能损坏，相比较上面的方式好了很多。



#### **4.return实现最优解    -- 最好**

虽然上面我们使用参数代替了正则，但是`rewrite` 规则会先对`url` 进行匹配，匹配上了再执行相应的规则，而 `return` 没有匹配`url` 层面的性能消耗，直接返回用户新的连接，所以是最优的解决方案。

```
server {
        listen       80;
        server_name  yichen2.com;
        return       301 https://$host$request_uri ;
}
server {

        listen       443 ssl;
        server_name  yichen2.com;
        root /usr/share/nginx/html;
        index  test.html ;
        ssl_certificate  /root/ssl/yichen2.crt;
        ssl_certificate_key /root/ssl/yichen2.key;
        charset  utf-8;
        location / {

}
}

```

**注意**: 在`return` 中， `$request_uri` 后面不用加`?` (加`?` 用来避免携带参数是`rewrite` 中的特性)。

如果希望实现永久重定向，则使用`return 301 https://$host$request_uri` , 不过想要两个域名都会使用，所以更多情况下使用`302` 临时重定向。

**301重定向和302重定向的区别**

　　302重定向只是暂时的重定向，搜索引擎会抓取新的内容而保留旧的地址，**因为服务器返回302，所以，搜索搜索引擎认为新的网址是暂时的。**

　　**而301重定向是永久的重定向，搜索引擎在抓取新的内容的同时也将旧的网址替换为了重定向之后的网址。**

　　