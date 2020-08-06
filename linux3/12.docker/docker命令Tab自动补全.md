docker疑难杂症：docker命令Tab无法自动补全

```
yum install -y yum-utils device-mapper-persistent-data lvm2

yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install  -y  docker-ce docker-ce-cli containerd.io
systemctl restart docker && systemctl enable docker
```





一、安装bash-complete

```
yum install -y bash-completion
```



二、刷新文件

```
source /usr/share/bash-completion/completions/docker
source /usr/share/bash-completion/bash_completion
```





