# fiddler ios手机 抓包app api域名

# 第一步：配置网络

iPhone 和电脑连接同一个 WIFI。

# 第二步：配置 fiddler

1、打开 fiddler，进入 Tools —— Options...

2、如下图设置：

![arrESs.png](https://s1.ax1x.com/2020/08/05/arrESs.png)

搞一下证书

![arr1fJ.png](https://s1.ax1x.com/2020/08/05/arr1fJ.png)

选择Connections 允许远程连接

![arrYOx.png](https://s1.ax1x.com/2020/08/05/arrYOx.png)

3、设置完成后，保存，然后重启 fiddler



# 第三步：手机设置代理

1、查看电脑的ip：

![arrU0K.png](https://s1.ax1x.com/2020/08/05/arrU0K.png)



假如电脑 ip为：192.168.1.102

2、iPhone 手机打开 “设置 —— 无线局域网”，点击已连接 wifi 后面的小叹号，如图

![arrTcn.png](https://s1.ax1x.com/2020/08/05/arrTcn.png)

3、然后滑动到页面最下方，点击“配置代理”，配置代理默认是关闭的。



选择“手动”，然后在“服务器”输入电脑的ip，在“端口”输入“8888”。切记，抓包完成后，将配置代理设置为“关闭”，否则可能影响手机的上网。

![arrbn0.png](https://s1.ax1x.com/2020/08/05/arrbn0.png)



# 第四步：安装证书

在 Safair 浏览器中打开 电脑ip:8888，例如“192.168.1.102:8888”。

点击圈出来的链接安装证书

![arrjNF.png](https://s1.ax1x.com/2020/08/05/arrjNF.png)



只安装还不行，iPhone默认不会开启信任的，需要手动添加一下证书信任，设置 - 通用 - 关于本机，最下面有个信任证书设置按钮，打开后是下面的页面，将DO_NOT_TRUST_FiddlerRoot这个证书打开，不信任这个证书是抓不到https包的，同样的测试完之后你也可以将他关闭。

![ars9j1.png](https://s1.ax1x.com/2020/08/05/ars9j1.png)

到这里，就可以使用fiddler抓包iPhone了，直接在手机上进入对应的APP就可以获取相应的数据了。

