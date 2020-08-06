 ry_files指令是在nginx0.7.27版本中开始加入的，它可以按顺序检查文件是否存在，并返回第一个找到的文件，如果未找到任何文件，则会调用最后一个参数进行内部重定向。

 try_files指令，官方说明：http://nginx.org/en/docs/http/ngx_http_core_module.html#try_files 

语法：try_files file ... uri; try_files file ... =code; 默认值：无 作用域：server, location 

 示例一：

```
location /luke/ {
    try_files $uri /luke/default.gif;
}
```

 说明：

 1、访问www.example.com/luke/123/321（文件不存在）时，此时看到的是default.gif图片，URL地址不变 

 2、访问www.example.com/luke/123.png（文件存在）时，此时看到的是123.png图片，URL地址不变 

 总结：当images目录下文件不存在时，默认返回default.gif 

 示例二： 

```

location /luke/ {
    try_files $uri =403;
}

```
说明：

1、访问www.example.com/luke/123.html（文件存在）时，此时看到的是123.html内容，URL地址不变

2、访问www.example.com/luke/21.html（文件不存在）时，此时看到的是403状态，URL地址不变

总结：和示例一一样，只是将默认图片换成了403状态

示例三：

```
location /luke/ {
    try_files $uri @ab;
}
location @ab {
    rewrite ^/(.*)$ https://www.yichenxiu.com;
}
```
说明：

1、访问www.example.com/luke/123.html（文件存在）时，此时看到的是123.html内容，URL地址不变

2、访问www.example.com/luke/21.html（文件不存在）时，此时跳转到博客，URL地址改变

总结：当文件不存在时，会去查找@ab值，此时在location中定义@ab值跳转到博客

示例四：

```
try_files $uri @pro;
location @pro {
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_pass https://www.yichenxiu.com;
}

```
说明：

1、访问www.example.com/123.html（文件存在）时，此时看到的是123.html内容，URL地址不变

2、访问www.example.com/post-3647.html（文件不存在）时，此时看到的是博客的内容，URL地址不变

总结：当前服务器上文件不存在时，会进行反向代理


