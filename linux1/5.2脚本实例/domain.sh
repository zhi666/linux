#!/bin/bash
#author anan
script_dir=$(cd $(dirname "$0") && pwd)

echo "检测时间是`date +"%Y-%m-%d-%R"`" >${script_dir}/确定有问题状态码.txt
cat ${script_dir}/domain_ssl.info |while read line;do

    jc=`curl https://api.66mz8.com/api/http.code.php?url=https://${line}|egrep  '(\<http_code\>)'| egrep -o '(\<[0-9]{1,3}\>)'`

    if [ $jc -eq 200 ] || [ $jc -eq 301 ] || [ $jc -eq 302 ];then echo "检测的域名是: ${line}  状态码是: ${jc} " >> ${script_dir}/正确状态码.txt
    
    else  
 
      echo "检测存在问题的域名是: ${line} 状态码是 ${jc}" >>/${script_dir}/可能存在问题状态码.txt
    
    fi

done


cat ${script_dir}/可能存在问题状态码.txt | egrep  '(状态码是 [0-9]{1,3})' >>${script_dir}/确定有问题状态码.txt
 
sed -i -e '/\(状态码是 [0-9]\{1,3\}\)/d' ${script_dir}/可能存在问题状态码.txt
sed -i 's/检测存在问题的域名是: //g' ${script_dir}/可能存在问题状态码.txt 
sed -i 's/ 状态码是//g' ${script_dir}/可能存在问题状态码.txt

cat ${script_dir}/可能存在问题状态码.txt | while read line1;do

    code=`curl https://tool.chinaz.com/pagestatus/?url=https%3A%2F%2F${line1}| egrep -o '(<span>[0-9]{1,4}</span>)'|egrep -o '([0-9]{1,4})'`

    if [ $code -eq 200 ] || [ $code -eq 301 ] || [ $code -eq 302 ];then 

	echo "检测存在问题的域名是 ${line1} 状态码是: ${code}" >>${script_dir}/china无问题状态码.txt

    else 

      echo "检测存在问题的域名是 ${line1} 状态码是: ${code}" >>${script_dir}/确定有问题状态码.txt 

    fi

done

    echo "如果出现状态码为空的请手动测试! 已经两个接口测试了。" >>${script_dir}/确定有问题状态码.txt

sh ${script_dir}/message.sh
