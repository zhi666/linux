

登陆root帐户,输入cat /etc/redhat-release,即可显示系统版本.
编写启动脚本

[root@n1 ~]# vim  /usr/lib/systemd/system/nginx.service

```

[Unit]
Description=nginx

After=network.target remote-fs.target nss-lookup.target

[Service]

Type=forking

PIDFile=/usr/local/nginx/logs/nginx.pid

ExecStartPost=/bin/sleep 0.1

ExecStartPre=/usr/local/nginx/sbin/nginx -t -c /usr/local/nginx/conf/nginx.conf

ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf

ExecReload=/bin/kill -s HUP $MAINPID

ExecStop=/bin/kill -s QUIT $MAINPID

PrivateTmp=true

[Install]

WantedBy=multi-user.target

```