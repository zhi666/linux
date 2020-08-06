[toc]
# 部署wordpress
## MySql部署集

`mysqldeployment.yaml`

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-deploy
  namespace: blog
  labels:
    app: mysql
spec:
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:5.7
        imagePullPolicy: IfNotPresent
        args:
        - --default_authentication_plugin=mysql_native_password
        - --character-set-server=utf8mb4
        - --collation-server=utf8mb4_unicode_ci
        ports:
        - containerPort: 3306
          name: dbport
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: rootPassW0rd
        - name: MYSQL_DATABASE
          value: wordpress
        - name: MYSQL_USER
          value: wordpress
        - name: MYSQL_PASSWORD
          value: wordpress
        volumeMounts:
        - name: db
          mountPath: /var/lib/mysql
      volumes:
      - name: db
        hostPath:
          path: /var/lib/mysql

```

## MySql Service

`mysql-service.yaml`

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: blog
spec:
  selector:
    app: mysql
  ports:
  - name: mysqlport
    protocol: TCP
    port : 3306
    targetPort: 3306

```

## WordPress 部署集

`wordpress.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress-dploy
  namespace: blog
  labels:
    app: wordpress
spec:
  replicas: 2
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
      - name: wordpress
        image: wordpress
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
          name: wdport
        env:
        - name: WORDPRESS_DB_HOST
          value: 10.254.42.40:3306 #为mysql svc 的clusterip地址
        - name: WORDPRESS_DB_USER
          value: wordpress
        - name: WORDPRESS_DB_PASSWORD
          value: wordpress


```

## WordPress Service

`wordpress-service.yaml`

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  namespace: blog
spec:
  selector:
    app: wordpress
  ports:
  - name: wordpressport
    protocol: TCP
    port: 8888
    targetPort: 80

```

`ingress.yaml`

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: wordpress
  namespace: blog
spec:
#  tls:
#  - hosts:
#    - traefik.nginx.io
#    secretName: traefik-ssl
  rules:
  - host: traefik.nginx.io
    http:
      paths:
      - path: /
        backend:
          serviceName: wordpress
          servicePort: 8888

```

> 建议练习直接用`nodeport`就可以，用i`ngress `涉及到`ingress-rbac.yaml ` `ingress.yaml  ssl.crt  ssl.key  traefik-daemonset.yaml  traefik-ui.yaml `  可以去二进制部署那一篇里面找

# 提高稳定性

## 健康检测

现在`wordpress`应用已经部署成功了，那么就万事大吉了吗？如果我们的网站访问量突然变大了怎么办，如果我们要更新我们的镜像该怎么办？如果我们的`mysql`服务挂掉了怎么办？

所以要保证我们的网站能够非常稳定的提供服务，我们做得还不够，我们可以通过做些什么事情来提高网站的稳定性呢？

第一. 增加健康检测，`liveness probe`和`rediness probe`是提高应用稳定性非常重要的方法：

```yaml
livenessProbe:
  tcpSocket:
    port: 80
  initialDelaySeconds: 3
  periodSeconds: 3
readinessProbe:
  tcpSocket:
    port: 80
  initialDelaySeconds: 5
  periodSeconds: 10
```

增加上面两个探针，每10s检测一次应用是否可读，每3s检测一次应用是否存活

## HPA

第二. 增加 HPA，让我们的应用能够自动应对流量高峰期：

```bash
kubectl autoscale deployment wordpress-deploy --cpu-percent=10 --min=1 --max=10 -n blog
deployment "wordpress-deploy" autoscaled
```

我们用`kubectl autoscale`命令为我们的`wordpress-deploy`创建一个`HPA`对象，最小的 pod 副本数为1，最大为10，`HPA`会根据设定的 cpu使用率（10%）动态的增加或者减少pod数量。当然最好我们也为`Pod`声明一些资源限制：

```yaml
resources:
  limits:
    cpu: 200m
    memory: 200Mi
  requests:
    cpu: 100m
    memory: 100Mi
```

更新`Deployment`后，我们可以可以来测试下上面的`HPA`是否会生效：

```bash
$ kubectl run -i --tty load-generator --image=busybox /bin/sh
If you don't see a command prompt, try pressing enter.
/ # while true; do wget -q -O- http://$url; done
```

