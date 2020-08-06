#!/bin/bash

clean_sys() {
    #清环境
    systemctl disable firewalld
    systemctl stop firewalld
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
}

init() {
    yum update -y
    #安装epel源
    yum install -y epel-release
    #安装软件
    yum install -y vim mailx ntp bash-completion lsof wget iptables* bc mailx openresty-resty openresty openresty-opm fail2ban unzip google-authenticator expect lrzsz iftop net-tools rsync
    #创建相关目录
    mkdir /sh -p

    #增加颜色
    cat <<EOF >>/etc/profile
PS1="\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\w\[\e[0m\]]\\$ "
/root/.bash_login
EOF

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
    chmod o+x /root
    source /etc/profile
}

init_nginx() {
    #启用openresty源
    yum install yum-utils -y
    yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo
    #安装软件
    yum install -y openresty-resty openresty openresty-opm
}

init_nginx_conf() {
    #导入nginx主配置
    cat <<EOF >/usr/local/openresty/nginx/conf/nginx.conf
user    root;
worker_processes  auto;

error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

pid        logs/nginx.pid;

events {
    use epoll;
    worker_connections  65535;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format  main  '[\$time_local] \$http_host "\$request" \$remote_addr \$remote_user '
                      '\$status \$body_bytes_sent "\$http_referer" "\$http_user_agent" '
                      '"\$http_x_forwarded_for" \$request_time \$upstream_response_time '
                      '"\$upstream_addr" \$upstream_status';

    access_log  logs/access.log  main;

    limit_req_zone \$cookie_token zone=session_limit:3m rate=1r/s;
    limit_req_zone \$binary_remote_addr zone=auth_limit:3m rate=1r/m;

    server_names_hash_bucket_size 2048;

    sendfile        on;
    tcp_nopush      on;
    tcp_nodelay     on;

    # keep alive
    keepalive_timeout   65;
    keepalive_requests  100000;

    # hide server tag
    server_tokens   off;
    etag    off;
    proxy_hide_header   X-Powered-By;
    more_clear_headers  'Server';
    more_clear_headers  'Last-Modified';

    # buffer size
    client_body_buffer_size     128k;
    client_max_body_size        0;
    client_header_buffer_size   1k;
    large_client_header_buffers 4   4k;
    output_buffers              1   32k;
    postpone_output             1460;

    # timeouts
    #client_header_timeout  3m;
    #client_body_timeout    3m;
    #send_timeout           3m;

    # gzip
    gzip              on;
    gzip_comp_level   2;
    gzip_proxied      any;
    gzip_min_length   1100;
    gzip_buffers      16 8k;
    gzip_types        application/x-javascript text/css application/javascript text/javascript text/plain text/xml application/json application/vnd.ms-fontobject application/x-font-opentype application/x-font-truetype application/x-font-ttf application/xml font/eot font/opentype font/otf image/svg+xml image/vnd.microsoft.icon;

    include /software/站点配置文件/*.conf;
    include /etc/nginx/conf.d/*.conf;
    include /software/站点配置文件/qipaiguanwang/*.conf;
    include /usr/local/openresty/nginx/conf/conf.d/*.conf;
}
EOF
    ln -s /usr/local/openresty/nginx /etc/nginx
    # ln -s /usr/local/openresty/bin/openresty /usr/bin/nginx
    mkdir /etc/nginx/conf/conf.d -p

    #zabbix监控nginx
    cat <<EOF >/etc/nginx/conf/conf.d/nginx_status.conf
server {
    listen 80;
    server_name localhost;
    location = /basic_status {
        access_log off;
        stub_status;
        allow 127.0.0.1;
        deny all;
    }
}
EOF
    # 日志轮转
    cat <<EOF >/etc/logrotate.d/nginx
/etc/nginx/logs/*log {
    daily
    rotate 10
    missingok
    notifempty
    compress
    sharedscripts
    dateext
    postrotate
        [ ! -f /usr/local/openresty/nginx/logs/nginx.pid ] || /bin/kill -USR1 `cat /usr/local/openresty/nginx/logs/nginx.pid 2>/dev/null` 2>/dev/null || true
    endscript
}
EOF

    systemctl start openresty
    systemctl enable openresty
}

init_ip_secure() {
    cd /sh
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
iptables -A ALLCNRULE -s 47.244.62.17 -j RETURN
iptables -A ALLCNRULE -s 49.213.26.92 -j RETURN
iptables -A ALLCNRULE -s 202.60.236.25 -j RETURN
iptables -A ALLCNRULE -s 202.60.234.56 -j RETURN
iptables -A ALLCNRULE -s 27.124.17.224 -j RETURN
iptables -A ALLCNRULE -s 103.104.105.179 -j RETURN
iptables -A ALLCNRULE -s 118.99.29.25 -j RETURN
iptables -A ALLCNRULE -s 103.104.105.70 -j RETURN
iptables -A ALLCNRULE -s 103.112.28.243 -j RETURN
iptables -A ALLCNRULE -s 162.247.4.225 -j RETURN
iptables -A ALLCNRULE -s 47.244.41.255 -j RETURN
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
    chmod o+x 拦截国外ip.sh

}

init_f2b() {
    #防暴力破解
    cat <<EOF >/etc/fail2ban/jail.d/jail.local
[ssh-iptables]
enabled = true
filter = sshd
# 以空格分隔的列表，可以是 IP 地址、CIDR 前缀或者 DNS 主机名
# 用于指定哪些地址可以忽略 fail2ban 防御
ignoreip = 127.0.0.1 114.199.68.31 46.19.166.241 47.244.62.17 162.247.4.225
# 客户端主机被禁止的时长（秒）,永久封禁 -1
bantime = 86400
# ssh 服务的最大尝试次数
maxretry = 3
# 查找失败次数的时长（秒）
findtime = 600
backend = auto
action = iptables[name=SSH,port=ssh,protocol=tcp]
         mail[name=SSH,dest=cleartly.org@etlgr.com,sender=fail2ban@email.com]
# Red Hat 系的发行版
logpath = /var/log/secure
EOF
}

init_ssh() {
    #免密登录
    mkdir /root/.ssh/ -p
    cat <<EOF >/root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDpnW+HQ+mvWZfL0LCv//luenMp9006yXv8kHM3zXWEt9kc54shnJ8hV2kC4egN7GrV4lLbpH9nB816tQyoNmyRg8TqFCedruBPl39IKZz9g+wd9DwZMnmdfUWOu9xSEtxLGAL2O2rAcSGna+SKVrFOHClD2aJI0xrRgbNnEicUqca0QHYPIM8/1dUUdAjtWVLS2saexMWbQAQlmH9PgmpXJmfqTUBZW6VyhsUYbmFqy0acWNHFSye2icKNTEbme5gVOr7gep7Pvqbp01B3WE5uuqFBghAKRN2BsXovLhb6GZHa6TpjgtBUo8r43p2/Fl17AwRBL0soeYd6AkMxPHAR root@maste_1
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQClROWcKX7Xw8T2XTvGOqK+uxFn+tru8+s0YDjV9FZpXsn/RMu9i51tNDgDoDdHppTkY9zRWqDm787915ZWLbCeLwOv4O1Bae8zceLzuvyOLqpRxHHyhJS2CWlupkChrG2+mhWgJ7lBhyAor+BE+ddGVg3pNz1cI0MrprC5A6YUOeLIHGcEmcbLeNf5vDXbjoInsYVhv05bujTck9iYSVVhMcVrAfctv/Ff2uWxDhZ3w8N4kPicGSVFhhQTW85gxZBR/4PQaHFKohI4HPBrdU2SHGHzW+zfwXTu2q7/Hya+TJ4kcRYGqGEqwaC9pUPW8JiMcETjT2Ek6HoOD9MvoTa3 docker推送
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq1MiiY4PevjYcHlOZOElNsnffdrnhgyz/9sq3Zxq+nfodZl76vlbS2jOJe7i3x9GoH3IGSw8ObqcxBbB0kTjOJTIK7eo9qNz1MeOrmgCJUcEPZvwCMMraNP9HNKea8WiUqrXVrVrMteGxi8fm0zv/UaJMFIu088qFoXTB9/262UMoGWD/4cklvqNifAsIjZ3BPL0aRhhHLr1Btg1gBnIXRhCcx0LYuNQvD+ekibI+Kxs5TnEbTcvwRUqxM5fPDW9wDl+earVJqvRS40qC4mzIthCKemITf69Z4pjgAl9R/H68cSeAyCx+xBJvctM9FeB140EEJ4Sv0Jk1Idb2miz+Q==
EOF
}

init_iptables() {
    #iptables 防火墙配置
    >/etc/sysconfig/iptables
    cat <<EOF >/etc/sysconfig/iptables
# Generated by iptables-save v1.4.21 on Mon Nov  4 11:28:30 2019
*mangle
:PREROUTING ACCEPT [203:20110]
:INPUT ACCEPT [202:19782]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [184:41853]
:POSTROUTING ACCEPT [184:41853]
COMMIT
# Completed on Mon Nov  4 11:28:30 2019
# Generated by iptables-save v1.4.21 on Mon Nov  4 11:28:30 2019
*nat
:PREROUTING ACCEPT [25:1576]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [82:5343]
:POSTROUTING ACCEPT [82:5343]
COMMIT
# Completed on Mon Nov  4 11:28:30 2019
# Generated by iptables-save v1.4.21 on Mon Nov  4 11:28:30 2019
*filter
:INPUT DROP [24:1248]
:FORWARD ACCEPT [0:0]
:OUTPUT DROP [0:0]
:ALLCNRULE - [0:0]
:f2b-SSH - [0:0]
:f2b-nginx - [0:0]
-A INPUT -p tcp -m tcp --dport 22 -j f2b-SSH
-A INPUT -s 127.0.0.1/32 -j ACCEPT
-A INPUT -s 162.247.4.225/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 47.244.41.255/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 114.199.68.31/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 46.19.166.241/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 49.213.26.92/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 58.82.202.253/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 58.82.246.106/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 58.82.247.186/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 154.194.255.73/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 47.244.62.17/32 -p tcp -m multiport --dports 22,10050 -j ACCEPT
-A INPUT -s 202.60.234.56/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 123.59.194.60/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -s 154.194.254.176/32 -p tcp -m multiport --dports 22 -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
-A f2b-SSH -j RETURN
COMMIT
# Completed on Mon Nov  4 11:28:30 2019
EOF
}

init_zabbix() {
    #安装zabbix源
    # CentOS7
    rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
    # CentOS8
    # rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
    # 原版Agent
    # yum -y install zabbix-agent
    # Go版Agent
    yum -y install zabbix-agent2
    # zabbix配置
    read -p "请输入zabbix的主机名称，例如：Slave_2_Shanghai_mianbeian ----- 服务器ip:"请按Enter键,继续
    read name
    ip=$(curl -s checkip.dyndns.org | sed 's/.*IP Address: \([0-9\.]*\).*/\1/g')

    # Go版Agent /etc/zabbix/zabbix_agent2.conf 原版 /etc/zabbix/zabbix_agentd.conf
    sed -i 's/Server=127.0.0.1/Server=47.244.62.17/g' /etc/zabbix/zabbix_agent2.conf
    sed -i 's/ServerActive=127.0.0.1/ServerActive=47.244.62.17/g' /etc/zabbix/zabbix_agent2.conf
    sed -i "s/Hostname=Zabbix server/Hostname=$name ----- $ip/g" /etc/zabbix/zabbix_agent2.conf
    #sed -i 's/# ListenPort=10050/ListenPort=10050/g' /etc/zabbix/zabbix_agent2.conf
    sed -i 's/# HostMetadataItem=/HostMetadataItem=system.uname/g' /etc/zabbix/zabbix_agent2.conf
    # sed -i 's/# HostMetadata=/HostMetadata=xxx/g' /etc/zabbix/zabbix_agent2.conf
    # sed -i 's/# StartAgents=3/StartAgents=3/g' /etc/zabbix/zabbix_agentd.conf
    # sed -i 's/# Timeout=3/Timeout=10/g' /etc/zabbix/zabbix_agentd.conf
}

init_fstab() {
    # 磁盘更改名称
    cat /etc/fstab | grep /home
    if [ $? -eq 0 ]; then
        sed -i 's/\/home/\/software/g' /etc/fstab
        umount /home
        mount /dev/mapper/centos-home /software
    else
        mkdir /software
    fi
}

init_passwd() {
    #更改服务器密码
    expect <<EOF &>/dev/null
spawn passwd root
expect "password:"
send "wuji..!@#\$\shanfeng..\$\#\@\!abc\n"
expect "password:"
send "wuji..!@#\$\shanfeng..\$\#\@\!abc\n"
expect EOF
EOF
}

init_hostname() {
    #修改服务器名称
    read -p "请输入服务器名称:"请按Enter键,继续
    read name
    echo "$name" >/etc/hostname
    echo "kernel.hostname = $name" >>/etc/sysctl.conf
    sysctl -p
}

init_enable() {
    #服务开机自启
    systemctl enable zabbix-agent2 iptables fail2ban
    systemctl start zabbix-agent2 iptables fail2ban
}

init_sync_time() {
    #修改时间
    rm -rf /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    ntpdate time.windows.com
    hwclock -w
    hwclock -s
}

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

enableBBR() {
    check_sys
    check_version
    check_sys_bbrplus
    startbbrplus
}

net_optimize() {
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
}

#清环境
clean_sys
#安装基础软件
init
# 安装nginx
init_nginx
#nginx配置
init_nginx_conf
#拦截国外ip
init_ip_secure
#防火墙
init_iptables
#ssh公钥
init_ssh
#f2b
init_f2b
#zabbix自动注册
init_zabbix
#更改硬盘名
# init_fstab
#更改服务器密码
init_passwd
#更改主机名
init_hostname
#系统时间同步
init_sync_time
#服务开机自启
init_enable
#网络配置优化
net_optimize

#启用bbr
# enableBBR

sed -i 's:/usr/libexec/openssh/sftp-server:internal-sftp:g' /etc/ssh/sshd_config
systemctl restart sshd
#重启服务器
reboot
