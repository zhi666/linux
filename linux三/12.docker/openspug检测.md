openspug检测

openspug.yml

```
version: "3"
services:
  open-spug:
    image: openspug/spug
    container_name: spug
    hostname: spug
    networks:
      - spugnetwork
    volumes:
      - "spugdata:/data"
    ports:
      - "9898:80"
networks:
  spugnetwork:

volumes:
  spugdata:
    driver: local-persist
    driver_opts:
      mountpoint: /root/openspug/data/
```



启动后设置用户信息

```
#进入容器 设定用户密码  以下为 admin spug.dev 账号密码
docker exec $CONTAINER_ID init_spug admin spug.dev
 
#执行完毕重启容器 
docker restart $CONTAINER_ID
```



```
#如果容器重启了 导致监控不更新
$ cd /data/spug/spug_api
$ source venv/bin/activate
$ python manage.py runmonitor

```

