#!/bin/bash
###证书到期检测
#author 阿南

script_dir=$( cd $(dirname "$0") && pwd )

which ssl-cert-check >>/dev/null

if [ $? -ne 0 ];then wget -P ${script_dir}/ssl-check https://raw.githubusercontent.com/Matty9191/ssl-cert-check/master/ssl-cert-check  && cd ${script_dir}/ssl-check/ && chmod +x ssl-cert-check && ln -s ${script_dir}/ssl-check/ssl-cert-check /usr/bin/ ;fi

cat ${script_dir}/domain_ssl.info >>/dev/null

if [ $? -ne 0 ];then find / -name domain_ssl.info -exec \cp -rf {} ${script_dir}/ \; ;fi

cat ${script_dir}/domain_ssl.info >> /dev/null 

if [ $? -eq 0 ];then  echo -e 检测时间: $(date +'%Y-%m-%d  %R') > ${script_dir}/jc.txt  && echo -e "\n " >> ${script_dir}/jc.txt ;fi 

cat ${script_dir}/domain_ssl.info |while read line;do

ssl-cert-check -i -s ${line} -p 443 >>${script_dir}/未过滤.txt

done

#开始过滤

egrep '(-[0-9]{4,10})' ${script_dir}/未过滤.txt  |awk '{print $1}' > ${script_dir}/被墙或没有证书 && sed -i "s#:443##g" ${script_dir}/被墙或没有证书 

egrep 'Unable' ${script_dir}/未过滤.txt |awk '{print $1}' > ${script_dir}/没有dns解析 && sed -i "s#:443##g" ${script_dir}/没有dns解析

egrep '(ERROR)' ${script_dir}/未过滤.txt |egrep '(for)' |awk '{print $10}' > ${script_dir}/无法正常访问 && sed -i "s#:443##g" ${script_dir}/无法正常访问

egrep -v '(-[0-9]{4,10}|Unable|ERROR)' ${script_dir}/未过滤.txt  | egrep '([0-9]{1,4})'| awk  ' {print "域名:"$1,"证书剩余过期天数"$8" 天"}' >> ${script_dir}/jc.txt && sed -i "s#:443##g" ${script_dir}/jc.txt


n1=`wc -l ${script_dir}/jc.txt |awk '{print $1}'`
n2=4

head -`expr ${n1} - ${n2}` ${script_dir}/jc.txt | while read line;do

    number=` echo $line |awk '{print $2}' |egrep -o '([0-9]{1,3})'`
    if [ $number -lt 20 ];then echo  " ${line}" >> ${script_dir}/zjjc.txt;fi
done


sh ${script_dir}/message.sh
