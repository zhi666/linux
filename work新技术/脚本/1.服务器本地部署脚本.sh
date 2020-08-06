#!/bin/bash

#清环境
systemctl disable firewalld
systemctl stop firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

#安装epel源
yum install -y epel-release

#导入zabbix源
cat <<EOF >/etc/yum.repos.d/zabbix.repo
[zabbix]
name=Zabbix Official Repository - \$basearch
baseurl=http://repo.zabbix.com/zabbix/3.2/rhel/7/\$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX-A14FE591

[zabbix-non-supported]
name=Zabbix Official Repository non-supported - \$basearch 
baseurl=http://repo.zabbix.com/non-supported/rhel/7/\$basearch/
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX
gpgcheck=1
EOF

#导入zabbix秘钥
cat <<EOF >/etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX-A14FE591
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.10 (GNU/Linux)

mQENBFeIdv0BCADAzkjO9jHoDRfpJt8XgfsBS8FpANfHF2L29ntRwd8ocDwxXSbt
BuGIkUSkOPUTx6i/e9hd8vYh4mcX3yYpiW8Sui4aXbJu9uuSdU5KvPOaTsFeit9j
BDK4b0baFYBDpcBBrgQuyviMAVAczu5qlwolA/Vu6DWqah1X9p+4EFa1QitxkhYs
3br2ZGy7FZA3f2sZaVhHAPAOBSuQ1W6tiUfTIj/Oc7N+FBjmh3VNfIvMBa0E3rA2
JlObxUEywsgGo7FPWnwjZyv883slHp/I3H4Or9VBouTWA2yICeROmMwjr4mOZtJT
z9e4v/a2cG/mJXgxCe+FjBvTvrgOVHAXaNwLABEBAAG0IFphYmJpeCBMTEMgPHBh
Y2thZ2VyQHphYmJpeC5jb20+iQE4BBMBAgAiBQJXiHb9AhsDBgsJCAcDAgYVCAIJ
CgsEFgIDAQIeAQIXgAAKCRAIKrVroU/lkbO8B/4/MhxoUN2RPmH7BzFGIntKEWAw
bRkDzyQOk9TjXVegfsBnzmDSdowh7gyteVauvr62jiVtowlE/95vbXqbBCISLqKG
i9Wmbrj7lUXBd2sP7eApFzMUhb3G3GuV5pCnRBIzerDfhXiLE9EWRN89JYDxwCLY
ctQHieZtdmlnPyCbFF6wcXTHUEHBPqdTa6hvUqQL2lHLFoduqQz4Q47Cz7tZxnbr
akAewEToPcjMoteCSfXwF/BRxSUDlN7tKFfBpYQawS8ZtN09ImHOO6CZ/pA0qQim
iNiRUfA25onIDWLLY/NMWg+gK94NVVZ7KmFG3upDB5/uefK6Xwu2PsgiXSQguQEN
BFeIdv0BCACZgfqgz5YoX+ujVlw1gX1J+ygf10QsUM9GglLEuDiSS/Aa3C2UbgEa
+N7JuvzZigGFCvxtAzaerMMDzbliTqtMGJOTjWEVGxWQ3LiY6+NWgmV46AdXik7s
UXM155f1vhOzYp6EZj/xtGvyUzTLUkAlnZNrhEUbUmOhDLassVi32hIyMR5W7w6I
Ii0zIM1mSuLR0H6oDEpR3GzuGVHGj4/sLeAg7iY5MziGwySBQk0Dg0xH5YqHb+uK
zCTH/ILu3srPJq+237Px/PctAZCEA96ogc/DNF2XjdUpMSaEybR0LuHHstAqkrq8
AyRtDJNYE+09jDFdUIukhErLuo1YPWqFABEBAAGJAR8EGAECAAkFAleIdv0CGwwA
CgkQCCq1a6FP5ZH8+wf/erZneDXqM6xYT8qncFpc1GtOCeODNb19Ii22lDEXd9qN
UlAz2SB6zC5oywlnR0o1cglcrW96MD/uuCL/+tTczeB2C455ofs2mhpK7nKiA4FM
+JZZ6XSBnq7sfsYD6knbvS//SXQV/qYb4bKMvwYnyMz63escgQhOsTT20ptc/w7f
C+YPBR/rHImKspyIwxyqU8EXylFW8f3Ugi2+Fna3CAPR9yQIAChkCjUawUa2VFmm
5KP8DHg6oWM5mdqcpvU5DMqpi8SA26DEFvULs8bR+kgDd5AU3I4+ei71GslOdfk4
s1soKT4X2UK+dCCXui+/5ZJHakC67t5OgbMas3Hz4Q==
=5TOS
-----END PGP PUBLIC KEY BLOCK-----
EOF

