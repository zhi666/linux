## tomcat无法关闭的问题

shutdown.sh 报这样的错误

```
java.net.ConnectException: 连接超时
	at java.net.PlainSocketImpl.socketConnect(Native Method)
	at java.net.AbstractPlainSocketImpl.doConnect(AbstractPlainSocketImpl.java:345)
	at java.net.AbstractPlainSocketImpl.connectToAddress(AbstractPlainSocketImpl.java:206)
	at java.net.AbstractPlainSocketImpl.connect(AbstractPlainSocketImpl.java:188)
	at java.net.SocksSocketImpl.connect(SocksSocketImpl.java:392)
	at java.net.Socket.connect(Socket.java:589)
	at java.net.Socket.connect(Socket.java:538)
	at java.net.Socket.<init>(Socket.java:434)
	at java.net.Socket.<init>(Socket.java:211)
	at org.apache.catalina.startup.Catalina.stopServer(Catalina.java:450)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:497)
	at org.apache.catalina.startup.Bootstrap.stopServer(Bootstrap.java:400)
	at org.apache.catalina.startup.Bootstrap.main(Bootstrap.java:487)

The stop command failed. Attempting to signal the process to stop through OS signal.
Tomcat stopped.

```



解决办法就是修改catalina.sh文件，

```
	
 PRGDIR=`dirname "$PRG"`
```

在这行下面追加内容

```

if [ -z "$CATALINA_PID" ]; then

     CATALINA_PID=$PRGDIR/CATALINA_PID

     cat $CATALINA_PID

fi
```

![zhuijia](https://s2.ax1x.com/2019/12/17/QIS2sx.png)



然后修改 **修改Tomcat bin目录下shutdown.sh文件**；最后一句修改为如下 



```
exec "$PRGDIR"/"$EXECUTABLE" stop -force "$@"
```

添加一个参数 -force

```
然后在shutdown.sh 把停掉，也可以通过./catalina.sh start  启动， ./catalina.sh stop 停止

```



