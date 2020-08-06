

##  通过 itms-services 协议，发布或者分享 iOS 应用程序



 **itms-services 协议常用于 iOS 企业应用的无线部署，这可在不使用 iTunes 的情况下将内部软件发布或者分享给用户。**

**一、前期准备资料：**

1、应用程序 (.ipa) 文件（使用了企业级预置描述文件）；
2、清单 (.plist) 文件（xml格式的清单描述文件）。

**二、准备清单 (.plist) 文件：**

我们的清单文件时一个xml格式的文件，可以参考如下代码：

```

<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
  <dict>
      <key>items</key>
      <array>
        <dict>
           <key>assets</key>
           <array>
             <dict>
               <key>kind</key>
               <string>software-package</string>
               <key>url</key>
               <string><![CDATA[https://666-ff.oss-cn-shenzhen.aliyuncs.com/666ff.ipa]]></string>
             </dict>
             <dict>
               <key>kind</key>
               <string>display-image</string>
               <key>needs-shine</key>
               <integer>0</integer>
               <key>url</key>
               <string><![CDATA[https://666-ff.oss-cn-shenzhen.aliyuncs.com/logo.png]]></string>
             </dict>
             <dict>
               <key>kind</key>
               <string>full-size-image</string>
               <key>needs-shine</key>
               <true/>
               <key>url</key>
               <string><![CDATA[https://666-ff.oss-cn-shenzhen.aliyuncs.com/logo.png]]></string>
             </dict>
           </array>
           <key>metadata</key>
           <dict>
             <key>bundle-identifier</key>
             <string>com.666ff.cocosios</string>
             <key>bundle-version</key>
             <string><![CDATA[1.1.0]]></string>
             <key>kind</key>
             <string>software</string>
             <key>title</key>
             <string><![CDATA[666ff]]></string>
           </dict>
        </dict>
      </array>
  </dict>
</plist>

```

描述文件需要注意的三个地方：

1、两个 url 地址，即 software-package 和 display-image 的 URL，前者是所要安装的 ipa 地址，后者是安装时桌面显示的 logo 图标。
2、metadata里需要修改 bundle-identifier 和 bundle-version，具体是什么就不用介绍了，但是要注意一定要跟所安装的 ipa 包内容一致，不然无法安装成功。
3、可以修改title和subtitle，定制安装时弹出框的内容。

 那么plist文件内容是这样的。内容主要是告诉我们下载ipa文件的地址和icon图片的下载地址。这个文件必须通过https的访问才可以。因为现在苹果规定必须以https的方式进行访问 

![arBUjx.png](https://s1.ax1x.com/2020/08/05/arBUjx.png)





**三、ipa格式应用的分享或者发布**

可以使用以下两种方式提供下载：

**第1种是点击下载，在网页中加入如下的链接就行了：**

```
<a href="itms-services://?action=download-manifest&url=https://xxx-qq.oss-cn-shenzhen.aliyuncs.com/xxxx.plist">下载App</a>
```



**第2种是通过JavaScript自动下载，参考代码：**

```
<script>        var url = "https://xxx-qq.oss-cn-shenzhen.aliyuncs.com/xxxx.plist";        window.location = "itms-services://?action=download-manifest&url=" + url;</script>

```
备注：此代码放到 html 标签的 head 标记中，这样就会自动提示下载和安装了。

备注：请勿使用应用程序 (.ipa) 的 Web 链接方式提供下载。当打开清单文件（manifest.plist）时，设备会下载该 .ipa。虽然 URL 的协议部分是 itms-services，但 iTunes Store 并不参与此过程。



##  从itms-services协议中获取ipa的下载地址

在html代码里面配置ipa的plist文件

```
<script type="text/javascript">
        function DownSoft() {
            openInstall.wakeupOrInstall();
            if (isIOS) {
                $("#xrBox").show();
                showXR();
                // window.open("https://ff66.app2.xin", "_blank");
                window.location.href = "itms-services://?action=download-manifest&url=https://xxx-qq.oss-cn-shenzhen.aliyuncs.com/xxxx.plist";
            } else {
                $("#xrBox").hide();
            }
        }
    </script>

```