cat <<EOF >/etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.10 (GNU/Linux)

mQGiBFCNJaYRBAC4nIW8o2NyOIswb82Xn3AYSMUcNZuKB2fMtpu0WxSXIRiX2BwC
YXx8cIEQVYtLRBL5o0JdmoNCjW6jd5fOVem3EmOcPksvzzRWonIgFHf4EI2n1KJc
JXX/nDC+eoh5xW35mRNFN/BEJHxxiRGGbp2MCnApwgrZLhOujaCGAwavGwCgiG4D
wKMZ4xX6Y2Gv3MSuzMIT0bcEAKYn3WohS+udp0yC3FHDj+oxfuHpklu1xuI3y6ha
402aEFahNi3wr316ukgdPAYLbpz76ivoouTJ/U2MqbNLjAspDvlnHXXyqPM5GC6K
jtXPqNrRMUCrwisoAhorGUg/+S5pyXwsWcJ6EKmA80pR9HO+TbsELE5bGe/oc238
t/2oBAC3zcQ46wPvXpMCNFb+ED71qDOlnDYaaAPbjgkvnp+WN6nZFFyevjx180Kw
qWOLnlNP6JOuFW27MP75MDPDpbAAOVENp6qnuW9dxXTN80YpPLKUxrQS8vWPnzkY
WtUfF75pEOACFVTgXIqEgW0E6oww2HJi9zF5fS8IlFHJztNYtbQgWmFiYml4IFNJ
QSA8cGFja2FnZXJAemFiYml4LmNvbT6IYAQTEQIAIAUCUI0lpgIbAwYLCQgHAwIE
FQIIAwQWAgMBAh4BAheAAAoJENE9WOR56l7UhUwAmgIGZ39U6D2w2oIWDD8m7KV3
oI06AJ9EnOxMMlxEjTkt9lEvGhEX1bEh7bkBDQRQjSWmEAQAqx+ecOzBbhqMq5hU
l39cJ6l4aocz6EZ9mSSoF/g+HFz6WYnPAfRaYyfLmZdtF5rGBDD4ysalYG5yD59R
Mv5tNVf/CEx+JAPMhp6JCBkGRaH+xHws4eBPGkea4rGNVP3L3rA7g+c1YXZICGRI
OOH7CIzIZ/w6aFGsPp7xM35ogncAAwUD/3s8Nc1OLDy81DC6rGpxfEURd5pvd/j0
D5Di0WSBEcHXp5nThDz6ro/Vr0/FVIBtT97tmBHX27yBS3PqxxNRIjZ0GSWQqdws
Q8o3YT+RHjBugXn8CzTOvIn+2QNMA8EtGIZPpCblJv8q6MFPi9m7avQxguMqufgg
fAk7377Rt9RqiEkEGBECAAkFAlCNJaYCGwwACgkQ0T1Y5HnqXtQx4wCfcJZINKVq
kQIoV3KTQAIzr6IvbZoAn12XXt4GP89xHuzPDZ86YJVAgnfK
=+200
-----END PGP PUBLIC KEY BLOCK-----
EOF

#安装软件
yum install -y vim lsof wget iptables* bc nginx fail2ban unzip google-authenticator zabbix-agent expect lrzsz iftop net-tools rsync

#创建相关目录
mkdir /sh
mkdir /script
mkdir /etc/nginx/kis
mkdir /etc/nginx/conf

