#!/bin/bash

check_http() {
  #result=$(curl --retry 3 --retry-max-time 8   -m 15 -s -o /dev/null -w %{http_code}:%{remote_ip} $url)
  result=$(curl  –connect-timeout 8 -m 15 -s -o /dev/null -w "\n"%{http_code}:%{remote_ip}"\n" $url|tail -1)
  sleep 0.3
  #exitcode=$(echo $?)
  status_code=$(echo $result | cut -d : -f 1)
  ip=$(echo $result | cut -d : -f 2)
}

delay() {
	sleep 2
}

dir=/sh
cd $dir
dest=106.12.39.63
cat yuming.txt | tr -s "\r\n" "\n" | sed '/^#/d' | sort >yuming
date=$(date +%Y/%m/%d-%H:%M:%S)
echo "检测时间：$date" >jc_result.log
data=$(cat yuming)
if [ -z "$data" ]; then
	echo "Faild to open yuming!"
	exit 1
fi

tmp_fifofile=/tmp/$$.fifo
# 创建有名管道
[[ -e tmp_fifofile ]] || mkfifo $tmp_fifofile
# 创建文件描述符，以可读（<）可写（>）的方式关联管道文件，这时候文件描述符9就有了有名管道文件的所有特性
exec 9<>$tmp_fifofile
# 关联后的文件描述符拥有管道文件的所有特性,所以这时候管道文件可以删除，我们留下文件描述符来用就可以了
rm -rf $tmp_fifofile
# 并发线程数（总令牌数）
thread=20
for ((i = 0; i < $thread; i++)); do
	echo >&9 # &3代表引用文件描述符3，这条命令代表往管道里面放入了一个"令牌"
done

for url in $data; do
	read -u9 # 代表从管道中读取一个令牌
	{
		{
			check_http
			if [ $status_code -ne 200 ] && [ $status_code -ne 301 ]; then
                                ifempt=$(curl -x "$ip:80" -s -m 2  -w "\n"%{http_code}:%{remote_ip}"\n" $url|grep 301||grep 200)
                                if [ -z "$ifempt" ];then
					echo $url 异常 状态码:$status_code ip:$ip >>jc_result.log
				fi
			fi
		} && delay
		echo >&9 # 命令执行完毕，把令牌放回管道
	} &
done

wait      # 等待上面的命令都执行完毕了再往下执行。
exec 9<&- # 关闭文件描述符的读
exec 9>&- # 关闭文件描述符的写

if [ $(cat jc_result.log | wc -l) -gt 1 ]; then
	mail -s "Slave22苏州——域名监测警报：" yumingmingxi@etlgr.com <jc_result.log
fi

rsync -av --delete /sh/jc_result.log /total/zwj/$(hostname)_jc_result.log || echo | mail -s "$(hostname)传输 jc_result.log 文件失败" systemwarning@etlgr.com
exit 0
