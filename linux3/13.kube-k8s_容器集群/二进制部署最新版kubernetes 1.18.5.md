[toc]
# 1.组件版本 && 集群环境
## 组件版本
- Kubernetes 1.18.5
- Docker 19.03.2-ce
- Etcd 3.2.9
- Flanneld
- TLS认证通信（所有组件，如etcd、kubernetes master 和node）
- RBAC授权
- kubernetes TLS Bootstrapping
- kubedns dashboard heapster等插件
- harbor,使用nfs后端存储

## etcd集群 && k8s master机器 && k8s node机器

- master01  172.17.46.196
- master02 172.17.46.11
- master03 172.17.46.14
- 由于资源分配原因先只用一个node 再加入操作也是一样的
- node01 192.168.1.161 



## 集群环境变量

后面部署将会使用到的全局变量，定义如下（根据自己的机器、网络修改）：

```bash
# TLS Bootstrapping 使用的Token，可以使用命令 head -c 16 /dev/urandom | od -An -t x | tr -d ' ' 生成
BOOTSTRAP_TOKEN="3d0d48c67642f537704ffe559c1c7b3a"

# 建议使用未用的网段来定义服务网段和Pod 网段
# 服务网段(Service CIDR)，部署前路由不可达，部署后集群内部使用IP:Port可达
SERVICE_CIDR="10.254.0.0/16"

# Pod 网段(Cluster CIDR)，部署前路由不可达，部署后路由可达(flanneld 保证)
CLUSTER_CIDR="172.30.0.0/16"

# 服务端口范围(NodePort Range)
NODE_PORT_RANGE="10000-32666"

# etcd集群服务地址列表
ETCD_ENDPOINTS="https://172.17.46.196:2379,https://172.17.46.11:2379,https://172.17.46.14:2379"

# flanneld 网络配置前缀
FLANNEL_ETCD_PREFIX="/kubernetes/network"

# kubernetes 服务IP(预先分配，一般为SERVICE_CIDR中的第一个IP)
CLUSTER_KUBERNETES_SVC_IP="10.254.0.1"

# 集群 DNS 服务IP(从SERVICE_CIDR 中预先分配)
CLUSTER_DNS_SVC_IP="10.254.0.2"

#集群 DNS 域名
CLUSTER_DNS_DOMAIN="cluster.local."

# MASTER API Server 地址
MASTER_URL="k8s-api.virtual.local"

```

将上面变量保存为: **env.sh**，然后将脚本拷贝到所有机器的`/usr/k8s/bin`目录

为了方便后面迁移，我们在集群内定义一个域名用于访问apiserver,在每个节点的/etc/hosts文件中 添加记录：**172.17.46.196 k8s-api.virtual.local k8s-api**

其中`172.17.46.196`为master01的ip,暂时使用该ip来做apiserver的负载地址

> 如果你使用的是阿里云的ECS 服务，强烈建议你先将上述节点的安全组配置成允许所有访问，不然在安装过程中会遇到各种访问不了的问题，待集群配置成功以后再根据需要添加安全限制。

# 2.创建CA证书和密钥