#导入nginx主配置
cat <<EOF >/etc/nginx/nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
# Load dynamic modules. See /usr/share/nginx/README.dynamic.
worker_rlimit_nofile 65535;
include /usr/share/nginx/modules/*.conf;
events {
    use epoll;
    multi_accept on;
    worker_connections 65535;
}
http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] \"\$request\" '
                      '\$status \$body_bytes_sent \"\$http_referer\" '
                      '\"\$http_user_agent\" \"\$http_x_forwarded_for\"';
    access_log  /var/log/nginx/access.log  main;
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;
    proxy_connect_timeout 300;
    proxy_send_timeout 300;
    proxy_read_timeout 300;
    proxy_buffer_size 256k;
    proxy_buffers 128 32k;
    proxy_busy_buffers_size 512k;
    proxy_temp_file_write_size 256k;
    proxy_max_temp_file_size 128m;
    proxy_redirect off;
    proxy_headers_hash_max_size 51200;
    proxy_headers_hash_bucket_size 6400;
    proxy_next_upstream error timeout invalid_header http_500 http_503 http_404;


    proxy_temp_path  /dev/shm/proxy_temp;
    proxy_cache_path /dev/shm/proxy_cache levels=1:2 keys_zone=cache_one:300m inactive=1d max_size=1g;

    gzip  on;
    gzip_min_length  1k;
    gzip_buffers     16 16k;
    gzip_http_version 1.1;
    gzip_comp_level 2;
    gzip_types       text/plain application/x-javascript text/css application/xml; 
    gzip_vary on;
    
    limit_req_zone \$binary_remote_addr zone=one:10m rate=5r/s;
    limit_conn_zone \$binary_remote_addr zone=addr:10m;
    server_tokens off;  #隐藏nginx的版本号
    server_names_hash_bucket_size 512;

    client_header_buffer_size 256k;
    large_client_header_buffers 4 256k;

    #size limits
    client_max_body_size    50m;
    client_body_buffer_size 256k;
    client_header_timeout   3m;
    client_body_timeout 3m;
    send_timeout   3m;
    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/kis/站点配置文件/*.conf;  #导入相关子配置文件
    include /etc/nginx/kis/站点配置文件/qipaiguanwang/*.conf;  #导入相关子配置文件
}
EOF

cd /sh
#安全日志过滤ip脚本
cat <<EOF >/sh/secure.sh
#!/bin/bash
if [ ! -d /sh ]; then
    mkdir /sh
fi
cd /sh
if [ ! -f biaoji.txt ]; then
    >biaoji.txt
fi
\\cp /var/log/secure /sh/secure
#取值行号
hang=\$(cat biaoji.txt | awk '{print \$1}')
#取值时间
shijian=\$(cat biaoji.txt | awk '{print \$4}')
#对于首次运行，biaoji.txt为空的情况做判断
if [ -z \${hang} ]; then
    \\cp secure secure.log
else
    sed -n \"\${hang}p\" secure | grep \${shijian} >/dev/null
    if [ \$? -eq 0 ]; then
        sed -n \"\${hang},\\\$p\" secure | sed -n '2,\$p' >secure.log
    else
        \\cp secure secure.log
    fi
fi

ip=\$(cat /sh/secure.log | grep from | grep -Ev \"bus|\\)\" | grep -Ev \"58.82.238.95|46.19.166.241|114.199.68.31|directory|socket\" | awk -F\"from\" '{print \$2}' | awk -F\":\" '{print \$1}' | awk -F \" \" '{print \$1}' | sort | uniq)
echo \$ip >>/sh/ip1.txt
sed -i 's/ /\\n/g ' /sh/ip1.txt
cat /sh/ip1.txt | sort | uniq >/sh/ip.txt
rm -rf /sh/ip1.txt

/sbin/iptables -L -n | grep REJECT | awk '{print \$4}' >tmp
sum=\$(cat tmp | wc -l)
index=0
for c in \$(cat tmp); do
    for i in \$(cat /sh/ip.txt); do
        if [[ \"\$c\" == \"\$i\" ]]; then
            let index=\$((index + 1))
        fi
    done
done
if [ \$index -eq \$sum ]; then
    for dif in \$(grep -vf tmp ip.txt); do
        /sbin/iptables -I f2b-SSH 1 -s \$dif -j REJECT
    done
    rm -rf ip.txt
fi

# 判断没有更新日志的情况下保留原来标记
a=\$(cat secure.log | wc -l)
if [ \$a -eq 0 ]; then
    rm -rf secure.log
else
    # 取最后一行，留作下次匹配判断，取值 行号 和 时间
    cat -n secure.log | tail -1 | awk '{print\$1,\$2\"\\t\",\$3,\$4}' >biaoji.txt
fi
rm -rf secure
rm -rf secure.log
rm -rf ip.txt
rm -rf tmp
EOF

#拦截国外ip
echo "#!/bin/bash
mmode=\$1

#下面语句可以单独执行，不需要每次执行都获取网段表
#wget -q --timeout=60 -O- 'https://github.com/17mon/china_ip_list/blob/master/china_ip_list.txt' | grep \"js-file-line\" | awk -F\"\\\"\" '{print \$5}' | awk -F\"<\" '{print \$1}'| awk -F\">\" '{print \$2}' > /sh/china_ssr.txt

CNIP=\"/sh/china_ssr.txt\"


gen_iplist() {
        cat <<-EOF
                \$(cat \${CNIP:=/dev/null} 2>/dev/null)
EOF
}

flush_r() {
iptables  -F ALLCNRULE 2>/dev/null
iptables -D INPUT -p tcp -j ALLCNRULE 2>/dev/null
iptables  -X ALLCNRULE 2>/dev/null
ipset -X allcn 2>/dev/null
}

mstart() {
ipset create allcn hash:net 2>/dev/null
ipset -! -R <<-EOF 
\$(gen_iplist | sed -e \"s/^/add allcn /\")
EOF

iptables -N ALLCNRULE 
iptables -I INPUT -p tcp -j ALLCNRULE 
iptables -A ALLCNRULE -s 127.0.0.0/8 -j RETURN
iptables -A ALLCNRULE -s 114.199.68.42 -j RETURN
iptables -A ALLCNRULE -s 114.199.68.49 -j RETURN
iptables -A ALLCNRULE -s 114.199.68.31 -j RETURN
iptables -A ALLCNRULE -s 46.19.166.139 -j RETURN
iptables -A ALLCNRULE -s 46.19.166.232 -j RETURN
iptables -A ALLCNRULE -s 46.19.166.241 -j RETURN
iptables -A ALLCNRULE -s 58.82.238.95 -j RETURN
iptables -A ALLCNRULE -s 49.213.26.92 -j RETURN
iptables -A ALLCNRULE -s 202.60.236.25 -j RETURN
iptables -A ALLCNRULE -s 202.60.234.56 -j RETURN
iptables -A ALLCNRULE -s 27.124.17.224 -j RETURN
iptables -A ALLCNRULE -s 103.104.105.179 -j RETURN
iptables -A ALLCNRULE -s 118.99.29.25 -j RETURN
iptables -A ALLCNRULE -s 103.104.105.70 -j RETURN
iptables -A ALLCNRULE -s 103.112.28.243 -j RETURN
iptables -A ALLCNRULE -s 192.168.224.0/24 -j RETURN
iptables -A ALLCNRULE -s 47.244.62.17 -j RETURN
#可在此增加你的公网网段，避免调试ipset时出现自己无法访问的情况

iptables -A ALLCNRULE -m set --match-set allcn  src -j RETURN 
iptables -A ALLCNRULE -p tcp -j DROP 


}

if [ \"\$mmode\" == \"stop\" ] ;then
flush_r
exit 0
fi

flush_r
sleep 1
mstart" >/sh/拦截国外ip.sh

#下载国内ip段
wget -q --timeout=60 -O- 'https://github.com/17mon/china_ip_list/blob/master/china_ip_list.txt' | grep "js-file-line" | awk -F"\"" '{print $5}' | awk -F"<" '{print $1}' | awk -F">" '{print $2}' >/sh/china_ssr.txt
#删除空行
sed -i '/^[[:space:]]*$/d' china_ssr.txt

#添加权限
chmod o+x 拦截国外ip.sh secure.sh

cd /script
cat <<EOF >/script/check_failed.sh
#!/bin/bash
LOG_PATH=\"/var/log/secure\"
mon=\$(date +%B)
h=\$(date +%d)
ms=\$(date +%H:%M)
#表示字符开头为0就替换为空
h=\${h/#0/\"\"}
k=\" \"
count=\`grep \"\$h\$k\$ms\" /var/log/secure | grep -c Failed \`

echo \$count
EOF

#增加权限
setfacl -m u:zabbix:r-- /var/log/secure

#zabbix 监控nginx
cat <<EOF >/script/nginx_status.sh
#!/bin/bash

case \$1 in
ping)
     /usr/sbin/pidof nginx |wc -l ;;
active)
     curl -s http://127.0.0.1/nginx_status | awk '/Active/ {print \$3}' ;;
accepts)
     curl -s http://127.0.0.1/nginx_status | awk 'NR==3 {print \$1}' ;;
handled)
     curl -s http://127.0.0.1/nginx_status | awk 'NR==3 {print \$2}' ;;
requests)
     curl -s http://127.0.0.1/nginx_status | awk 'NR==3 {print \$3}' ;;
reading)
     curl -s http://127.0.0.1/nginx_status | awk '/Reading/ {print \$2}' ;;
writing)
     curl -s http://127.0.0.1/nginx_status | awk '/Writing/ {print \$4}' ;;
waiting)
     curl -s http://127.0.0.1/nginx_status | awk '/Waiting/ {print \$6}' ;;
*)
     echo \"Usage: \$0 { ping | active | accepts | handled | requests | reading | writing | waiting }\" ;;
esac 
EOF

#添加权限
chmod o+x nginx_status.sh check_failed.sh

#zabbix 监控
cat <<EOF >/etc/zabbix/zabbix_agentd.d/nginx_status.conf
## Nginx_status
UserParameter=nginx.ping,/script/nginx_status.sh ping
UserParameter=nginx.active,/script/nginx_status.sh active
UserParameter=nginx.accepts,/script/nginx_status.sh accepts
UserParameter=nginx.handled,/script/nginx_status.sh handled
UserParameter=nginx.requests,/script/nginx_status.sh requests
UserParameter=nginx.reading,/script/nginx_status.sh reading
UserParameter=nginx.writing,/script/nginx_status.sh writing
UserParameter=nginx.waiting,/script/nginx_status.sh waiting
EOF

#zabbix监控nginx
cat <<EOF >/etc/nginx/conf.d/nginx_status.conf
server {
        listen       80 ;
        server_name  localhost;
        root         /usr/share/nginx/html;
        
        location /nginx_status {
          stub_status on;
          access_log off;
          allow 127.0.0.1;
          allow 58.82.238.95;
          }

        location /php-fpm_status {
          include       fastcgi_params;
          fastcgi_pass  127.0.0.1:9000;
          fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF

#防暴力破解
cat <<EOF >/etc/fail2ban/jail.d/jail.local
[ssh-iptables]
enabled = true
filter = sshd
# 以空格分隔的列表，可以是 IP 地址、CIDR 前缀或者 DNS 主机名
# 用于指定哪些地址可以忽略 fail2ban 防御
ignoreip = 127.0.0.1 114.199.68.31 46.19.166.241 58.82.238.95 123.59.194.60
# 客户端主机被禁止的时长（秒）,永久封禁 -1
bantime = 86400
# ssh 服务的最大尝试次数
maxretry = 3
# 查找失败次数的时长（秒）
findtime = 600
backend = auto
action = iptables[name=SSH,port=ssh,protocol=tcp]
         mail[name=SSH,dest=cleartly.org@etlgr.com]
# Red Hat 系的发行版
logpath = /var/log/secure

[nginx-get-dos]
enabled = true
#port = http,https
#filter.d/nginx-get-dos.conf 文件名
filter = nginx-get-dos
ignoreip = 127.0.0.1
#需要监控nginx日志log
logpath = /var/log/nginx/access.log
maxretry = 1500
findtime = 60
bantime = 1200
action = iptables-multiport[name=nginx,port=\"http,https,666,888,2018,2019,2020\",protocol=tcp]
         mail[name=nginx,dest=cleartly.org@etlgr.com]
EOF

#nginx-get-dos.conf
cd /etc/fail2ban/filter.d
echo "[Definition]
failregex = <HOST> -.*- .*HTTP/1.* .* .*$
ignoreregex =" >/etc/fail2ban/filter.d/nginx-get-dos.conf

#免密登录
mkdir /root/.ssh/ -p
cat <<EOF >/root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDpnW+HQ+mvWZfL0LCv//luenMp9006yXv8kHM3zXWEt9kc54shnJ8hV2kC4egN7GrV4lLbpH9nB816tQyoNmyRg8TqFCedruBPl39IKZz9g+wd9DwZMnmdfUWOu9xSEtxLGAL2O2rAcSGna+SKVrFOHClD2aJI0xrRgbNnEicUqca0QHYPIM8/1dUUdAjtWVLS2saexMWbQAQlmH9PgmpXJmfqTUBZW6VyhsUYbmFqy0acWNHFSye2icKNTEbme5gVOr7gep7Pvqbp01B3WE5uuqFBghAKRN2BsXovLhb6GZHa6TpjgtBUo8r43p2/Fl17AwRBL0soeYd6AkMxPHAR root@maste_1
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+65VSIXUuMwOUb+yH/SMUSC89sOFaDjFwXfmR/Q2igIHbF6boykg6Y7ER7X/cdX/GaM43evK3HO5Wnr+fKTXSsno4LdnzbXgZ8d1g1Rx+1ZKgkhvwRyVkN1TMJuaBTgkecE//UitXuXZqSGrgzCP72aoy2UrNPjHMo97t4ZYAafrR1DZe2DIyuj29VxOPhBg+aTCVk+urNTwXG2epq8wgiYLgz3JfUA6u+leup91VnMXxUCi4kxS9cllS72mS8CxTmnd7KQuJrhiwshAJ3YT2o9tqoz7ejFwaiDEC4PI60h106RumAsjO9iMssccWCbkOy53HyxcFAq+UDgxSkCJ9 root@lnmpz
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq1MiiY4PevjYcHlOZOElNsnffdrnhgyz/9sq3Zxq+nfodZl76vlbS2jOJe7i3x9GoH3IGSw8ObqcxBbB0kTjOJTIK7eo9qNz1MeOrmgCJUcEPZvwCMMraNP9HNKea8WiUqrXVrVrMteGxi8fm0zv/UaJMFIu088qFoXTB9/262UMoGWD/4cklvqNifAsIjZ3BPL0aRhhHLr1Btg1gBnIXRhCcx0LYuNQvD+ekibI+Kxs5TnEbTcvwRUqxM5fPDW9wDl+earVJqvRS40qC4mzIthCKemITf69Z4pjgAl9R/H68cSeAyCx+xBJvctM9FeB140EEJ4Sv0Jk1Idb2miz+Q==
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3NkyeyeoamnV5wQnHEvM6HMMAjmyJR2kCDNrVWkKTKrYdJPTp10FK8GJnZytA7HkAUxXvFnb7J67Ui6pHb1fsyH4TzBQfxxtz/Cw9xhp/oUTpNyxVP1HbHYQNqE6BaaM9hiP5vPTwXiyG+ZtUc53C2WKYEo9Z/DRTero8n1Y3nP04M8p6EuPL/RKVBaAB7fNFmgWDf8VKPttXFMkOEjRLlDyqsHacw+P3Uws41M9gbj+bGbZsC9Jv5YzBdjQ8VihSJjKbbsFxcGZ7WMrwpF81w9wNDC4gcczddXpF2lxKH/kEe4EdI5PKV6Sn4wvTtjUlZzLNcg9DpGfQFVx/2gTL r6c@JIMUs-Mac-mini.local
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCiFsYd+jfGb+bAXCIAcxvKdVhkMTNFaNvuEmSIuXqtGUaCF0A7Mos/kK5YPpM3HEdDariPjDZBZ1TYROb6U1hX3Rd/yvXhNqt64z5CeDtirBwnU/wanjkkVggibvX/rNRCfpDhW/52FZtW2GCMjGMcP39jHfEodqGthqXXxtzAmdJIt0eViwN6tnVScNX55bJ4csks3qSQg0xvE/X48IqdXUJ0rxDx3YpCkaMUn6gkeXAWErQ0sfBHUtB0wgKxu29A4pVeMDnN0JRpgtjfoMSBcwy4adJzWS23j2DL+2ejJcwdE3Pndcn/3gQs37USwRnUE0rwPDMKFcBu/KoPobVN8r6D5bVGzCz5BUawS45fLmEQlS6sc0Y1zRRC6Qhvh7+9i9jtRthpT1SP2sBqImTBDF9Dsrz0jdzaPIBwJtPuNeRn3b95+eLijeBksybmvUrLOsrrR6NZGNlQE0nYMcx0mnCJLOWEdCHObsMUfsf8VlXwlceJ7V6YaaYbZvklxPM= Jimu
EOF

#iptables 防火墙配置
>/etc/sysconfig/iptables

cat <<EOF >/etc/sysconfig/iptables
# Generated by iptables-save v1.4.21 on Fri Mar  8 05:33:46 2019
*mangle
:PREROUTING ACCEPT [25568030:7819583681]
:INPUT ACCEPT [25567238:7819520276]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [22006815:14799414155]
:POSTROUTING ACCEPT [22002800:14799192913]
COMMIT
# Completed on Fri Mar  8 05:33:46 2019
# Generated by iptables-save v1.4.21 on Fri Mar  8 05:33:46 2019
*nat
:PREROUTING ACCEPT [4473296:305225368]
:INPUT ACCEPT [1154092:66646070]
:OUTPUT ACCEPT [1096531:66230375]
:POSTROUTING ACCEPT [1096531:66230375]
COMMIT
# Completed on Fri Mar  8 05:33:46 2019
# Generated by iptables-save v1.4.21 on Fri Mar  8 05:33:46 2019
*filter
:INPUT DROP [3:234]
:FORWARD ACCEPT [0:0]
:OUTPUT DROP [0:0]
:ALLCNRULE - [0:0]
:f2b-SSH - [0:0]
:f2b-nginx - [0:0]
-A INPUT -s 192.168.224.0/24 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 114.199.68.31/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 46.19.166.241/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 49.213.26.92/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 58.82.202.253/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 58.82.246.106/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 58.82.247.186/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 154.194.255.73/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 58.82.238.95/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 202.60.234.56/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 123.59.194.60/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 154.194.254.176/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -p udp -m multiport --dports 25,53,161 -j ACCEPT
-A INPUT -p udp -m multiport --sports 25,53,161 -j ACCEPT
-A INPUT -p tcp -m multiport --dports 25,80,88,443,666,888,873,2018,2019,2020,2021,9000,10050,10051 -j ACCEPT
-A INPUT -p tcp -m multiport --sports 25,80,88,443,666,888,873,2018,2019,2020,2021,9000,10050,10051 -j ACCEPT
-A INPUT -p tcp -m multiport --dports 81,82,83,91,92,93,2022,2030,2097,2098,2099 -j ACCEPT
-A INPUT -p tcp -m multiport --sports 81,82,83,91,92,93,2022,2030,2097,2098,2099 -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A OUTPUT -p tcp -m state --state ESTABLISHED -j ACCEPT
-A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT
-A OUTPUT -p udp -m state --state ESTABLISHED -j ACCEPT
-A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT
-A OUTPUT -p tcp -m state --state ESTABLISHED -j ACCEPT
-A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT
-A OUTPUT -p icmp -j ACCEPT
COMMIT
# Completed on Fri Mar  8 05:33:46 2019
EOF

# zabbix配置
read -p "请输入zabbix的主机名称，例如：Slave_2_Shanghai_mianbeian ----- 服务器ip:"请按Enter键,继续
read name
ip=$(curl ifconfig.me)
echo $name
echo $ip

sed -i 's/Server=127.0.0.1/Server=58.82.238.95/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive=58.82.238.95/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/Hostname=Zabbix server/Hostname='$name' ----- '$ip'/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# ListenPort=10050/ListenPort=10050/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# HostMetadataItem=/HostMetadataItem=system.uname/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# StartAgents=3/StartAgents=3/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# Timeout=3/Timeout=10/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# UnsafeUserParameters=0/UnsafeUserParameters=1/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# UserParameter=/UserParameter=check_failed,sh \/script\/check_failed.sh/g' /etc/zabbix/zabbix_agentd.conf

# 磁盘更改名称
cat /etc/fstab | grep /home
if [ $? -eq 0 ]; then
    sed -i 's/\/home/\/software/g' /etc/fstab
    umount /home
    mount /dev/mapper/centos-home /software
else
    mkdir /software
fi

#更改服务器密码

expect <<EOF &>/dev/null
spawn passwd root
expect "password:"
send "wuji..!@#\$\shanfeng..\$\#\@\!abc\n"
expect "password:"
send "wuji..!@#\$\shanfeng..\$\#\@\!abc\n"
expect EOF
EOF

#增加颜色

echo "PS1=\"\\[\\e[37;40m\\][\\[\\e[32;40m\\]\\u\\[\\e[37;40m\\]@\\h \\[\\e[35;40m\\]\\W\\[\\e[0m\\]]\\\\\$ \\[\\e[33;40m\\]\"
/root/.bash_login" >> /etc/profile
#计算内存、磁盘

cat <<EOF >/root/.bash_login
#~/.bash_login
echo -e "\nOf course it runs on $(uname -o)\n"
 CPUTIME=$(ps -eo pcpu | awk 'NR>1' | awk '{tot=tot+$1} END {print tot}')
 CPUCORES=$(cat /proc/cpuinfo | grep -c processor)
 echo "
 System Summary (collected $(date))
 - CPU Usage (average)       = $(echo $CPUTIME / $CPUCORES | bc)%
 - Memory free (real)        = $(free -m | head -n 2 | tail -n 1 | awk {'print $4'}) Mb
 - Memory free (cache)       = $(free -m | head -n 2 | tail -n 1 | awk {'print $6'}) Mb
 - Swap in use               = $(free -m | tail -n 1 | awk {'print $3'}) Mb
 - System Uptime             =$(uptime)
 - Disk Space Used           = $(df / | awk '{ a = $5 } END { print a }')"
EOF

chmod o+x /root/.bash_login
source /etc/profile

#修改服务器名称
read -p "请输入服务器名称:"请按Enter键,继续
read name
echo "$name" >/etc/hostname
echo "kernel.hostname = $name" >>/etc/sysctl.conf
sysctl -p

#服务开机自启
 systemctl enable zabbix-agent nginx iptables fail2ban

#修改时间

rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock -w
hwclock -s

#定时任务计划

echo "*/1 * * * * sh /sh/secure.sh" >>/var/spool/cron/root

