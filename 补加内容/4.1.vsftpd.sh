#!/bin/sh

users=/etc/vsftpd/vftpuser.txt #账号配置文件
login=/etc/vsftpd/vftpuser.db  #账号数据库文件
generate_db="db_load -T -t hash -f $users $login"
virtual_user_config=/etc/vsftpd/vuser_conf
virtual_user_home=/data/wwwroot #ftp根目录位置
guest_username=www              #指定ftp权限账号

#Source function library
. /etc/rc.d/init.d/functions

install_vsftpd() {
    setenforce 0
    yum -y install db4-utils
    yum -y install vsftpd
    systemctl enable vsftpd

    useradd -s /sbin/nologin ${guest_username}

    mv /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
    cat >/etc/vsftpd/vsftpd.conf <<EOF
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
pasv_enable=YES
pasv_min_port=60000
pasv_max_port=61000
xferlog_std_format=YES
listen=YES
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES

chroot_local_user=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd/chroot_list

pam_service_name=vsftpd
guest_enable=YES
guest_username=${guest_username}
user_config_dir=/etc/vsftpd/vuser_conf
allow_writeable_chroot=YES
EOF

    mkdir /etc/vsftpd/vuser_conf
    mkdir /etc/vsftpd/chroot_list

    #i386 32位系统打开下列两行
    #echo 'auth required pam_userdb.so db=/etc/vsftpd/vftpuser' > /etc/pam.d/vsftpd
    #echo 'account required pam_userdb.so db=/etc/vsftpd/vftpuser' >> /etc/pam.d/vsftpd

    #X64 64位系统打开下列两行
    echo 'auth required /lib64/security/pam_userdb.so db=/etc/vsftpd/vftpuser' >/etc/pam.d/vsftpd
    echo 'account required /lib64/security/pam_userdb.so db=/etc/vsftpd/vftpuser' >>/etc/pam.d/vsftpd

    touch /etc/vsftpd/vftpuser.txt

    systemctl restart vsftpd
    [ $? -eq 0 ] && action $"Install vsftp:" /bin/true || action $"Install vsftp:" /bin/false
    #开启防火墙，21连接端口，60000-61000为被动模式数据传输端口
    iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 21 -j ACCEPT
    iptables -A INPUT -p tcp --dport 60000:61000 -j ACCEPT
    iptables-save >/etc/sysconfig/iptables
}

add_user() {
    not_enough_parameter=56
    retval=0

    if [ "$#" -ne 2 ]; then
        echo "usage:$(basename $0) <useradd> <user_name> <password>."
        exit $not_enough_parameter
    fi

    if grep -q "$1" "$users"; then
        passwd=$(sed -n "/$1/{n;p;}" "$users")
        if [ "$passwd" = "$2" ]; then
            echo "the user $1 already exists."
            exit $retval
        else
            echo "updating $1's password ... "
            sed -i "/$1/{n;s/$passwd/$2/;}" "$users"
            eval "$generate_db"
            exit $retval
        fi
    fi

    for i in "$1" "$2"; do
        echo "$i" >>"$users"
    done

    eval "$generate_db"

    cat >>"$virtual_user_config"/"$1" <<EOF
local_root=$virtual_user_home/$1
write_enable=YES
download_enable=YES
anon_world_readable_only=NO
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
local_umask=022
EOF

    mkdir "$virtual_user_home"/"$1" -p
    chown $guest_username "$virtual_user_home"/"$1"

    echo "==========$users============"
    cat $users
}

case "$1" in
'install')
    install_vsftpd
    ;;
'useradd')
    add_user $2 $3
    ;;
*)
    echo "usage: $0 {install|useradd}"
    exit 1
    ;;
esac
