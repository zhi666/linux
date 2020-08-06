[toc]

# 创建centos镜像支持ssh连接

### 一，方法一

先建一个目录和创建一个Dockerfile文件

```
mkdir /root/tuisong/centos7_systemd
cd /root/tuisong/centos7_systemd

vim Dockerfile
FROM centos:7
# 使用阿里云仓库，启用systemd，启用service，加入中文支持。
ENV container="docker" LC_ALL="zh_CN.UTF-8"
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
    systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*; \
    rm -f /etc/systemd/system/*.wants/*; \
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*; \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo; \
    curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo; \
    yum makecache; \
    yum -y install kde-l10n-Chinese gcc nc initscripts; \
    yum -y reinstall glibc-common; \
    localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8; \
    echo 'LANG="zh_CN.UTF-8"' > /etc/locale.conf; \
    yum clean all; \
    rm -rf /var/cache/yum/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]


```

***获取镜像***

创建一个tuisong.yaml文件

```
cd /root/tuisong/
vim tuisong.yaml

version: "3.7"
services:
  centos:
    build: ./centos7_systemd
    container_name: master
    hostname: Docker推送
    restart: always
    tty: true
    privileged: true
    working_dir: /root
    ports:
      - "2222:22"
      - "10060:10060"

```

***首先安装docker-compose***

 yum -y install python-pip

   pip install docker-compose

docker-compose -f tuisong.yaml up -d --build

然后进入容器安装sshd

docker exec -it master bash

```
yum install lrzsz vim -y
yum install openssh-server  -y
systemctl enable sshd && systemctl start sshd

```

然后设置密码 

```
[root@Docker ~]# passwd
输入两次 123 回车
就可以了，然后就可以通过2222端口进入容器了


```





### 二，方法二

 这个copy 或者add是只复制目录下内容的 不复制目录本身 还有很多用法直接google查就好 1 代表Dockerfile目录下的文件或目录名 .代表workdir 也可以写想要复制到容器的哪个位置绝对路径
Dockerfile文件内容为 

```
mkdir /Dockerfile  cd /Dockerfile
echo "1123" > 1    
vim Dockerfile

```

 等于把1这个文件拷贝到容器的工作目录APP这个目录里，

以下是内容文件内容

```
FROM  centos:7
WORKDIR /APP
RUN   yum -y install openssh-server vim lsof ansible \
      && echo "123456" |  passwd --stdin root
RUN rm -rf /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime #修改时区
RUN yum -y install kde-l10n-Chinese && yum -y reinstall glibc-common #安装中文支持
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 #配置显示中文
ENV LC_ALL zh_CN.utf8 #设置环境变量
RUN yum -y install python-setuptools && easy_install pip && pip install supervisor #安装supervisor多进程管理工具，用于启动多进程
COPY  1  .
EXPOSE 22

```

 在Dockerfile目录运行 获取镜像root密码为123456   centos:luke为镜像名


```
docker build -t centos7:luke .     

```

运行镜像 

```
docker run -itd --name centos-test --privileged  --restart=always -p 2222:22 centos7:luke init
```

然后就可以直接连接2222端口进入容器了



解决docker容器中Centos7系统的中文乱码问题有如下两种方案：

第一种只能临时解决中文乱码：

​    在命令行中执行如下命令：

\# localedef -i zh_CN -f UTF-8 zh_CN.UTF-8

\# yum -y install kde-l10n-Chinese && yum -y reinstall glibc-common

\# localedef -c -f UTF-8 -i zh_CN zh_CN.utf8

\# export LC_ALL=zh_CN.utf8
第二种需要修改生成镜像的配置文件：

​    在Dockerfile中添加一行，如下所示：

​        ENV LANG C.UTF-8

​    重新打包制作docker镜像，重新进入容器后发现问题解决！

### 方法三

```
1.启动容器
docker run  -itd --name centos7_6 --privileged --restart=always -p 2222:22  centos /usr/sbin/init
进入容器
docker exec -it centos7_6   /bin/bash

2.安装sshd
yum install -y openssh-server openssh-clients
systemctl enable sshd
systemctl start sshd

mkdir /var/run/sshd

3.修改sshd_config配置文件 dns打开
echo 'UseDNS no' >> etc/ssh/sshd_config

sed -i -e '/pam_loginuid.so/d' /etc/pam.d/sshd 

echo 'root:123456' |chpasswd
/usr/bin/ssh-keygen -A

现在可以通过xshell 2222端口连接了。

4.或者可以创建新镜像。以后可以用。
docker commit -m="支持sshd" -a="luke" centos7_6 centosxin

运行新的
docker run  -itd --name centosxin1 --privileged --restart=always  -p 3333:22 centosxin /usr/sbin/sshd -D 

```