github="raw.githubusercontent.com/chiakge/Linux-NetSpeed/master"
#检查系统
check_sys() {
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	fi
}

#检查Linux版本
check_version() {
	if [[ -s /etc/redhat-release ]]; then
		version=$(grep -oE "[0-9.]+" /etc/redhat-release | cut -d . -f 1)
	else
		version=$(grep -oE "[0-9.]+" /etc/issue | cut -d . -f 1)
	fi
	bit=$(uname -m)
	if [[ ${bit} == "x86_64" ]]; then
		bit="x64"
	else
		bit="x32"
	fi
}

check_sys_bbrplus() {
	check_version
	if [[ "${release}" == "centos" ]]; then
		if [[ ${version} -ge "6" ]]; then
			installbbrplus
		else
			echo -e "${Error} BBRplus内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${release}" == "debian" ]]; then
		if [[ ${version} -ge "8" ]]; then
			installbbrplus
		else
			echo -e "${Error} BBRplus内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${release}" == "ubuntu" ]]; then
		if [[ ${version} -ge "14" ]]; then
			installbbrplus
		else
			echo -e "${Error} BBRplus内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
		fi
	else
		echo -e "${Error} BBRplus内核不支持当前系统 ${release} ${version} ${bit} !" && exit 1
	fi
}

