## 1,linux下安装node.js

 Node.js 官网：

```
https://nodejs.org
```

 下载Node.js： 可以去官网下载最新的版本

```

wget https://nodejs.org/dist/v4.4.3/node-v4.4.3-linux-x64.tar.xz  #旧版本
wget    https://nodejs.org/dist/v12.14.0/node-v12.14.0-linux-x64.tar.xz

tar -xvf node-v12.14.0-linux-x64.tar.xz #解压tar
```

全局链接设置：

```

ln -s /root/node-v12.14.0-linux-x64/bin/node /usr/local/bin/node
ln -s /root/node-v12.14.0-linux-x64/bin/npm /usr/local/bin/npm

```



##  2,forever守护nodejs进程

 客户端启动Node.js应用 

```
node app.js  # 方法一
npm start    # 方法二 Express框架
```

这样可以正常启动应用，但是如果断开客户端连接，应用也就随之停止了。也就是说这样的启动方式没有给应用一个守护线程。

 Forever可以解决这个问题！Forever可以守护Node.js应用，客户端断开的情况下，应用也能正常工作。

安装过Node.js后再安装forever，需要加-g参数，因为forever要求安装到全局环境下：

```
[sudo] npm install forever -g

ln -s /root/node-v12.14.0-linux-x64/bin/forever /usr/local/bin/forever
```

 forever使用： 

```

# 启动
forever start ./bin/www  ＃最简单的启动方式
forever start -l forever.log ./bin/www  #指定forever日志输出文件，默认路径~/.forever
forever start -l forever.log -a ./bin/www  #需要注意，如果第一次启动带日志输出文件，以后启动都需要加上 -a 参数，forever默认不覆盖原文件
forever start -o out.log -e err.log ./bin/www  ＃指定node.js应用的控制台输出文件和错误信息输出文件
forever start -w ./bin/www  #监听当前目录下文件改动，如有改动，立刻重启应用，不推荐的做法！如有日志文件，日志文件是频繁更改的

# 重启
forever restart ./bin/www  ＃重启单个应用
forever restart [pid]  #根据pid重启单个应用
forever restartall  #重启所有应用

# 停止（和重启很类似）
forever stop ./bin/www  ＃停止单个应用
forever stop [pid]  #根据pid停止单个应用
forever stopall  ＃停止所有应用

# 查看forever守护的应用列表
forever list

```

