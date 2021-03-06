#!/bin/bash

#PPP14
    # 输入编码选择检测输入的类型
        # 1. 检测输入的是否是纯数字
        # 2. 检测输入的是否是纯字母
        # 3. 测试字符串是否纯小写
        # 4. 测试字符串是否纯大写
        # 5. 检测输入的是否是电子邮箱
        # 6. 检测输入的是否是手机号码
        # 7. 测试字符串是否非负整数
        # 8. 测试字符串是否正整数
        # 9. 测试字符串是否负整数
        # 10. 测试字符串是否整数
        # 11. 测试字符串是否小数
        # 12. 测试字符串是否只包含字母、数字、下划线，而且不以数字开头
    # 输入q/Q就提示， 然后退出
    # 输入的不是q/Q/1/2/3/4/5/6/7/8/9/10/11/12就提示输错了，重输
    # 输入编码之后， 提示用户输入要检测的字符串
    # 输入完成之后给结果
    # 输入编码选择检测输入的类型(按q/Q退出)

space="---------------------------------"
state=0

judge () {
    echo "$space"
    echo "$str" | egrep "$1"
    [ "$?" == "0" ] && is_sure="\"是\"" || is_sure="\"不是\""
    echo -e "\t$example""$is_sure""$2"
    echo "$space"
}

while : ; do
    [ "$state" != 0 ] && exits="(按q/Q退出)"
    echo "输入编码选择检测输入的类型$exits"
    echo "1. 检测输入的是否是纯数字"
    echo "2. 检测输入的是否是纯字母"
    echo "3. 测试字符串是否纯小写"
    echo "4. 测试字符串是否纯大写"
    echo "5. 检测输入的是否是电子邮箱"
    echo "6. 检测输入的是否是手机号码"
    echo "7. 测试字符串是否非负整数"
    echo "8. 测试字符串是否正整数"
    echo "9. 测试字符串是否负整数"
    echo "10. 测试字符串是否整数"
    echo "11. 测试字符串是否小数"
    echo "12. 测试字符串是否只包含字母、数字、下划线，而且不以数字开头"
    read -p "  " answer

    if [ "$answer" == "q" -o "$answer" == "Q" ]; then
        echo -e "$space"
        echo -e "\t欢迎使用， 期待下次的相遇"
        echo -e "$space"
        exit 0
    fi

    egrep '^(1|2|3|4|5|6|7|8|9|10|11|12)$' <<< $answer

    if [ "$?" != "0" ]; then
        echo -e "$space"
        echo -e "\t请输入正确的编码"
        echo -e "$space"
        continue
    fi

    echo "请输入要测试的字符串: "
    read -p " " str

    example="你输入的字符串"
    case "$answer" in

        1)
            # echo "$space"
            # echo "$str" | egrep '^[0-9]+$'
            # [ "$?" == "0" ] && echo "是" || echo "不是"

            # echo "$space"
            judge '^[0-9]+$' "纯数字"
            ;;
        2)
            judge '^[a-Z]+$' "纯字母" ;;
        3)
            judge '^[a-z]+$' "纯小写" ;;
        4)
            judge '^[A-Z]+$' "纯大写" ;;
        5)
            judge '^[0-9a-Z_]+@[0-9a-Z]+\.[(com)|(cn)|(net)|(HK)|(TW)|(hk)]+$' "电子邮箱";;
        6)
            judge '^1[3-9][0-9]{9}$' "手机号码" ;;
        7)
            judge '^[0-9]+$' "非负整数" ;;
        8)
            judge '^[1-9][0-9]*$' "正整数" ;;
        9)
            judge '^-[1-9][0-9]*$' "负整数" ;;
        10)
            judge '^(-?[1-9][0-9]*)$' "整数" ;;
        11)
            judge '^-?[0-9]+\.[0-9]+$' "小数" ;;
        12)
            judge '^[a-Z_]+[a-Z0-9_]*$' "只包含字母、数字、下划线，而且不以数字开头" ;;
        *)
            echo "其他"
            ;;
    esac
    [ $state == 0 ] && let state+=1
done
