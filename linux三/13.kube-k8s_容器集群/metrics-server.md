因为上一次部署wordpress 忘记写了，因为HPA是要去获取pod的cpu占用的，所以需要部署metrics-server  这样才能实现 HPA

### 生成证书并分发

```bash
cat > metrics-server-csr.json <<EOF
{
  "CN": "aggregator",
  "hosts": [
    "127.0.0.1",
    "172.17.46.196",
    "172.17.46.13",
    "172.17.46.11",
    "172.17.46.14"
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
      "OU": "4Paradigm"
    }
  ]
}
EOF

cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem   -ca-key=/etc/kubernetes/ssl/ca-key.pem    -config= /etc/kubernetes/ssl/ca-config.json  -profile=kubernetes metrics-server-csr.json | cfssljson -bare metrics-server


```

> 证书移动到/etc/kubernetes/ssl/下
> 分发到各个节点

kube-apiserver.service文件追加

```bash
  --requestheader-client-ca-file=/etc/kubernetes/ssl/ca.pem \
  --requestheader-allowed-names="" \
  --requestheader-extra-headers-prefix="X-Remote-Extra-" \
  --requestheader-group-headers=X-Remote-Group \
  --requestheader-username-headers=X-Remote-User \
  --proxy-client-cert-file=/etc/kubernetes/ssl/metrics-server.pem \
  --proxy-client-key-file=/etc/kubernetes/ssl/metrics-server-key.pem \
  --enable-aggregator-routing=true
```
```bash
systemctl daemon-reload
systemctl restart kube-apiserver
```



### 部署metrics-server

```bash
wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml
```



```yaml
      - name: metrics-server
        image: k8s.gcr.io/metrics-server-amd64:v0.3.6
        imagePullPolicy: IfNotPresent
        args:
          - --cert-dir=/tmp
          - --secure-port=4443
          - --kubelet-insecure-tls#修改部分
          - --kubelet-preferred-address-types=InternalIP#修改部分

```

```bash

[root@master01 wordpress]# kubectl apply -f components.yaml 
[root@master01 wordpress]# kubectl get hpa  wordpress -n blog
NAME        REFERENCE              TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
wordpress   Deployment/wordpress   1%/10%    1         10        1          31m

[root@master01 wordpress]# kubectl get pods -n blog
NAME                        READY   STATUS    RESTARTS   AGE
mysql-6c6f96f7d6-ncgrs      1/1     Running   0          34m
wordpress-6559976c8-gmkhg   1/1     Running   0          34m
# 可以看到目前只有一个wordpress pod

[root@master02 ~]# while true;do wget -q -O- traefik.nginx.io ;done

[root@master01 wordpress]# kubectl get hpa  wordpress -n blog
NAME        REFERENCE              TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
wordpress   Deployment/wordpress   200%/10%   1         10        4          33m

#自动在陆续启动了
[root@master01 wordpress]# kubectl get pods -n blog
NAME                        READY   STATUS     RESTARTS   AGE
mysql-6c6f96f7d6-ncgrs      1/1     Running    0          36m
wordpress-6559976c8-2r8jg   0/1     Running    0          28s
wordpress-6559976c8-2rkxd   0/1     Init:0/1   0          12s
wordpress-6559976c8-gmkhg   1/1     Running    0          36m
wordpress-6559976c8-jg5c8   0/1     Running    0          28s
wordpress-6559976c8-jx6zt   0/1     Running    0          43s
wordpress-6559976c8-l99h2   0/1     Running    0          43s
wordpress-6559976c8-nc67g   0/1     Running    0          28s
wordpress-6559976c8-pnpkd   0/1     Running    0          28s
wordpress-6559976c8-tq2wp   0/1     Init:0/1   0          12s
wordpress-6559976c8-xnpdn   0/1     Running    0          43s



```

