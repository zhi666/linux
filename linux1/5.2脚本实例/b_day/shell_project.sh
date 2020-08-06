#!/bin/bash

NIC_name=$(ifconfig | egrep '^e[a-Z0-9]' | sed -re 's/^([a-Z0-9]+):(.*)/\1/')
net_path="/etc/sysconfig/network-scripts/ifcfg-$NIC_name"

# ------------------------------第一小题---------------------------------------
static_net () {
    echo "DEVICE=$NIC_name"
    echo "BOOTPROTO=static"
    echo "NM_CONTROLLED=no"
    echo "ONBOOT=yes"
    echo "TYPE=Ethernet"
    echo "IPADDR=$ip"
    echo "NETMASK=255.255.255.0"
    echo "GATEWAY=192.168.2.1"
    echo "DNS1=223.5.5.5"
}

add_ip () {
    for i in {2..254}; do
        echo "$i"
        ping -c 1 192.168.2.$i || ip="192.168.2.$i" && break
    done
    sudo ip a add $ip"/24" dev $NIC_name
    sudo chmod 777 $net_path
    static_net > $net_path
    sudo chmod 644 $net_path
    sudo systemctl restart network
}

check_gateWay () {
    Network_segment_third=$(echo "$route" | awk -F "." '{print $3}')
    Network_segment_fourth=$(echo "$route" | awk -F "." '{print $4}')
    ip_third=$(echo "$ip" | awk -F "." '{print $3}')
    (($Network_segment_third == $ip_third)) && (( $Network_segment_fourth == "2" )) \
        && return 0
    sudo ip r del default
    sudo ip r add default via 192.168.2.1
}

checkNet () {
    # ping -c 1 192.168.2.183 &> /dev/null && return 0
    sudo mii-tool $NIC_name | grep "link ok" &> /dev/null
    (($? != 0 )) && echo "你的网线出问题了" && exit
    ip=$(ifconfig $NIC_name | awk 'NR == 2 {print $2}')
    netmask=$(ifconfig $NIC_name | awk 'NR == 2 {print $4}')
    echo "$ip" | egrep '[a-Z]' \
        && echo "-----没有ip， 正在检测能够使用的ip地址-----" && add_ip
    route=$(route -n | grep "UG" | awk '{print $2}')
    test -z $route && sudo ip r add default via 192.168.2.1 || check_gateWay
    ping -c 1 192.168.2.183 || echo "设置已经完成， 不是本机的网络问题， 请联系网络管理员"
}

# ------------------------------第二小题---------------------------------------

check_mount () {
    mount_path="/yw20181119"
    test -d "$mount_path" || sudo mkdir -m 755  $mount_path \
        sudo chown $USER:$USER $mount_path
}

# ------------------------------第三小题---------------------------------------

mount_works () {
    sudo mount 192.168.2.183:/works $mount_path || echo "网络故障，请联系网络管理员"
}

# ------------------------------第四小题---------------------------------------

cp_function_perm () {
    # test -r $1 || echo "请网络管理员加读的权限" && continue
    # echo "$1"" " "$2"" " "$3"
    if ! test -a $1; then
        echo "文件不存在, 请核对后再次输入"
        return 0
    fi
    if test -d $1; then
        test -z $3 || ! grep "r" <<< "$3" &> /dev/null \
            && echo "$1 是文件夹，没有r参数， 请重新输入" && return 0
    fi

    if test -d $2; then
        echo "是文件夹"
        if test -w $2; then
            test -z $3 && cp $1 $2 || cp $1 $2 $3
        else
            echo "$2 不能写入文件， 请跟换地址！！！"
            return 0
        fi
    else
        echo "是文件"
        $2=$(dirname $2)
        if test -w $2; then
            test -z $3 && cp $1 $2 || cp $1 $2 $3
        else
            echo "$2 不能写入文件， 请跟换地址！！！"
            return 0
        fi
    fi
    test -d $2 && test -w $2 && test -z $3 && cp $1 $2 || cp $1 $2 $3
}

cp_function_no () {
    if (("$1" == "get" )); then
        cp_function_perm $answer_second $answer_third
    else
        cp_function_perm $answer_third $answer_second
    fi
}

