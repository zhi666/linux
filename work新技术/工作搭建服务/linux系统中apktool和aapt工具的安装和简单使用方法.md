 linux系统中apktool和aapt工具的安装和简单使用方法 

**下载安装apktool和aapt工具**

新建`/usr/local/apktool`文件夹

```
mkdir /usr/local/apktool && cd /usr/local/apktool/
```



apktool和aapt各种版本可以到如下地址下载，以下以apktool 2.2.2为例

```
http://connortumbleson.com/apktool/
```



 下载 apktool 

```

# wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
```

 下载apktool，重命名为`apktool.jar` 

```

# wget http://connortumbleson.com/apktool/apktool_2.2.2.jar
# mv apktool_2.2.2.jar apktool.jar
```

 下载 aapt 

```
下载一: wget  https://connortumbleson.com/apktool/aapts/linux/aapt

下载二:  wget https://dl.androidaapt.com/aapt-linux.zip
unzip aapt-linux.zip   #解压aapt
```

 赋予 apktool，apktool.jar和aapt可执行权限 

```
# chmod +x apktool apktool.jar aapt

```

 将apktool加入环境变量，修改`/etc/profile`,添加如下内容 

```
export PATH="$PATH:/usr/local/apktool/"
```

 使用`aapt`工具时可能报如下错误 

```
aapt: /lib64/libc.so.6: version `GLIBC_2.14' not found (required by aapt)
```



缺少glibc-2.14，安装一下就好了

```
# wget http://ftp.gnu.org/gnu/glibc/glibc-2.14.tar.gz
# tar zxvf glibc-2.14.tar.gz
# cd glibc-2.14 
# mkdir build
# cd build
# ../configure --prefix=/opt/glibc-2.14
# make -j4
# make install
```

**解决方法**
切换到`/usr/local/apktool`

```
cd /usr/local/apktool
```

首先将aapt重命名为`aapt_`

```
mv aapt aapt_
```

再新建一个脚本aapt使用`glibc 2.14`环境变量

```
vim aapt
```

写入以下内容

```
#!/bin/sh
echo "$0"_$@
export LD_LIBRARY_PATH=/opt/glibc-2.14/lib && "$0"_ $@
```

然后给aapt相应的权限

```
chmod 755 aapt
```

**apktool和aapt简单使用方法**

```
# apktool d /data/test.apk //反编译apk
# aapt dump badging /data/test.apk //查看apk包详细信息
```