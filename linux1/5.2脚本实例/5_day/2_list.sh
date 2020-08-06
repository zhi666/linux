#!/bin/bash

country () {
    while : ; do
        echo "-------------------"
        echo "$1"
        echo "$2"
        echo "$3"
        echo "$4"
        echo "请选择菜单: (q返回上一层， Q退出)"
        read -p " " num2

        case $num2 in
            q)
                break
                ;;
            Q)
                exit
                ;;
        esac


        case $5 in
            1)
                country "1-1asd" "1-2hgjbvk" "1-3sdf" "1-4sdfs"
                ;;
            2)
                country "2-1asd" "2-2hgjbvk" "2-3sdf" "2-4sdfs"
                ;;
            3)
                country "3-1asd" "3-2hgjbvk" "3-3sdf" "3-4sdfs"
                ;;
            4)
                country "4-1asd" "4-2hgjbvk" "4-3sdf" "4-4sdfs"
                ;;
        esac

    done
}

main () {
    while : ; do
        echo "这是一个简单的小菜单(请输入菜单前面的内容进行选择q/Q)"
        echo "1. 中国"
        echo "2. 美国"
        echo "3. 德国"
        echo "4. 英国"
        read -p "  " num1

        case $num1 in
            1)
                country "    1. 北京" "    2. 上海" "    3. 广州" "    4. 深圳" 1
                ;;
            2)
                country "    1. 华盛顿" "    2. 纽约" "    3. 旧金山" "    4. 拉斯维加斯" 2
                ;;
            3)
                country "    1. 柏林" "    2. 慕尼黑" "    3. 汉堡" "    4. 法兰克福" 3
                ;;
            4)
                country "    1. 伦敦" "    2. 爱丁堡" "    3. 加的夫" "    4. 格拉斯哥" 4
                ;;
            q)
                echo "返回上一层"
                ;;
            Q)
                echo "GG"
                break
                ;;
            *)
                echo "瞎输"
                ;;
        esac
    done
}

main