installbbrplus() {
	kernel_version="4.14.129-bbrplus"
	if [[ "${release}" == "centos" ]]; then
		wget -N --no-check-certificate https://${github}/bbrplus/${release}/${version}/kernel-${kernel_version}.rpm
		yum install -y kernel-${kernel_version}.rpm
		rm -f kernel-${kernel_version}.rpm
		kernel_version="4.14.129_bbrplus" #fix a bug
	elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
		mkdir bbrplus && cd bbrplus
		wget -N --no-check-certificate http://${github}/bbrplus/debian-ubuntu/${bit}/linux-headers-${kernel_version}.deb
		wget -N --no-check-certificate http://${github}/bbrplus/debian-ubuntu/${bit}/linux-image-${kernel_version}.deb
		dpkg -i linux-headers-${kernel_version}.deb
		dpkg -i linux-image-${kernel_version}.deb
		cd .. && rm -rf bbrplus
	fi
	detele_kernel
	BBR_grub
}
#删除多余内核
detele_kernel() {
	if [[ "${release}" == "centos" ]]; then
		rpm_total=$(rpm -qa | grep kernel | grep -v "${kernel_version}" | grep -v "noarch" | wc -l)
		if [ "${rpm_total}" ] >"1"; then
			echo -e "检测到 ${rpm_total} 个其余内核，开始卸载..."
			for ((integer = 1; integer <= ${rpm_total}; integer++)); do
				rpm_del=$(rpm -qa | grep kernel | grep -v "${kernel_version}" | grep -v "noarch" | head -${integer})
				echo -e "开始卸载 ${rpm_del} 内核..."
				rpm --nodeps -e ${rpm_del}
				echo -e "卸载 ${rpm_del} 内核卸载完成，继续..."
			done
			echo --nodeps -e "内核卸载完毕，继续..."
		else
			echo -e " 检测到 内核 数量不正确，请检查 !" && exit 1
		fi
	elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
		deb_total=$(dpkg -l | grep linux-image | awk '{print $2}' | grep -v "${kernel_version}" | wc -l)
		if [ "${deb_total}" ] >"1"; then
			echo -e "检测到 ${deb_total} 个其余内核，开始卸载..."
			for ((integer = 1; integer <= ${deb_total}; integer++)); do
				deb_del=$(dpkg -l | grep linux-image | awk '{print $2}' | grep -v "${kernel_version}" | head -${integer})
				echo -e "开始卸载 ${deb_del} 内核..."
				apt-get purge -y ${deb_del}
				echo -e "卸载 ${deb_del} 内核卸载完成，继续..."
			done
			echo -e "内核卸载完毕，继续..."
		else
			echo -e " 检测到 内核 数量不正确，请检查 !" && exit 1
		fi
	fi
}
#更新引导
BBR_grub() {
	if [[ "${release}" == "centos" ]]; then
		if [[ ${version} == "6" ]]; then
			if [ ! -f "/boot/grub/grub.conf" ]; then
				echo -e "${Error} /boot/grub/grub.conf 找不到，请检查."
				exit 1
			fi
			sed -i 's/^default=.*/default=0/g' /boot/grub/grub.conf
		elif [[ ${version} == "7" ]]; then
			if [ ! -f "/boot/grub2/grub.cfg" ]; then
				echo -e "${Error} /boot/grub2/grub.cfg 找不到，请检查."
				exit 1
			fi
			grub2-set-default 0
		fi
	elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
		/usr/sbin/update-grub
	fi
}
#卸载全部加速
remove_all() {
	rm -rf bbrmod
	sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
	sed -i '/fs.file-max/d' /etc/sysctl.conf
	sed -i '/net.core.rmem_max/d' /etc/sysctl.conf
	sed -i '/net.core.wmem_max/d' /etc/sysctl.conf
	sed -i '/net.core.rmem_default/d' /etc/sysctl.conf
	sed -i '/net.core.wmem_default/d' /etc/sysctl.conf
	sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
	sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_recycle/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_keepalive_time/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_rmem/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_wmem/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_mtu_probing/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
	sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
	sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
	sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
	sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
	if [[ -e /appex/bin/lotServer.sh ]]; then
		bash <(wget --no-check-certificate -qO- https://github.com/MoeClub/lotServer/raw/master/Install.sh) uninstall
	fi
	clear
	echo -e "${Info}:清除加速完成。"
	sleep 1s
}
#启用BBRplus
startbbrplus() {
	remove_all
	echo "net.core.default_qdisc=fq" >>/etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control=bbrplus" >>/etc/sysctl.conf
	echo -e "${Info}BBRplus启动成功！"
}

check_sys
check_version
check_sys_bbrplus
startbbrplus

cat <<EOF >/etc/security/limits.conf
*               soft    nofile           1000000
*               hard    nofile          1000000
EOF

#网络配置优化
sed -i '/fs.file-max/d' /etc/sysctl.conf
sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
cat <<EOF >>/etc/sysctl.conf
fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
# forward ipv4
net.ipv4.ip_forward = 1
EOF
#重启服务器
reboot