观察`Deployment`的副本数是否有变化

```bash
$ kubectl get deployment wordpress-deploy
NAME        DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
wordpress-deploy   3         3         3            3           4d
```

## 滚动更新策略

第三. 增加滚动更新策略，这样可以保证我们在更新应用的时候服务不会被中断：

```yaml
replicas: 2
revisionHistoryLimit: 10
minReadySeconds: 5
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 1
```

第四. 我们知道如果`mysql`服务被重新创建了的话，它的`clusterIP`非常有可能就变化了，所以上面我们环境变量中的`WORDPRESS_DB_HOST`的值就会有问题，就会导致访问不了数据库服务了，这个地方我们可以直接使用`Service`的名称来代替`host`，这样即使`clusterIP`变化了，也不会有任何影响。

> 这里有个坑 如果发生错误的话，去容器里看下是否能解析到mysql-service name mysql的ip 如果解析不到 重新启动下kube-dns

```yaml
env:
- name: WORDPRESS_DB_HOST
  value: mysql:3306
```

第五. 我们在部署`wordpress`服务的时候，`mysql`服务以前启动起来了吗？如果没有启动起来是不是我们也没办法连接数据库了啊？该怎么办，是不是在启动`wordpress`应用之前应该去检查一下`mysql`服务，如果服务正常的话我们就开始部署应用了，这是不是就是`InitContainer`的用法：

```yaml
initContainers:
- name: init-db
  image: busybox
  command: ['sh', '-c', 'until nslookup mysql; do echo waiting for mysql service; sleep 2; done;']
```

直到`mysql`服务创建完成后，`initContainer`才结束，结束完成后我们才开始下面的部署。

最后，我们把部署的应用整合到一个`YAML`文件中来：（wordpress-all.yaml）

# 整合wordpress

wordpress-all.yaml

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  namespace: blog
  labels:
    app: mysql
spec:
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:5.7
        args:
        - --default_authentication_plugin=mysql_native_password
        - --character-set-server=utf8mb4
        - --collation-server=utf8mb4_unicode_ci
        ports:
        - containerPort: 3306
          name: dbport
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: rootPassw0rd
        - name: MYSQL_DATABASE
          value: wordpress
        - name: MYSQL_USER
          value: wordpress
        - name: MYSQL_PASSWORD
          value: wordpress
        volumeMounts:
        - name: db
          mountPath: /var/lib/mysql
      volumes:
      - name: db
        hostPath:
          path: /var/lib/mysql

---
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: blog
spec:
  selector:
    app: mysql
  ports:
  - name: mysqlport
    protocol: TCP
    port: 3306
    targetPort: 3306

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  namespace: blog
  labels:
    app: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
  minReadySeconds: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      initContainers:
      - name: init-db
        image: busybox
        command: ['sh', '-c', 'until nslookup mysql;do echo waiting for mysql service; sleep 2;done;']      
      containers:
      - name: wordpress
        image: wordpress
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
          name: wdport
        env:
        - name: WORDPRESS_DB_HOST
          value: mysql:3306
        - name: WORDPRESS_DB_USER
          value: wordpress
        - name: WORDPRESS_DB_PASSWORD
          value: wordpress
        readinessProbe:
          tcpSocket:
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        resources:
          limits:
            cpu: 200m
            memory: 256Mi
          requests:
            cpu: 100m
            memory: 100Mi

---
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  namespace: blog
spec:
  selector:
    app: wordpress
  ports:
  - name: wordpressport
    protocol: TCP
    port: 8989
    targetPort: 80

---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: wordpress
  namespace: blog
spec:
 # tls:
 # - hosts:
 #   - traefik.nginx.io
 #   secretName: traefik-ssl
  rules:
  - host: traefik.nginx.io
    http:
      paths:
      - path: /
        backend:
          serviceName: wordpress
          servicePort: 8989

```

```bash
[root@master01 wordpress]# kubectl create -f wordpress-all.yaml 

[root@master01 wordpress]# kubectl autoscale deployment wordpress --cpu-percent=10 --min=1 --max=10 -n blog
horizontalpodautoscaler.autoscaling/wordpress autoscaled


```