cp_function_yes () {
    echo "$answer_second" | egrep '^-' &> /dev/null
    if (($? == 0 )); then
        if (("$1" == "get")); then
            cp_function_perm $answer_third $answer_fourth $answer_second
        else
            cp_function_perm $answer_fourth $answer_third $answer_second
        fi
    else
        if (("$1" == "get")); then
            cp_function_perm $answer_second $answer_third $answer_fourth
        else
            cp_function_perm $answer_third $answer_second $answer_fourth
        fi
    fi
}

cp_function () {
    test -z $answer_fourth && cp_function_no $1 || cp_function_yes $1
}

judge_char () {
    for k in {0..61}; do
        if [ $1x == ${rand[$k]}x ]; then
            return 1
        fi
    done
    return 0
}

add_prefix () {
    rand=(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v
        w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)

    path="/tmp/changePrefix.txt"
    j=0
    old=()
    ! test -z "$answer_second"  && [ "$answer_second" != "d" ] \
        && ls "$answer_second" > "$path" || ls > "$path"
    # ls > $path
    len=$(wc -l < $path | awk '{print $1}')
    echo "$len"

    # 获取当前所得到的文件夹下面的所有文件和文件夹的名字， 把它存到一个数组old
    for i in $(seq 1 $len); do
        old[$j]=$(sed -n "${i}p" $path)
        let j++
    done
    n=0
    # let j--
    for i in $(seq 0 $j); do
        # 截取前面的2个字符去判断当前的名字是否有前缀
        first_char=$(echo "${old[$i]}" | sed -nr 's/(.)(.*)/\1/p')
        second_char=$(echo "${old[$i]}" | sed -nr 's/.(.)(.*)/\1/p')
        judge_char $first_char

        if [ $? -eq 1 -a  x$second_char == x"_" ]; then
            if [ x$answer_second == xd -a "${old[$i]}"x != x  ]; then
                new=$(echo "${old[$i]}" | sed -nr 's/..(.*)/\1/p')
                mv "${old[$i]}" "$new"
            fi
            some[$n]=$first_char
            let n++
            continue
        fi
        # echo "${some[*]}"


        # 保存前缀名
        newChar=""
        # 分配再当前文件夹下面不重复的前缀
        for m in {0..61}; do
            if echo ${some[@]} | grep -q ${rand[$m]}; then
                echo -n
            else
                newChar=${rand[$m]}
                some[$n]=${rand[$m]}
                let n++
                break
            fi
        done
        if [ ${newChar}x = x ]; then
            break
        fi
        if [ x$1 != xd -a "${old[$i]}"x != x ]; then
            # mv "${old[$i]}" "${newChar}_${old[$i]}"
            test -z $answer_second && mv "${old[$i]}" "${newChar}_${old[$i]}" \
                || mv "${answer_second}/""${old[$i]}" "${answer_second}/""${newChar}_${old[$i]}"
        fi
    done
}


changePrefix () {
    echo "$answer_second"
    if test -z "$answer_second"; then
        echo "在当目录下添加前缀"
        add_prefix
    else
        if [ "$answer_second" == "d" ]; then
            echo "删除当前目录下面的前缀"
            add_prefix
        else
            echo "在$answer_second""文件下面添加前缀"
            add_prefix
        fi
    fi

}

commands () {
    echo "请输入指令: "
    read -p "  " answer
    answer_first=$(echo "$answer" | awk '{print $1}')
    answer_second=$(echo "$answer" | awk '{print $2}')
    answer_third=$(echo "$answer" | awk '{print $3}')
    answer_fourth=$(echo "$answer" | awk '{print $4}')
    # echo "$answer_first" " " "$answer_second" " " "$answer_third" " " "$answer_fourth"
    case $answer_first in
        Q|q)
            echo "欢迎下次再次使用！！！"
            break
            ;;
        cd)
            cd $answer_second
            ;;
        ls)
            test -z "$answer_second" && ls || ls "$answer_second"
            ;;
        pwd)
            pwd
            ;;
        get)
            cp_function "get"
            ;;
        put)
            cp_function "put"
            ;;
        # changePrefix)
            # echo "changePrefix"
            # ;;
        cf)
            changePrefix
            ;;
        *)
            echo "$answer 是不存在的指令，内部指令为: cd/ls/pwd/get/put/changePrefix/q/Q"
            continue
            ;;
    esac
}

method () {
    while : ; do
       commands
    done
}
main () {
    # 1 检查并修复网络
    # checkNet

    # 2 检测本地的挂载点
    # check_mount

    # 3 挂载
    # mount_works

    # 4 程序主体
    method
}

main
