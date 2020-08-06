#!/bin/bash

# http://www.baidu.com/index.html
# http:/www:163/com/1.html
# http///post.baidu.com/index.html123.html
# http:mp3.taobao.com/xiezi:index.html
# ftp//w.wangyi.com/3..353.353.35...html
# ftp://post1*baidu#com|2.ht.ml



http="http:mp3.taobao.com/xiezi:index.html"

# 按关键字截取

echo
echo "按关键字截取"

http1=${http%%:*}

http2=${http#*:}
http2=${http2%%.*}

http3=${http#*.}
http3=${http3%%.*}

http4=${http%%/*}
http4=${http4##*.}

http5=${http#*/}
http5=${http5%%:*}

http6=${http##*:}
http6=${http6%%.*}

http7=${http##*.}

echo "$http1 $http2 $http3 $http4 $http5 $http6 $http7"

echo "---------------------------------------------------------------------"

# 按截取

echo
echo "按位置截取"

# http="http:mp3.taobao.com/xiezi:index.html"

echo "${http:0:4} ${http:5:3} ${http:9:6} ${http:16:3} ${http:20:5} ${http:26:5} ${http:32:4}"