`kubernetes`系统各个组件需要使用`TLS`证书对通信进行加密，这里我们使用`CloundFlare`的PKI工具集[cfssl](https://github.com/cloudflare/cfssl)来生成Certficate Authority(CA)证书和密钥文件，CA是自签名证书，用来签名后续创建的其他TLS证书。

## 安装 CFSSL

> 在一台master操作即可 签发证书后分发到需要的机器上，切记不要搞一堆ca签证书
```bash
[root@localhost ~]# yum -y install wget
[root@localhost ~]# wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
[root@localhost ~]# chmod +x cfssl_linux-amd64
[root@localhost ~]#  mv cfssl_linux-amd64 /usr/k8s/bin/cfssl
[root@localhost ~]# wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
[root@localhost ~]# chmod +x cfssljson_linux-amd64
[root@localhost ~]#  mv cfssljson_linux-amd64 /usr/k8s/bin/cfssljson
[root@localhost ~]#  wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
[root@localhost ~]# chmod +x cfssl-certinfo_linux-amd64
[root@localhost ~]# mv cfssl-certinfo_linux-amd64 /usr/k8s/bin/cfssl-certinfo
[root@localhost ~]# export PATH=/usr/k8s/bin:$PATH
[root@localhost ~]# echo "export PATH=/usr/k8s/bin:$PATH" >> /etc/profile
[root@localhost ~]# . /etc/profile
[root@localhost ~]# mkdir ssl && cd ssl
[root@localhost ssl]# cfssl print-defaults config > config.json
[root@localhost ssl]# cfssl print-defaults csr > csr.json

```

为了方便，将`/usr/k8s/bin`设置成了环境变量

## 创建CA

修改上面创建的config.json 文件为ca-config.json:

```bash
[root@localhost ssl]# mv config.json ca-config.json

[root@localhost ssl]# cat ca-config.json
{
    "signing": {
        "default": {
            "expiry": "87600h"
        },
        "profiles": {
            "kubernetes": {
                "expiry": "87600h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
}

```

- `config.json`: 可以定义多个profiles，分别指定不通的过期时间、使用场景等参数;后续在签名证书时使用某个profile；
- `signing`: 表示该证书可用于签名其他证书，生成的ca.pem证书`CA=TRUE`；
- `server auth`: 表示client可以用该CA对server提供的证书进行校验；
- `client auth`:表示server可以用该CA对client提供的证书进行验证。

修改CA证书签名请求为`ca-csr.json`:

```bash
[root@localhost ssl]# mv csr.json ca-csr.json
[root@localhost ssl]# cat ca-csr.json
{
    "CN": "kubernetes",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "BeiJing",
            "ST": "BeiJing",
            "O": "k8s",
            "OU": "System"
        }
    ]
}

```

- CN: Common Name, **kube-apiserver**从证书中提取该字段作为请求的用户名；浏览器使用该字段验证网站是否合法；
- O：Organization，**kube-apiserver**从证书中提取该字段作为请求用户所属的组；

生成CA证书和私钥：

```bash
[root@localhost ssl]# cfssl gencert -initca ca-csr.json | cfssljson -bare ca
[root@localhost ssl]# ls ca*
ca-config.json  ca.csr  ca-csr.json  ca-key.pem  ca.pem

```

## 分发证书

将生成的CA证书、密钥文件、配置文件拷贝到**所有机器的**`/etc/kubernetes/ssl/`目录下面:

```bash
[root@localhost ssl]# mkdir -p /etc/kubernetes/ssl
[root@localhost ssl]# cp ca* /etc/kubernetes/ssl
[root@localhost ~]# scp /etc/kubernetes/ssl/* root@172.17.46.11:/etc/kubernetes/ssl/
```

# 3.部署高可用etcd集群

**kubernetes**系统使用`etcd`存储所有的数据，我们这里部署三个节点的etcd集群，这三个节点直接复用kubernetes master的三个节点，分别命名为etcd01、etcd02、etcd03:

- etcd01: 172.17.46.196
- etcd02: 172.17.46.11
- etcd03 172.17.46.14

## 定义环境变量

使用到的变量如下：

> 追加到/usr/k8s/bin/env.sh 并分发到所有节点 稍作修改

追加部分的内容为：

```bash
NODE_NAME=etcd01
NODE_IP=172.17.46.196
NODE_IPS="172.17.46.196 172.17.46.11 172.17.46.14"
ETCD_NODES=etcd01="https://172.17.46.196:2380,etcd02=https://172.17.46.11:2380,etcd03=https://172.17.46.14:2380"
```

```bash
[root@master01 ~]# source /usr/k8s/bin/env.sh 
```

## 下载etcd二进制文件

到https://github.com/coreos/etcd/releases页面下载最新二进制文件：

```bash
[root@master01 ~]#  wget https://github.com/coreos/etcd/releases/download/v3.4.9/etcd-v3.4.9-linux-amd64.tar.gz
[root@master01 ~]# tar xvf etcd-v3.4.9-linux-amd64.tar.gz 
[root@master01 ~]# rm -rf etcd-v3.4.9-linux-amd64.tar.gz
[root@master01 ~]# mv etcd-v3.4.9-linux-amd64/etcd* /usr/k8s/bin/
[root@master01 ~]# rm -rf etcd-v3.4.9-linux-amd64/

```

## 创建TLS密钥和证书

为了保证通信安全， 客户端(如etcdctl)与etcd集群之间的通信需要使用tls加密。

创建etcd证书签名请求：

```bash
[root@master01 ~]# cat > etcd-csr.json <<EOF
{
  "CN": "etcd",
  "hosts": [
    "127.0.0.1",
    "${NODE_IP}"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
```

- `host`字段指定授权使用该证书的`etcd`节点ip

生成`etcd`证书和私钥：

```bash
[root@master01 ~]# cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem \
>   -ca-key=/etc/kubernetes/ssl/ca-key.pem \
>   -config=/etc/kubernetes/ssl/ca-config.json \
>   -profile=kubernetes etcd-csr.json | cfssljson -bare etcd

[root@master01 ~]# ls etcd*
etcd.csr  etcd-csr.json  etcd-key.pem  etcd.pem
[root@master01 ~]# mkdir -p /etc/etcd/ssl
[root@master01 ~]# mv etcd*.pem /etc/etcd/ssl/
```

> 分发到所有master节点上

## 创建etcd的systemd unit文件

> 必须要先创建工作目录 并且改好各个master的环境变量

```bash
[root@master01 ~]# mkdir -p /var/lib/etcd

[root@master01 ~]#  cat > etcd.service <<EOF
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
ExecStart=/usr/k8s/bin/etcd \\
  --name=${NODE_NAME} \\
  --cert-file=/etc/etcd/ssl/etcd.pem \\
  --key-file=/etc/etcd/ssl/etcd-key.pem \\
  --peer-cert-file=/etc/etcd/ssl/etcd.pem \\
  --peer-key-file=/etc/etcd/ssl/etcd-key.pem \\
  --trusted-ca-file=/etc/kubernetes/ssl/ca.pem \\
  --peer-trusted-ca-file=/etc/kubernetes/ssl/ca.pem \\
  --initial-advertise-peer-urls=https://${NODE_IP}:2380 \\
  --listen-peer-urls=https://${NODE_IP}:2380 \\
  --listen-client-urls=https://${NODE_IP}:2379,http://127.0.0.1:2379 \\
  --advertise-client-urls=https://${NODE_IP}:2379 \\
  --initial-cluster-token=etcd-cluster-0 \\
  --initial-cluster=${ETCD_NODES} \\
  --initial-cluster-state=new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

```

- 指定`etcd`的工作目录和数据目录为`/var/lib/etcd`,需要在启动前创建这个目录；
- 为了保证通信安全，需要指定`etcd`的公私钥、peeres通信的公私钥 
- `--initial-cluster-state`值为`new`时，`--name`的参数值必须位于`--initial-cluster`列表中

## 启动etcd服务
> 三个master节点操作
```bash
[root@master01 ~]# mv etcd.service  /etc/systemd/system/
[root@master01 ~]# systemctl daemon-reload
[root@master01 ~]# systemctl enable etcd
[root@master01 ~]# systemctl start etcd
```

> 最先启动的etcd 进程会卡住一段时间，等待其他节点启动加入集群，在所有的etcd 节点重复上面的步骤，直到所有的机器etcd 服务都已经启动。

## 验证服务

部署完etcd 集群后，在任一etcd 节点上执行下面命令：

```bash
for ip in ${NODE_IPS}; do
  ETCDCTL_API=3 /usr/k8s/bin/etcdctl \
  --endpoints=https://${ip}:2379  \
  --cacert=/etc/kubernetes/ssl/ca.pem \
  --cert=/etc/etcd/ssl/etcd.pem \
  --key=/etc/etcd/ssl/etcd-key.pem \
  endpoint health; done
```

输出如下结果:

```bash
https://172.17.46.196:2379 is healthy: successfully committed proposal: took = 28.917692ms
https://172.17.46.11:2379 is healthy: successfully committed proposal: took = 12.262842ms
https://172.17.46.14:2379 is healthy: successfully committed proposal: took = 13.290885ms

```

可以看到上面的信息3个节点上的etcd 均为**healthy**，则表示集群服务正常。

# 4.配置kuberctl命令行工具

`kubectl`默认从`~/.kube/config`配置文件中获取访问kube-apiserver 地址、证书、用户名等信息，需要正确配置该文件才能正常使用`kubectl`命令。

需要将下载的kubectl 二进制文件和生产的`~/.kube/config`配置文件拷贝到需要使用kubectl 命令的机器上。

> 很多童鞋说这个地方不知道在哪个节点上执行，`kubectl`只是一个和`kube-apiserver`进行交互的一个命令行工具，所以你想安装到那个节点都行，master或者node任意节点都可以，比如你先在master节点上安装，这样你就可以在master节点使用`kubectl`命令行工具了，如果你想在node节点上使用(当然安装的过程肯定会用到的)，你就把master上面的`kubectl`二进制文件和`~/.kube/config`文件拷贝到对应的node节点上就行了。

## 环境变量

> `/usr/k8s/bin/env.sh`追加新内容

```bash
KUBE_APISERVER="https://${MASTER_URL}:6443
```

> 注意这里的`KUBE_APISERVER`地址，因为我们还没有安装`haproxy`，所以暂时需要手动指定使用`apiserver`的6443端口，等`haproxy`安装完成后就可以用使用443端口转发到6443端口去了。

- 变量KUBE_APISERVER 指定kubelet 访问的kube-apiserver 的地址，后续被写入`~/.kube/config`配置文件

 ## 下载kubectl

```bash
[root@master01 ~]# wget https://dl.k8s.io/v1.18.5/kubernetes-client-linux-amd64.tar.gz
[root@master01 ~]# tar -xzvf kubernetes-client-linux-amd64.tar.gz
[root@master01 ~]# cp kubernetes/client/bin/kube* /usr/k8s/bin/
[root@master01 ~]# chmod a+x /usr/k8s/bin/kube*
[root@master01 ~]# rm -rf kubernetes kubernetes-client-linux-amd64.tar.gz 

```

## 创建admin证书

**kubectl** 与**kube-apiserver**的安全端口通信，需要为安全通信提供TLS 证书和密钥。创建admin 证书签名请求：

```bash
[root@master01 ~]# cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "system:masters",
      "OU": "System"
    }
  ]
}
EOF
```

- 后续`kube-apiserver`使用RBAC 对客户端(如kubelet、kube-proxy、Pod)请求进行授权
- `kube-apiserver` 预定义了一些RBAC 使用的RoleBindings，如cluster-admin 将Group `system:masters`与Role `cluster-admin`绑定，该Role 授予了调用`kube-apiserver`所有API 的权限
- O 指定了该证书的Group 为`system:masters`，kubectl使用该证书访问`kube-apiserver`时，由于证书被CA 签名，所以认证通过，同时由于证书用户组为经过预授权的`system:masters`，所以被授予访问所有API 的权限
- hosts 属性值为空列表

生成admin证书和私钥：

```bash
[root@master01 ~]#  cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem \
>   -ca-key=/etc/kubernetes/ssl/ca-key.pem \
>   -config=/etc/kubernetes/ssl/ca-config.json \
>   -profile=kubernetes admin-csr.json | cfssljson -bare admin

[root@master01 ~]# ls admin*
admin.csr  admin-csr.json  admin-key.pem  admin.pem
[root@master01 ~]# mv admin*.pem /etc/kubernetes/ssl/
```

> 记得分发证书

## 创建kubectl kubeconfig文件

```bash
# 设置集群参数
$ kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER}
  # 设置客户端认证参数
$ kubectl config set-credentials admin \
  --client-certificate=/etc/kubernetes/ssl/admin.pem \
  --embed-certs=true \
  --client-key=/etc/kubernetes/ssl/admin-key.pem \
  --token=${BOOTSTRAP_TOKEN}
# 设置上下文参数
$ kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=admin
# 设置默认上下文
$ kubectl config use-context kubernete
```

- `admin.pem`证书O 字段值为`system:masters`，`kube-apiserver` 预定义的 RoleBinding `cluster-admin` 将 Group `system:masters` 与 Role `cluster-admin` 绑定，该 Role 授予了调用`kube-apiserver` 相关 API 的权限
- 生成的kubeconfig 被保存到 `~/.kube/config` 文件

## 分发kubeconfig文件

将`~/.kube/config`文件拷贝到运行`kubectl`命令的机器的`~/.kube/`目录下去。



# 5.部署Flannel网络

kubernetes 要求集群内各节点能通过Pod 网段互联互通，下面我们来使用Flannel 在所有节点上创建互联互通的Pod 网段的步骤。

> Node节点也要安装。

## 环境变量

```bash
 NODE_IP=172.17.46.13  # 当前部署节点的IP
 source /usr/k8s/bin/env.sh
```

## 创建TLS密钥和证书

etcd 集群启用了双向TLS 认证，所以需要为flanneld 指定与etcd 集群通信的CA 和密钥。

创建flanneld 证书签名请求：

```bash
cat > flanneld-csr.json <<EOF
{
  "CN": "flanneld",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
```

生成flanneld 证书和私钥：

```bash
cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem   -ca-key=/etc/kubernetes/ssl/ca-key.pem   -config=/etc/kubernetes/ssl/ca-config.json   -profile=kubernetes flanneld-csr.json | cfssljson -bare flanneld


[root@master01 ~]# ls flanneld*
flanneld.csr  flanneld-csr.json  flanneld-key.pem  flanneld.pem

[root@master01 ~]# mkdir -p /etc/flanneld/ssl
[root@master01 ~]# mv flanneld*.pem /etc/flanneld/ssl/

[root@master01 ~]# etcdctl   --endpoints=${ETCD_ENDPOINTS}   --cacert=/etc/kubernetes/ssl/ca.pem   --cert=/etc/flanneld/ssl/flanneld.pem   --key=/etc/flanneld/ssl/flanneld-key.pem   put ${FLANNEL_ETCD_PREFIX}/config '{"Network":"'${CLUSTER_CIDR}'", "SubnetLen": 24, "Backend": {"Type": "vxlan"}}'

OK

```

## 安装和配置flanneld

前往[flanneld release](https://github.com/coreos/flannel/releases)页面下载最新版的flanneld 二进制文件：

```bash
[root@node01 ~]# mkdir flannel
[root@node01 ~]# cd flannel/
[root@master01 flannel]# wget https://github.com/coreos/flannel/releases/download/v0.12.0/flannel-v0.12.0-linux-amd64.tar.gz
[root@node01 flannel]# tar zxf flannel-v0.12.0-linux-amd64.tar.gz 
[root@node01 flannel]# cp {flanneld,mk-docker-opts.sh} /usr/k8s/bin
[root@node01 flannel]# rm -rf ./*


```

创建flanneld的systemd unit 文件

```bash
cat > flanneld.service << EOF
[Unit]
Description=Flanneld overlay address etcd agent
After=network.target
After=network-online.target
Wants=network-online.target
After=etcd.service
Before=docker.service

[Service]
Type=notify
ExecStart=/usr/k8s/bin/flanneld \\
  -etcd-cafile=/etc/kubernetes/ssl/ca.pem \\
  -etcd-certfile=/etc/flanneld/ssl/flanneld.pem \\
  -etcd-keyfile=/etc/flanneld/ssl/flanneld-key.pem \\
  -etcd-endpoints=${ETCD_ENDPOINTS} \\
  -etcd-prefix=${FLANNEL_ETCD_PREFIX}
ExecStartPost=/usr/k8s/bin/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/docker
Restart=on-failure

[Install]
WantedBy=multi-user.target
RequiredBy=docker.service
EOF



[root@node01 flannel]# mv flanneld.service  /etc/systemd/system
[root@node01 flannel]# systemctl daemon-reload 
[root@node01 flannel]# systemctl enable flanneld
[root@node01 flannel]# systemctl start flanneld

```

- `mk-docker-opts.sh`脚本将分配给flanneld 的Pod 子网网段信息写入到`/run/flannel/docker` 文件中，后续docker 启动时使用这个文件中的参数值为 docker0 网桥
- flanneld 使用系统缺省路由所在的接口和其他节点通信，对于有多个网络接口的机器(内网和公网)，可以用 `--iface` 选项值指定通信接口(上面的 systemd unit 文件没指定这个选项)





如果报这样的错误就是etcd 和flanneld版本不支持的结果，我这里遇到了要去换下etcd的版本

```bash
Couldn't fetch network config: client: response is invalid json. The endpoint is probably not valid etcd cluster endpoint.

[root@master01 ~]# wget https://github.com/coreos/etcd/releases/download/v3.2.9/etcd-v3.2.9-linux-amd64.tar.gz
所有master都需要操作，换一下执行文件就行
```



## 检查分配给各flanneld 的Pod 网段信息

```bash
# 查看集群 Pod 网段(/16)
[root@master01 flannel]#  etcdctl \
>   --endpoints=${ETCD_ENDPOINTS} \
>   --ca-file=/etc/kubernetes/ssl/ca.pem \
>   --cert-file=/etc/flanneld/ssl/flanneld.pem \
>   --key-file=/etc/flanneld/ssl/flanneld-key.pem \
>   get ${FLANNEL_ETCD_PREFIX}/config
{"Network":"172.30.0.0/16", "SubnetLen": 24, "Backend": {"Type": "vxlan"}}

 # 查看已分配的 Pod 子网段列表(/24)
 [root@master01 flannel]#  etcdctl \
>   --endpoints=${ETCD_ENDPOINTS} \
>   --ca-file=/etc/kubernetes/ssl/ca.pem \
>   --cert-file=/etc/flanneld/ssl/flanneld.pem \
>   --key-file=/etc/flanneld/ssl/flanneld-key.pem \
>   ls ${FLANNEL_ETCD_PREFIX}/subnets
/kubernetes/network/subnets/172.30.36.0-24
/kubernetes/network/subnets/172.30.91.0-24
/kubernetes/network/subnets/172.30.92.0-24
/kubernetes/network/subnets/172.30.90.0-24

# 查看某一 Pod 网段对应的 flanneld 进程监听的 IP 和网络参数
[root@master01 flannel]# etcdctl \
>   --endpoints=${ETCD_ENDPOINTS} \
>   --ca-file=/etc/kubernetes/ssl/ca.pem \
>   --cert-file=/etc/flanneld/ssl/flanneld.pem \
>   --key-file=/etc/flanneld/ssl/flanneld-key.pem \
>   get ${FLANNEL_ETCD_PREFIX}/subnets/172.30.90.0-24
{"PublicIP":"172.17.46.14","BackendType":"vxlan","BackendData":{"VtepMAC":"ba:67:54:38:c5:2d"}}

```

## 确保各节点间互通

在各个节点部署完Flanneld 后，查看已分配的Pod 子网段列表：
```bash
[root@master01 flannel]#  etcdctl \
>   --endpoints=${ETCD_ENDPOINTS} \
>   --ca-file=/etc/kubernetes/ssl/ca.pem \
>   --cert-file=/etc/flanneld/ssl/flanneld.pem \
>   --key-file=/etc/flanneld/ssl/flanneld-key.pem \
>   ls ${FLANNEL_ETCD_PREFIX}/subnets
/kubernetes/network/subnets/172.30.92.0-24
/kubernetes/network/subnets/172.30.90.0-24
/kubernetes/network/subnets/172.30.36.0-24
/kubernetes/network/subnets/172.30.91.0-24

```

当前四个节点分配的 Pod 网段分别是：172.30.92.0-24 172.30.90.0-24 172.30.36.0-24 172.30.91.0-24

# 6.部署master节点

kubernetes master 节点包含的组件有：

- kube-apiserver
- kube-scheduler
- kube-controller-manager

目前这3个组件需要部署到同一台机器上：（后面再部署高可用的master）

- `kube-scheduler`、`kube-controller-manager` 和 `kube-apiserver` 三者的功能紧密相关；
- 同时只能有一个 `kube-scheduler`、`kube-controller-manager` 进程处于工作状态，如果运行多个，则需要通过选举产生一个 leader；

master 节点与node 节点上的Pods 通过Pod 网络通信，所以需要在master 节点上部署Flannel 网络。

## 下载最新版本的二进制文件

在[kubernetes changelog](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.8.md#server-binaries) 页面下载最新版本的文件：

```bash
[root@master01 ~]# wget https://dl.k8s.io/v1.18.5/kubernetes-server-linux-amd64.tar.gz
[root@master01 ~]# tar zxf kubernetes-server-linux-amd64.tar.gz 
[root@master01 ~]# cd kubernetes/
[root@master01 kubernetes]# cp -r server/bin/{kube-apiserver,kube-controller-manager,kube-scheduler} /usr/k8s/bin/

```

## 创建kubernetes证书

创建kubernetes 证书签名请求：

```bash
[root@master01 ~]# cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "hosts": [
    "127.0.0.1",
    "${NODE_IP}",
    "${MASTER_URL}",
    "${CLUSTER_KUBERNETES_SVC_IP}",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
```

- 如果 hosts 字段不为空则需要指定授权使用该证书的 **IP 或域名列表**，所以上面分别指定了当前部署的 master 节点主机 IP 以及apiserver 负载的内部域名
- 还需要添加 kube-apiserver 注册的名为 `kubernetes` 的服务 IP (Service Cluster IP)，一般是 kube-apiserver `--service-cluster-ip-range` 选项值指定的网段的**第一个IP**，如 “10.254.0.1”

生成kubernetes 证书和私钥：

```bash
[root@master01 ~]# cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem   -ca-key=/etc/kubernetes/ssl/ca-key.pem   -config=/etc/kubernetes/ssl/ca-config.json   -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes

[root@master01 ~]# ls kubernetes*
kubernetes.csr  kubernetes-csr.json  kubernetes-key.pem  kubernetes.pem
[root@master01 ~]#  mkdir -p /etc/kubernetes/ssl/
[root@master01 ~]# mv kubernetes*.pem /etc/kubernetes/ssl/

```

## 6.1 配置和启动kube-apiserver

### 创建kube-apiserver 使用的客户端token 文件

kubelet 首次启动时向kube-apiserver 发送TLS Bootstrapping 请求，kube-apiserver 验证请求中的token 是否与它配置的token.csv 一致，如果一致则自动为kubelet 生成证书和密钥。

```bash
 # 导入的 environment.sh 文件定义了 BOOTSTRAP_TOKEN 变量
 [root@master01 ~]# cat > token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF

 [root@master01 ~]#  mv token.csv /etc/kubernetes/
```

### 创建kube-apiserver的systemd unit文件

```bash
cat  > kube-apiserver.service <<EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
ExecStart=/usr/k8s/bin/kube-apiserver \\
  --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --advertise-address=${NODE_IP} \\
  --bind-address=0.0.0.0 \\
  --insecure-bind-address=${NODE_IP} \\
  --authorization-mode=Node,RBAC \\
  --runtime-config=rbac.authorization.k8s.io/v1alpha1 \\
  --kubelet-https=true \\
  --experimental-bootstrap-token-auth \\
  --token-auth-file=/etc/kubernetes/token.csv \\
  --service-cluster-ip-range=${SERVICE_CIDR} \\
  --service-node-port-range=${NODE_PORT_RANGE} \\
  --tls-cert-file=/etc/kubernetes/ssl/kubernetes.pem \\
  --tls-private-key-file=/etc/kubernetes/ssl/kubernetes-key.pem \\
  --client-ca-file=/etc/kubernetes/ssl/ca.pem \\
  --service-account-key-file=/etc/kubernetes/ssl/ca-key.pem \\
  --etcd-cafile=/etc/kubernetes/ssl/ca.pem \\
  --etcd-certfile=/etc/kubernetes/ssl/kubernetes.pem \\
  --etcd-keyfile=/etc/kubernetes/ssl/kubernetes-key.pem \\
  --etcd-servers=${ETCD_ENDPOINTS} \\
  --enable-swagger-ui=true \\
  --allow-privileged=true \\
  --apiserver-count=2 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/lib/audit.log \\
  --audit-policy-file=/etc/kubernetes/audit-policy.yaml \\
  --event-ttl=1h \\
  --logtostderr=true \\
  --v=6
Restart=on-failure
RestartSec=5
Type=notify
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```

- 如果你安装的是**1.9.x**以上版本的，一定要记住上面的参数`experimental-bootstrap-token-auth`，需要替换成`enable-bootstrap-token-auth`，因为这个参数在**1.9.x**里面已经废弃掉了
- kube-apiserver 1.6 版本开始使用 etcd v3 API 和存储格式
- `--authorization-mode=RBAC` 指定在安全端口使用RBAC 授权模式，拒绝未通过授权的请求
- kube-scheduler、kube-controller-manager 一般和 kube-apiserver 部署在同一台机器上，它们使用**非安全端口**和 kube-apiserver通信
- kubelet、kube-proxy、kubectl 部署在其它 Node 节点上，如果通过**安全端口**访问 kube-apiserver，则必须先通过 TLS 证书认证，再通过 RBAC 授权
- kube-proxy、kubectl 通过使用证书里指定相关的 User、Group 来达到通过 RBAC 授权的目的
- 如果使用了 kubelet TLS Boostrap 机制，则不能再指定 `--kubelet-certificate-authority`、`--kubelet-client-certificate` 和 `--kubelet-client-key` 选项，否则后续 kube-apiserver 校验 kubelet 证书时出现 ”x509: certificate signed by unknown authority“ 错误
- `--admission-control` 值必须包含 `ServiceAccount`，否则部署集群插件时会失败
- `--bind-address` 不能为 `127.0.0.1`
- `--service-cluster-ip-range` 指定 Service Cluster IP 地址段，该地址段不能路由可达
- `--service-node-port-range=${NODE_PORT_RANGE}` 指定 NodePort 的端口范围
- 缺省情况下 kubernetes 对象保存在`etcd/registry` 路径下，可以通过 `--etcd-prefix` 参数进行调整
- kube-apiserver 1.8版本后需要在`--authorization-mode`参数中添加`Node`，即：`--authorization-mode=Node,RBAC`，否则Node 节点无法注册
- 注意要开启审查日志功能，指定`--audit-log-path`参数是不够的，这只是指定了日志的路径，还需要指定一个审查日志策略文件：`--audit-policy-file`，我们也可以使用日志收集工具收集相关的日志进行分析。

审查日志策略文件内容如下：（**/etc/kubernetes/audit-policy.yaml**）

审查日志的相关配置可以查看文档了解：https://kubernetes.io/docs/tasks/debug-application-cluster/audit/

### 启动kube-apiserver

```bash
[root@master01 ~]# mv kube-apiserver.service /etc/systemd/system
[root@master01 ~]# systemctl daemon-reload
[root@master01 ~]# systemctl enable kube-apiserver.service 

```

## 6.2 配置和启动kube-controller-manager

```bash
 [root@master01 ~]# cat > kube-controller-manager.service <<EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/k8s/bin/kube-controller-manager \\
  --address=127.0.0.1 \\
  --master=http://${MASTER_URL}:8080 \\
  --allocate-node-cidrs=true \\
  --service-cluster-ip-range=${SERVICE_CIDR} \\
  --cluster-cidr=${CLUSTER_CIDR} \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem \\
  --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem \\
  --service-account-private-key-file=/etc/kubernetes/ssl/ca-key.pem \\
  --root-ca-file=/etc/kubernetes/ssl/ca.pem \\
  --leader-elect=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

- `--address` 值必须为 `127.0.0.1`，因为当前 kube-apiserver 期望 scheduler 和 controller-manager 在同一台机器
- `--master=http://${MASTER_URL}:8080`：使用`http`(非安全端口)与 kube-apiserver 通信，需要下面的`haproxy`安装成功后才能去掉8080端口。
- `--cluster-cidr` 指定 Cluster 中 Pod 的 CIDR 范围，该网段在各 Node 间必须路由可达(flanneld保证)
- `--service-cluster-ip-range` 参数指定 Cluster 中 Service 的CIDR范围，该网络在各 Node 间必须路由不可达，必须和 kube-apiserver 中的参数一致
- `--cluster-signing-*` 指定的证书和私钥文件用来签名为 TLS BootStrap 创建的证书和私钥
- `--root-ca-file` 用来对 kube-apiserver 证书进行校验，**指定该参数后，才会在Pod 容器的 ServiceAccount 中放置该 CA 证书文件**
- `--leader-elect=true` 部署多台机器组成的 master 集群时选举产生一处于工作状态的 `kube-controller-manager` 进程

```bash
[root@master01 ~]# mv kube-controller-manager.service  /etc/systemd/system
[root@master01 ~]# systemctl daemon-reload 
[root@master01 ~]# systemctl enable kube-controller-manager.service 
[root@master01 ~]# systemctl start kube-controller-manager.service 

```

## 6.3 配置和启动kube-scheduler

```bash
[root@master01 ~]# cat > kube-scheduler.service <<EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/k8s/bin/kube-scheduler \\
  --address=127.0.0.1 \\
  --master=http://${MASTER_URL}:8080 \\
  --leader-elect=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

```bash
[root@master01 ~]# mv kube-scheduler.service  /etc/systemd/system

```

- `--address` 值必须为 `127.0.0.1`，因为当前 kube-apiserver 期望 scheduler 和 controller-manager 在同一台机器
- `--master=http://${MASTER_URL}:8080`：使用`http`(非安全端口)与 kube-apiserver 通信，需要下面的`haproxy`启动成功后才能去掉8080端口
- `--leader-elect=true` 部署多台机器组成的 master 集群时选举产生一处于工作状态的 `kube-controller-manager` 进程

```bash
[root@master01 ~]# systemctl daemon-reload  
[root@master01 ~]# systemctl enable kube-scheduler.service 
[root@master01 ~]# systemctl start kube-scheduler.service 
```

## 6.4 验证master节点

```bash
[root@master01 ~]# kubectl get componentstatuses
NAME                 STATUS    MESSAGE              ERROR
scheduler            Healthy   ok                   
controller-manager   Healthy   ok                   
etcd-1               Healthy   {"health": "true"}   
etcd-2               Healthy   {"health": "true"}   
etcd-0               Healthy   {"health": "true"}  
```

> 用上面的方式在`master02 master03`机器上安装`kube-apiserver``kube-controller-manager`、`kube-scheduler`

# 7.kube-apiserver高可用

现在我们还是手动指定访问的6443和8080端口的，因为我们的域名`k8s-api.virtual.local`对应的`master01`节点直接通过http 和https 还不能访问，这里我们使用`haproxy` 来代替请求。

> 就是我们需要将http默认的80端口请求转发到`apiserver`的8080端口，将https默认的443端口请求转发到`apiserver`的6443端口，所以我们这里使用`haproxy`来做请求转发。

## 安装haproxy

```bash
[root@master01 ~]# yum install -y haproxy

```

## 配置haproxy

由于集群内部有的组件是通过非安全端口访问apiserver 的，有的是通过安全端口访问apiserver 的，所以我们要配置http 和https 两种代理方式，配置文件 `/etc/haproxy/haproxy.cfg`：

```bash
listen stats
  bind    *:9000
  mode    http
  stats   enable
  stats   hide-version
  stats   uri       /stats
  stats   refresh   30s
  stats   realm     Haproxy\ Statistics
  stats   auth      Admin:Password

frontend k8s-api
    bind 172.17.46.196:443
    mode tcp
    option tcplog
    tcp-request inspect-delay 5s
    tcp-request content accept if { req.ssl_hello_type 1 }
    default_backend k8s-api

backend k8s-api
    mode tcp
    option tcplog
    option tcp-check
    balance roundrobin
    default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
    server k8s-api-1 172.17.46.11:6443 check
    server k8s-api-2 172.17.46.14:6443 check
    server k8s-api-3 172.17.46.196:6443 check
frontend k8s-http-api
    bind 172.17.46.196:80
    mode tcp
    option tcplog
    default_backend k8s-http-api

backend k8s-http-api
    mode tcp
    option tcplog
    option tcp-check
    balance roundrobin
    default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
    server k8s-http-api-1 172.17.46.11:8080 check
    server k8s-http-api-2 172.17.46.14:8080 check
    server k8s-http-api-2 172.17.46.196:8080 check

   
```

通过上面的配置文件我们可以看出通过`https`的访问将请求转发给apiserver 的6443端口了，http的请求转发到了apiserver 的8080端口。

## 启动haproxy

```bash
[root@master01 ~]# systemctl enable haproxy
[root@master01 ~]# systemctl start haproxy

```

然后我们可以通过上面`9000`端口监控我们的`haproxy`的运行状态`(172.17.46.196:9000/stats`):

## 问题

上面我们的`haproxy`的确可以代理我们的master 上的apiserver 了，但是还不是高可用的，如果master01 这个节点down 掉了，那么我们haproxy 就不能正常提供服务了。这里我们可以使用两种方法来实现高可用

### 方式1：使用阿里云SLB

这种方式实际上是最省心的，在阿里云上建一个内网的SLB，将master01 与master02 添加到SLB 机器组中，转发80(http)和443(https)端口即可（注意下面的提示）

> 注意：阿里云的负载均衡是四层TCP负责，不支持后端ECS实例既作为Real Server又作为客户端向所在的负载均衡实例发送请求。因为返回的数据包只在云服务器内部转发，不经过负载均衡，所以在后端ECS实例上去访问负载均衡的服务地址是不通的。什么意思？就是如果你要使用阿里云的SLB的话，那么你不能在`apiserver`节点上使用SLB（比如在apiserver 上安装kubectl，然后将apiserver的地址设置为SLB的负载地址使用），因为这样的话就可能造成回环了，所以简单的做法是另外用两个新的节点做`HA`实例，然后将这两个实例添加到`SLB` 机器组中。

### 方式2：使用keepalived

`KeepAlived` 是一个高可用方案，通过 VIP（即虚拟 IP）和心跳检测来实现高可用。其原理是存在一组（两台）服务器，分别赋予 Master、Backup 两个角色，默认情况下Master 会绑定VIP 到自己的网卡上，对外提供服务。Master、Backup 会在一定的时间间隔向对方发送心跳数据包来检测对方的状态，这个时间间隔一般为 2 秒钟，如果Backup 发现Master 宕机，那么Backup 会发送ARP 包到网关，把VIP 绑定到自己的网卡，此时Backup 对外提供服务，实现自动化的故障转移，当Master 恢复的时候会重新接管服务。非常类似于路由器中的虚拟路由器冗余协议（VRRP）

开启路由转发，这里我们定义虚拟IP为：**172.17.46.253**

```bash
[root@master01 ~]# vim /etc/sysctl.conf
# 添加以下内容
net.ipv4.ip_forward = 1
net.ipv4.ip_nonlocal_bind = 1

# 验证并生效
[root@master01 ~]#  sysctl -p
```

安装`keepalived`:

```bash
[root@master01 ~]# vim /etc/keepalived/keepalived.conf 

```

我们这里将master01 设置为Master，master02 03 设置为Backup，修改配置：

```bash
! Configuration File for keepalived

global_defs {
   notification_email {
   }
   router_id kube_api1
}

vrrp_script check_haproxy {
    # 自身状态检测
    script "killall -0 haproxy"
    interval 3
    weight 5
    weight -20
}

vrrp_instance haproxy-vip {
    # 使用单播通信，默认是组播通信
    unicast_src_ip 172.17.46.196
    unicast_peer {
        172.17.46.14
        172.17.46.11
    }
    # 初始化状态
    state MASTER
    # 虚拟ip 绑定的网卡 （这里根据你自己的实际情况选择网卡）
    interface ens33
    # 此ID 要与Backup 配置一致
    virtual_router_id 51
    # 默认启动优先级，要比Backup 大点，但要控制量，保证自身状态检测生效
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        # 虚拟ip 地址
        172.17.46.253
    }
    track_script {
        check_haproxy
    }
}

virtual_server 172.17.46.253 80 {
  delay_loop 5
  lvs_sched wlc
  lvs_method NAT
  persistence_timeout 1800
  protocol TCP

  real_server 172.17.46.196 80 {
    weight 1
    TCP_CHECK {
      connect_port 80
      connect_timeout 3
    }
  }
  real_server 172.17.46.14 80 {
    weight 1
    TCP_CHECK {
      connect_port 80
      connect_timeout 3
    }
  }
  real_server 172.17.46.11 80 {
    weight 1
    TCP_CHECK {
      connect_port 80
      connect_timeout 3
    }
  }

}

virtual_server 172.17.46.253 443 {
  delay_loop 5
  lvs_sched wlc
  lvs_method NAT
  persistence_timeout 1800
  protocol TCP

  real_server 172.17.46.196 443 {
    weight 1
    TCP_CHECK {
      connect_port 443
      connect_timeout 3
    }
  }
  real_server 172.17.46.11 443 {
    weight 1
    TCP_CHECK {
      connect_port 443
      connect_timeout 3
    }
  }
  real_server 172.17.46.14 443 {
    weight 1
    TCP_CHECK {
      connect_port 443
      connect_timeout 3
    }
  }

}
           
```

统一的方式在master02 03 节点上安装keepalived，修改配置，只需要将state 更改成BACKUP，priority更改成99，unicast_src_ip 与unicast_peer 地址修改即可。这里就不做演示了

> keepalived 弄完之后 我们就可以将上面的6443端口和8080端口去掉了，可以手动将`kubectl`生成的`config`文件(`~/.kube/config`)中的server 地址6443端口去掉，另外`kube-controller-manager`和`kube-scheduler`的**–master**参数中的8080端口去掉了，然后分别重启这两个组件即可。

验证apiserver：关闭master01 节点上的kube-apiserver 进程，然后查看虚拟ip是否漂移到了master02 节点。

验证虚拟ip

```bash
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:0c:29:d8:45:86 brd ff:ff:ff:ff:ff:ff
    inet 172.17.46.196/24 brd 172.17.46.255 scope global dynamic ens33
       valid_lft 1252sec preferred_lft 1252sec
    inet 172.17.46.253/32 scope global ens33

```



然后我们就可以将第一步在`/etc/hosts`里面设置的域名对应的IP 更改为我们的虚拟IP了

> master01 与master 02  03节点都需要安装keepalived 和haproxy，实际上我们虚拟IP的自身检测是检测haproxy，脚本大家可以自行更改



这样我们就实现了接入层apiserver 的高可用了，一个部分是多活的apiserver 服务，另一个部分是一主一备的haproxy 服务。

## kube-controller-manager 和kube-scheduler 的高可用

Kubernetes 的管理层服务包括`kube-scheduler`和`kube-controller-manager`。kube-scheduler和kube-controller-manager使用一主多从的高可用方案，在**同一时刻只允许一个服务**处以具体的任务。Kubernetes中实现了一套简单的选主逻辑，依赖Etcd实现scheduler和controller-manager的选主功能。如果scheduler和controller-manager在启动的时候设置了`leader-elect`参数，它们在启动后会先尝试获取leader节点身份，只有在获取leader节点身份后才可以执行具体的业务逻辑。它们分别会在Etcd中创建kube-scheduler和kube-controller-manager的endpoint，endpoint的信息中记录了当前的leader节点信息，以及记录的上次更新时间。leader节点会定期更新endpoint的信息，维护自己的leader身份。每个从节点的服务都会定期检查endpoint的信息，如果endpoint的信息在时间范围内没有更新，它们会尝试更新自己为leader节点。scheduler服务以及controller-manager服务之间不会进行通信，利用Etcd的强一致性，能够保证在分布式高并发情况下leader节点的全局唯一性.



当集群中的leader节点服务异常后，其它节点的服务会尝试更新自身为leader节点，当有多个节点同时更新endpoint时，由Etcd保证只有一个服务的更新请求能够成功。通过这种机制sheduler和controller-manager可以保证在leader节点宕机后其它的节点可以顺利选主，保证服务故障后快速恢复。当集群中的网络出现故障时对服务的选主影响不是很大，因为scheduler和controller-manager是依赖Etcd进行选主的，在网络故障后，可以和Etcd通信的主机依然可以按照之前的逻辑进行选主，就算集群被切分，Etcd也可以保证同一时刻只有一个节点的服务处于leader状态。



# 8. 部署node节点

kubernetes Node 节点包含如下组件：

- flanneld
- docker
- kubelet
- kube-proxy

## 环境变量

```shell
[root@node01 ~]# source /usr/k8s/bin/env.sh
[root@node01 ~]# export KUBE_APISERVER="https://${MASTER_URL}"  // 如果你没有安装`haproxy`的话，还是需要使用6443端口的
[root@node01 ~]# export NODE_IP=172.17.46.13# 当前部署的节点 IP
```

## 开启路由转发

修改`/etc/sysctl.conf`文件，添加下面的规则：

```bash
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
```

执行下面的命令立即生效：

```bash
[root@node01 ~]#  sysctl -p

```

## 配置docker

你可以用二进制或yum install 的方式来安装docker，然后修改docker 的systemd unit 文件：

```bash
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
EnvironmentFile=-/run/flannel/docker
ExecStart=/usr/bin/dockerd --log-level=info $DOCKER_NETWORK_OPTIONS
ExecReload=/bin/kill -s HUP $MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
```

- dockerd 运行时会调用其它 docker 命令，如 docker-proxy，所以需要将 docker 命令所在的目录加到 PATH 环境变量中
- flanneld 启动时将网络配置写入到 `/run/flannel/docker` 文件中的变量 `DOCKER_NETWORK_OPTIONS`，dockerd 命令行上指定该变量值来设置 docker0 网桥参数
- 如果指定了多个 `EnvironmentFile` 选项，则必须将 `/run/flannel/docker` 放在最后(确保 docker0 使用 flanneld 生成的 bip 参数)
- 不能关闭默认开启的 `--iptables` 和 `--ip-masq` 选项
- 如果内核版本比较新，建议使用 `overlay` 存储驱动
- docker 从 1.13 版本开始，可能将 **iptables FORWARD chain的默认策略设置为DROP**，从而导致 ping 其它 Node 上的 Pod IP 失败，遇到这种情况时，需要手动设置策略为 `ACCEPT`：

```bash
[root@node01 ~]# vim /etc/docker/daemon.json 
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}

```

## 启动docker

```bash
[root@node01 ~]# systemctl enable docker
[root@node01 ~]# systemctl restart docker

```

- 需要关闭 firewalld(centos7)/ufw(ubuntu16.04)，否则可能会重复创建 iptables 规则
- 最好清理旧的 iptables rules 和 chains 规则
- 执行命令：docker version，检查docker服务是否正常

## 安装和配置kubelet

kubelet 启动时向kube-apiserver 发送TLS bootstrapping 请求，需要先将bootstrap token 文件中的kubelet-bootstrap 用户赋予system:node-bootstrapper 角色，然后kubelet 才有权限创建认证请求(certificatesigningrequests)：

>  kubelet就是运行在Node节点上的，所以这一步安装是在所有的Node节点上，如果你想把你的Master也当做Node节点的话，当然也可以在Master节点上安装的。

```bash
[root@node01 ~]# kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --user=kubelet-bootstrap

```

- `--user=kubelet-bootstrap` 是文件 `/etc/kubernetes/token.csv` 中指定的用户名，同时也写入了文件 `/etc/kubernetes/bootstrap.kubeconfig`



然后下载最新的kubelet 和kube-proxy 二进制文件（前面下载kubernetes 目录下面其实也有）：

```bash
[root@node01 ~]#  wget https://dl.k8s.io/v1.18.5/kubernetes-server-linux-amd64.tar.gz
[root@node01 ~]# tar zxvf kubernetes-server-linux-amd64.tar.gz 
[root@node01 ~]# cd kubernetes
[root@node01 ~]# cp -r ./server/bin/{kube-proxy,kubelet} /usr/k8s/bin/

```

## 创建kubelet bootstapping kubeconfig 文件

```bash
 # 设置集群参数
 [root@node01 ~]# kubectl config set-cluster kubernetes \
>   --certificate-authority=/etc/kubernetes/ssl/ca.pem \
>   --embed-certs=true \
>   --server=${KUBE_APISERVER} \
>   --kubeconfig=bootstrap.kubeconfig
Cluster "kubernetes" set.

 # 设置客户端认证参数
[root@node01 ~]#  kubectl config set-credentials kubelet-bootstrap \
>   --token=${BOOTSTRAP_TOKEN} \
>   --kubeconfig=bootstrap.kubeconfig
User "kubelet-bootstrap" set.

# 设置上下文参数
 kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=bootstrap.kubeconfig
  Context "default" created.

# 设置默认上下文
[root@node01 ~]# kubectl config use-context default --kubeconfig=bootstrap.kubeconfig
Switched to context "default".

[root@node01 ~]#  mv bootstrap.kubeconfig /etc/kubernetes/

 
```

- `--embed-certs` 为 `true` 时表示将 `certificate-authority` 证书写入到生成的 `bootstrap.kubeconfig` 文件中；
- 设置 kubelet 客户端认证参数时**没有**指定秘钥和证书，后续由 `kube-apiserver` 自动生成；

## 创建kubelet 的systemd unit 文件

```bash
#必须先创建工作目录
[root@node01 ~]# mkdir /var/lib/kubele

[root@node01 ~]# cat > kubelet.service <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
WorkingDirectory=/var/lib/kubelet
ExecStart=/usr/k8s/bin/kubelet \\
  --fail-swap-on=false \\
  --cgroup-driver=cgroupfs \\
  --address=${NODE_IP} \\
  --hostname-override=${NODE_IP} \\
  --experimental-bootstrap-kubeconfig=/etc/kubernetes/bootstrap.kubeconfig \\
  --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \\
  --cert-dir=/etc/kubernetes/ssl \\
  --cluster-dns=${CLUSTER_DNS_SVC_IP} \\
  --cluster-domain=${CLUSTER_DNS_DOMAIN} \\
  --hairpin-mode promiscuous-bridge \\
  --serialize-image-pulls=false \\
  --logtostderr=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

**请仔细阅读下面的注意事项，不然可能会启动失败**。

- `--fail-swap-on`参数，这个一定要注意，**Kubernetes 1.8开始要求关闭系统的Swap**，如果不关闭，默认配置下kubelet将无法启动，也可以通过kubelet的启动参数`–fail-swap-on=false`来避免该问题
- `--cgroup-driver`参数，kubelet 用来维护主机的的 cgroups 的，默认是`cgroupfs`，但是这个地方的值需要你根据docker 的配置来确定（`docker info |grep cgroup`）
- `-address` 不能设置为 `127.0.0.1`，否则后续 Pods 访问 kubelet 的 API 接口时会失败，因为 Pods 访问的 `127.0.0.1`指向自己而不是 kubelet
- 如果设置了 `--hostname-override` 选项，则 `kube-proxy` 也需要设置该选项，否则会出现找不到 Node 的情况
- `--experimental-bootstrap-kubeconfig` 指向 bootstrap kubeconfig 文件，kubelet 使用该文件中的用户名和 token 向 kube-apiserver 发送 TLS Bootstrapping 请求
- 管理员通过了 CSR 请求后，kubelet 自动在 `--cert-dir` 目录创建证书和私钥文件(`kubelet-client.crt` 和 `kubelet-client.key`)，然后写入 `--kubeconfig` 文件(自动创建 `--kubeconfig` 指定的文件)
- 建议在 `--kubeconfig` 配置文件中指定 `kube-apiserver` 地址，如果未指定 `--api-servers` 选项，则必须指定 `--require-kubeconfig` 选项后才从配置文件中读取 kue-apiserver 的地址，否则 kubelet 启动后将找不到 kube-apiserver (日志中提示未找到 API Server），`kubectl get nodes` 不会返回对应的 Node 信息
- `--cluster-dns` 指定 kubedns 的 Service IP(可以先分配，后续创建 kubedns 服务时指定该 IP)，`--cluster-domain` 指定域名后缀，这两个参数同时指定后才会生效

## 启动kubelet

```bash
[root@node01 ~]# mv kubelet.service  /etc/systemd/system
[root@node01 ~]# systemctl daemon-reload
[root@node01 ~]#  systemctl enable kubelet

```

## 通过kubelet的TLS证书请求

kubelet 首次启动时向kube-apiserver 发送证书签名请求，必须通过后kubernetes 系统才会将该 Node 加入到集群。查看未授权的CSR 请求：

```bash
[root@master01 ~]# kubectl get csr
NAME                                                   AGE   SIGNERNAME                                    REQUESTOR           CONDITION
node-csr-cSl1V8Ncash7jxFfaReDTLeowwKl3kSeYtjMMjttn2o   7s    kubernetes.io/kube-apiserver-client-kubelet   kubelet-bootstrap   Pending

[root@master02 ~]# kubectl get nodes
No resources found in default namespace.


```

通过CSR请求：

```bash
[root@master02 ~]# kubectl certificate approve  node-csr-cSl1V8Ncash7jxFfaReDTLeowwKl3kSeYtjMMjttn2o 
certificatesigningrequest.certificates.k8s.io/node-csr-cSl1V8Ncash7jxFfaReDTLeowwKl3kSeYtjMMjttn2o approved

[root@master01 ~]# kubectl get nodes
NAME           STATUS   ROLES    AGE   VERSION
172.17.46.13   Ready    <none>   40s   v1.18.5


```

自动生成了kubelet kubeconfig 文件和公私钥：

```bash
[root@node01 ~]# ls -l /etc/kubernetes/kubelet.kubeconfig
-rw------- 1 root root 2304 Jul 11 18:22 /etc/kubernetes/kubelet.kubeconfig


[root@node01 ~]#  ls -l /etc/kubernetes/ssl/kubelet*
-rw------- 1 root root 1228 Jul 11 18:22 /etc/kubernetes/ssl/kubelet-client-2020-07-11-18-22-34.pem
lrwxrwxrwx 1 root root   58 Jul 11 18:22 /etc/kubernetes/ssl/kubelet-client-current.pem -> /etc/kubernetes/ssl/kubelet-client-2020-07-11-18-22-34.pem
-rw-r--r-- 1 root root 2181 Jul 11 18:15 /etc/kubernetes/ssl/kubelet.crt
-rw------- 1 root root 1675 Jul 11 18:15 /etc/kubernetes/ssl/kubelet.key

```

## 配置kube-proxy

### 创建kube-proxy 证书签名请求：

```bash
[root@master01 ~]# cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF

```

- CN 指定该证书的 User 为 `system:kube-proxy`
- `kube-apiserver` 预定义的 RoleBinding `system:node-proxier` 将User `system:kube-proxy` 与 Role `system:node-proxier`绑定，该 Role 授予了调用 `kube-apiserver` Proxy 相关 API 的权限
- hosts 属性值为空列表

### 生成kube-proxy 客户端证书和私钥

```bash
[root@master01 ~]# cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem \
>   -ca-key=/etc/kubernetes/ssl/ca-key.pem \
>   -config=/etc/kubernetes/ssl/ca-config.json \
>   -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy

[root@master01 ~]# ls kube-proxy*
kube-proxy.csr  kube-proxy-csr.json  kube-proxy-key.pem  kube-proxy.pem

[root@master01 ~]# mv kube-proxy*.pem /etc/kubernetes/ssl/

```

### 创建kube-proxy kubeconfig 文件

```bash
# 设置集群参数
[root@node01 ~]# kubectl config set-cluster kubernetes \
>   --certificate-authority=/etc/kubernetes/ssl/ca.pem \
>   --embed-certs=true \
>   --server=${KUBE_APISERVER} \
>   --kubeconfig=kube-proxy.kubeconfig
Cluster "kubernetes" set.

 # 设置客户端认证参数
[root@node01 ~]#  kubectl config set-credentials kube-proxy \
>   --client-certificate=/etc/kubernetes/ssl/kube-proxy.pem \
>   --client-key=/etc/kubernetes/ssl/kube-proxy-key.pem \
>   --embed-certs=true \
>   --kubeconfig=kube-proxy.kubeconfig
User "kube-proxy" set.

# 设置上下文参数
[root@node01 ~]# kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig
Context "default" created.


# 设置默认上下文
[root@node01 ~]# kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
Switched to context "default".

[root@node01 ~]# mv kube-proxy.kubeconfig /etc/kubernetes/


```

- 设置集群参数和客户端认证参数时 `--embed-certs` 都为 `true`，这会将 `certificate-authority`、`client-certificate` 和 `client-key` 指向的证书文件内容写入到生成的 `kube-proxy.kubeconfig` 文件中
- `kube-proxy.pem` 证书中 CN 为 `system:kube-proxy`，`kube-apiserver` 预定义的 RoleBinding `cluster-admin` 将User `system:kube-proxy` 与 Role `system:node-proxier` 绑定，该 Role 授予了调用 `kube-apiserver` Proxy 相关 API 的权限

### 创建kube-proxy 的systemd unit 文件

```bash
# 必须先创建工作目录
[root@node01 ~]#  mkdir -p /var/lib/kube-proxy 

cat > kube-proxy.service <<EOF
[Unit]
Description=Kubernetes Kube-Proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
WorkingDirectory=/var/lib/kube-proxy
ExecStart=/usr/k8s/bin/kube-proxy \\
  --bind-address=${NODE_IP} \\
  --hostname-override=${NODE_IP} \\
  --cluster-cidr=${SERVICE_CIDR} \\
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig \\
  --logtostderr=true \\
  --v=2
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```

- `--hostname-override` 参数值必须与 kubelet 的值一致，否则 kube-proxy 启动后会找不到该 Node，从而不会创建任何 iptables 规则
- `--cluster-cidr` 必须与 kube-apiserver 的 `--service-cluster-ip-range` 选项值一致
- kube-proxy 根据 `--cluster-cidr` 判断集群内部和外部流量，指定 `--cluster-cidr` 或 `--masquerade-all` 选项后 kube-proxy 才会对访问 Service IP 的请求做 SNAT
- `--kubeconfig` 指定的配置文件嵌入了 kube-apiserver 的地址、用户名、证书、秘钥等请求和认证信息
- 预定义的 RoleBinding `cluster-admin` 将User `system:kube-proxy` 与 Role `system:node-proxier` 绑定，该 Role 授予了调用 `kube-apiserver` Proxy 相关 API 的权限



### 启动kube-proxy

```bash
[root@node01 ~]# mv kube-proxy.service  /etc/systemd/system
[root@node01 ~]# systemctl daemon-reload
[root@node01 ~]# systemctl enable kube-proxy.service 
[root@node01 ~]# systemctl start kube-proxy
[root@node01 ~]# systemctl status kube-proxy

```



## 验证集群功能

定义yaml 文件：（将下面内容保存为：nginx-deployment.yaml）

```yaml
apiVersion: apps/v1 #于k8s集群版本有关，使用kubectl api-servrsions 即可查看当前集群支持的版本
kind: Deployment #该配置的类型，我们使用的是deployment
metadata: #译名为元数据，即deployment的一些基本属性和信息
  name: nginx-deployment #deployment的名称
  labels: #标签，可以灵活定位一个或多个资源，其中key和value均可自定义，可以定义多组
    app: nginx #为该deployment设置key为app value为nginx的标签
spec: #这是关于该deployment的描述，可以理解为你期待该deployment再k8s中如何使用
  replicas: 3 #使用该deployment创建一个应用程序实例
  selector: #标签选择器，与上面的标签共同作用 
    matchLabels: #选择包含标签app:nginx的资源
       app: nginx

  template: #这是选择或创建pod的模板
    metadata: #pod的元数据
      labels: #pod的标签，上面的selector即选择包含标签app:nginx的pod
        app: nginx
    spec: #期待pod实现的功能（即在pod中部署） 
      containers: #生成container，与docker中的container是同一种
      - name: nignx #container的名称
        image: nginx:1.13.0 #使用镜像nginx1.13.0创建container，该container默认80端口可以访问

```
定义service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service #Service 的名称
  labels: #Service 自己的标签
    app: nginx #为该 Service 设置 key 为 app，value 为 nginx 的标签
spec: #这是关于该 Service 的定义，描述了 Service 如何选择 Pod，如何被访问
  selector:  #标签选择器
    app: nginx #选择包含标签 app:nginx 的 Pod
  ports:
  - name: nginx-port  #端口的名字
    protocol: TCP    #协议类型 TCP/UD
    port: 80         #集群内的其他容器组可通过 80 端口访问 Service
    nodePort: 32600 #通过任意节点的 32600 端口访问 Service
    targetPort: 80  #将请求转发到匹配 Pod 的 80 端口
  type: NodePort #Serive的类型，ClusterIP/NodePort/LoaderBalancer

~                                                                              
```



### 创建pod和服务

```bash
[root@master01 nginx]# kubectl create -f nginx.deployment.yaml 
deployment.apps/nginx-deployment created

[root@master01 nginx]# kubectl apply -f nginx-service.yaml 
service/nginx-service created

```

预期访问所有node ip:32600都会输出nginx 欢迎页面内容，表示我们的Node 节点正常运行了。

### 配置k8s自动补全

```bash
[root@master01 nginx]# yum install -y bash-completion
[root@master01 nginx]# source /usr/share/bash-completion/bash_completion
[root@master01 nginx]# source <(kubectl completion bash)
[root@master01 nginx]# echo "source <(kubectl completion bash)" >> ~/.bashrc

```



# 9. 部署kubedns 插件

官方文件目录：[kubernetes/cluster/addons/dns](https://github.com/kubernetes/kubernetes/tree/v1.8.2/cluster/addons/dns)

使用的文件：

```bash
[root@master01 nginx]# ls *.yaml *.base
kubedns-cm.yaml               kubedns-sa.yaml  kubedns-controller.yaml.base  kubedns-svc.yaml.base
```

## 系统预定义的RoleBinding

预定义的RoleBinding `system:kube-dns`将kube-system 命名空间的`kube-dns`ServiceAccount 与 `system:kube-dns` Role 绑定，该Role 具有访问kube-apiserver DNS 相关的API 权限：

```bash
[root@master01 nginx]# kubectl get clusterrolebindings system:kube-dns -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  creationTimestamp: "2020-07-11T08:12:11Z"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  managedFields:
  - apiVersion: rbac.authorization.k8s.io/v1
    fieldsType: FieldsV1
    fieldsV1:
      f:metadata:
        f:annotations:
          .: {}
          f:rbac.authorization.kubernetes.io/autoupdate: {}
        f:labels:
          .: {}
          f:kubernetes.io/bootstrapping: {}
      f:roleRef:
        f:apiGroup: {}
        f:kind: {}
        f:name: {}
      f:subjects: {}
[root@master01 nginx]# kubectl get clusterrolebindings system:kube-dns -o yaml 
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  creationTimestamp: "2020-07-11T08:12:11Z"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  managedFields:
  - apiVersion: rbac.authorization.k8s.io/v1
    fieldsType: FieldsV1
    fieldsV1:
      f:metadata:
        f:annotations:
          .: {}
          f:rbac.authorization.kubernetes.io/autoupdate: {}
        f:labels:
          .: {}
          f:kubernetes.io/bootstrapping: {}
      f:roleRef:
        f:apiGroup: {}
        f:kind: {}
        f:name: {}
      f:subjects: {}
    manager: kube-apiserver
    operation: Update
    time: "2020-07-11T08:12:11Z"
  name: system:kube-dns
  resourceVersion: "104"
  selfLink: /apis/rbac.authorization.k8s.io/v1/clusterrolebindings/system%3Akube-dns
  uid: b2b219d5-009e-4fac-a4d0-e7a1665168fc
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-dns
subjects:
- kind: ServiceAccount
  name: kube-dns
  namespace: kube-system

```

`kubedns-controller.yaml` 中定义的 Pods 时使用了 `kubedns-sa.yaml` 文件定义的 `kube-dns` ServiceAccount，所以具有访问 kube-apiserver DNS 相关 API 的权限；

## 配置kube-dns ServiceAccount

无需更改

## 配置kube-dns 服务

```bash
[root@master01 nginx]# diff kubedns-svc.yaml.base  kubedns-svc.yaml
14c14
<   clusterIP: __PILLAR__DNS__SERVER__
---
>   clusterIP: 10.254.0.2

```

需要将 spec.clusterIP 设置为集群环境变量中变量 `CLUSTER_DNS_SVC_IP` 值，这个IP 需要和 kubelet 的 `—cluster-dns` 参数值一致

## 配置kube-dns Deployment

```bash
[root@master01 nginx]# diff kubedns-controller.yaml.base kubedns-controller.yaml
69c69
<         - --domain=__PILLAR__DNS__DOMAIN__.
---
>         - --domain=cluster.local
109c109
<         - --server=/__PILLAR__DNS__DOMAIN__/127.0.0.1#10053
---
>         - --server=/cluster.local/127.0.0.1#10053
141,142c141,142
<         - --probe=kubedns,127.0.0.1:10053,kubernetes.default.svc.__PILLAR__DNS__DOMAIN__,5,A
<         - --probe=dnsmasq,127.0.0.1:53,kubernetes.default.svc.__PILLAR__DNS__DOMAIN__,5,A
---
>         - --probe=kubedns,127.0.0.1:10053,kubernetes.default.svc.cluster.local,5,A
>         - --probe=dnsmasq,127.0.0.1:53,kubernetes.default.svc.cluster.local,5,A


```

- `--domain` 为集群环境变量`CLUSTER_DNS_DOMAIN` 的值
- 使用系统已经做了 RoleBinding 的 `kube-dns` ServiceAccount，该账户具有访问 kube-apiserver DNS 相关 API 的权限

## 执行所有定义文件

```bash
[root@master01 kube-dns]# ls *.yaml
kubedns-cm.yaml  kubedns-controller.yaml  kubedns-sa.yaml  kubedns-svc.yaml

[root@master01 kube-dns]# kubectl create -f .
configmap/kube-dns created
deployment.apps/kube-dns created
serviceaccount/kube-dns created
service/kube-dns created

```

## 检测kubedns

新建一个deployment

```yaml
apiVersion: apps/v1 #于k8s集群版本有关，使用kubectl api-servrsions 即可查看当前集群支持的版本
kind: Deployment #该配置的类型，我们使用的是deployment
metadata: #译名为元数据，即deployment的一些基本属性和信息
  name: my-nginx #deployment的名称
  labels: #标签，可以灵活定位一个或多个资源，其中key和value均可自定义，可以定义多组
    run: my-nginx #为该deployment设置key为app value为nginx的标签
spec: #这是关于该deployment的描述，可以理解为你期待该deployment再k8s中如何使用
  replicas: 3 #使用该deployment创建一个应用程序实例
  selector: #标签选择器，与上面的标签共同作用 
    matchLabels: #选择包含标签app:nginx的资源
       run: my-nginx

  template: #这是选择或创建pod的模板
    metadata: #pod的元数据
      labels: #pod的标签，上面的selector即选择包含标签app:nginx的pod
        run: my-nginx
    spec: #期待pod实现的功能（即在pod中部署） 
      containers: #生成container，与docker中的container是同一种
      - name: my-nignx #container的名称
        image: nginx:1.13.0 #使用镜像nginx1.7.9创建container，该container默认80端口可以访问
        ports:
        - containerPort: 80

~                                  

```

Expose 该Deployment，生成my-nginx 服务

```bash

[root@master01 kube-dns]# kubectl apply -f my-nginx.yaml 
deployment.apps/nginx-deployment created

[root@master01 kube-dns]# kubectl expose deployment my-nginx 
service/my-nginx exposed
[root@master01 kube-dns]# kubectl exec -it nginx-deployment-65f877b57c-bbm8f bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl kubectl exec [POD] -- [COMMAND] instead.
root@nginx-deployment-65f877b57c-bbm8f:/# ping my-nginx
PING my-nginx.default.svc.cluster.local (10.254.9.156): 56 data bytes
^C--- my-nginx.default.svc.cluster.local ping statistics ---
1 packets transmitted, 0 packets received, 100% packet loss


root@nginx-deployment-65f877b57c-bbm8f:/#  ping kube-dns.kube-system.svc.cluster.local
PING kube-dns.kube-system.svc.cluster.local (10.254.0.2): 56 data bytes
^C--- kube-dns.kube-system.svc.cluster.local ping statistics ---
1 packets transmitted, 0 packets received, 100% packet loss
root@nginx-deployment-65f877b57c-bbm8f:/#  ping kubernetes
PING kubernetes.default.svc.cluster.local (10.254.0.1): 56 data bytes
^C--- kubernetes.default.svc.cluster.local ping statistics ---
1 packets transmitted, 0 packets received, 100% packet loss


```

# 10. 部署kuboard

```bash
kubectl apply -f https://kuboard.cn/install-script/kuboard.yaml
kubectl apply -f https://addons.kuboard.cn/metrics-server/0.3.6/metrics-server.yaml

[root@master01 dashboard]# kubectl get svc -n kube-system
NAME             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
kube-dns         ClusterIP   10.254.0.2       <none>        53/UDP,53/TCP   42m
kuboard          NodePort    10.254.118.21    <none>        80:32567/TCP    105s
metrics-server   ClusterIP   10.254.159.177   <none>        443/TCP         96s
 
```

## 获取token

```bash
echo $(kubectl -n kube-system get secret $(kubectl -n kube-system get secret | grep kuboard-user | awk '{print $1}') -o go-template='{{.data.token}}' | base64 -d)

```

访问工作节点:32567就可以了

# 11. 安装ingress

`Ingress`其实就是从`kuberenets`集群外部访问集群的一个入口，将外部的请求转发到集群内不同的Service 上，其实就相当于nginx、apache 等负载均衡代理服务器，再加上一个规则定义，路由信息的刷新需要靠`Ingress controller`来提供

`Ingress controller`可以理解为一个监听器，通过不断地与`kube-apiserver`打交道，实时的感知后端service、pod 等的变化，当得到这些变化信息后，`Ingress controller`再结合`Ingress`的配置，更新反向代理负载均衡器，达到服务发现的作用。其实这点和服务发现工具`consul`的`consul-template`非常类似。

## 部署traefik

[Traefik](https://traefik.io/)是一款开源的反向代理与负载均衡工具。它最大的优点是能够与常见的微服务系统直接整合，可以实现自动化动态配置。目前支持**Docker、Swarm、Mesos/Marathon、 Mesos、Kubernetes、Consul、Etcd、Zookeeper、BoltDB、Rest API**等等后端模型。

### 创建rbac

创建文件：`ingress-rbac.yaml`，用于`service account`验证

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ingress
  namespace: kube-system
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: ingress
subjects:
  - kind: ServiceAccount
    name: ingress
    namespace: kube-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```



### DaemonSet形式部署traefik

创建文件：`traefik-daemonset.yaml`，为保证traefik 总能提供服务，在每个节点上都部署一个traefik，所以这里使用`DaemonSet` 的形式

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: traefik-conf
  namespace: kube-system
data:
  traefik-config: |-
    defaultEntryPoints = ["http","https"]
    [entryPoints]
      [entryPoints.http]
      address = ":80"
        [entryPoints.http.redirect]
          entryPoint = "https"
      [entryPoints.https]
      address = ":443"
        [entryPoints.https.tls]
          [[entryPoints.https.tls.certificates]]
          CertFile = "/ssl/ssl.crt"
          KeyFile = "/ssl/ssl.key"
---

```

注意上面的yaml 文件中我们添加了一个名为`traefik-conf`的`ConfigMap`，该配置是用来将http 请求强制跳转成https，并指定https 所需CA 文件地址

```bash
kubectl create secret generic traefik-ssl --from-file=ssl.crt --from-file=ssl.key --namespace=kube-system
```



### traefik UI

创建文件：`traefik-ui.yaml`，

```yaml
apiVersion: v1
kind: Service
metadata:
  name: traefik-ui
  namespace: kube-system
spec:
  selector:
    k8s-app: traefik-ingress
  ports:
  - name: web
    port: 80
    targetPort: 8080
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: traefik-ui
  namespace: kube-system
spec:
  rules:
  - host: traefik-ui.local
    http:
      paths:
      - path: /
        backend:
          serviceName: traefik-ui
          servicePort: web
```

### 创建ingress 

创建文件：`traefik-ingress.yaml`，现在可以通过创建`ingress`文件来定义请求规则了，根据自己集群中的service 自己修改相应的`serviceName` 和`servicePort`

```bash
[root@master01 ingress]# kubectl get svc
NAME            TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
kubernetes      ClusterIP   10.254.0.1    <none>        443/TCP    20h
nginx-service   ClusterIP   10.254.0.50   <none>        9000/TCP   98m

```



```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: traefik-ingress
spec:
  rules:
  - host: traefik.nginx.io
    http:
      paths:
      - path: /
        backend:
          serviceName: nginx-service
          servicePort: 9000

```

执行创建命令：

```bash
[root@master01 ingress]# kubectl apply -f .
serviceaccount/ingress created
clusterrolebinding.rbac.authorization.k8s.io/ingress created
ingress.extensions/traefik-ingress created
configmap/traefik-conf created
daemonset.apps/traefik-ingress created
service/traefik-ui created
ingress.extensions/traefik-ui created

```

## 测试

部署完成后，在本地`/etc/hosts`添加一条配置：

```bash
# 将下面的xx.xx.xx.xx替换成任意工作节点IP
xx.xx.xx.xx traefik.nginx.io traefik-ui.local
```

```bash
[root@master01 ingress]# curl -vvv traefik.nginx.io
* About to connect() to traefik.nginx.io port 80 (#0)
*   Trying 172.17.46.13...
* Connected to traefik.nginx.io (172.17.46.13) port 80 (#0)
> GET / HTTP/1.1
> User-Agent: curl/7.29.0
> Host: traefik.nginx.io
> Accept: */*
> 
< HTTP/1.1 302 Found
< Location: https://traefik.nginx.io:443/
< Date: Sun, 12 Jul 2020 05:04:13 GMT
< Content-Length: 5
< Content-Type: text/plain; charset=utf-8
< 
* Connection #0 to host traefik.nginx.io left intact

```

可以看到已经可以访问了。最后失败是因为跳转https 去调一下traefik就可以了

```yaml
#        [entryPoints.http.redirect]
#          entryPoint = "https"
#      [entryPoints.https]
#      address = ":443"
 #       [entryPoints.https.tls]
 #         [[entryPoints.https.tls.certificates]]
 #         CertFile = "/ssl/ssl.crt"
 #         KeyFile = "/ssl/ssl.key"
```

