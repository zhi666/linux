[toc]



 ## 一，html获取参数对应不同下载链接

```
</head>
    <script>
    const c = getQueryString("c");
    function getQueryString(name) {
            let reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
            let r = window.location.search.substr(1).match(reg);
            if (r != null) {
                return unescape(r[2]);
            };
            return null;
        }

    function ANDDownSoft() {
            if(c == null) {
                window.location.href = "下载链接1";
            } else if (c == "9PVHH") {
                window.location.href = "下载链接2";
            } else if (c == "qita"){
                window.location.href = "下载链接3";
            } else {
                window.location.href = "下载链接1";
            }
        }
    function IOSDownSoft() {
        if(c == null) {

                window.location.href = "下载链接1";

            } else if (c == "9PVHH") {

                window.location.href = "下载链接2";
            } else{
                window.location.href = "下载链接1";
            }
        }

    </script>
```
调用  图片点击下载链接ios的app

```
<div class="btn">
   <a onclick="IOSDownSoft();"><img src="static/picture/btn.png" alt=""></a>
</div>
```

h5展示三条 获取参数 跳转
```

        <div class="tzbox" >
            <div class="btn1">
                <span class="zdy">站点一</span><a class="ym1">3333.com</a><a class="djjr1" onclick="zdydownload();" target="_blank">点击进入</a>
            </div>
            <div class="btn2">
                <span class="zde">站点二</span><a class="ym2">2222.com</a><a class="djjr2" onclick="zdedownload();"  target="_blank">点击进入</a>
            </div>
            <div class="btn3">
                <span class="zds">站点三</span><a class="ym3">1111.com</a><a class="djjr3" onclick="zdsdownload();" target="_blank">点击进入</a>
            </div>



        <script>
        function zdydownload(){
            var url =  'https://3333.com/register.html' +document.location.search;
            console.log(url);
            window.open(url);
        }
        function zdedownload(){
            var url =  'https://2222.com/register.html' +document.location.search;
            console.log(url);
            window.open(url);
        }
        function zdsdownload(){
            var url =  'https://1111.com/register.html' +document.location.search;
            console.log(url);
            window.open(url);
        }
    </script>
</body>

</html>

```

H5点击跳转加参数

```
<body>
 
<div class="clear"></div>
            <ul>
                <li>
                    <a "https://111" onclick="zdydownload();" target="_blank"><span class="btn-open"></span></a>
                    <span class="ms">站点一</span>
                    <span class="url">111/span>
                </li>
                <li>
                    <a "https://345"  onclick="zdedownload();" target="_blank"><span class="btn-open"></span></a>
                    <span class="ms">站点二</span>
                    <span class="url">345.com</span>
                </li>
                <li>
                    <a "https://234.com" onclick="zdsdownload();" target="_blank"><span class="btn-open"></span></a>
                    <span class="ms">站点三</span>
                    <span class="url">234.com</span>
                </li>
            </ul>
        </div>
 
 
    <script>
        function zdydownload(){
            var url =  'https://2222:8443/#/auth' +document.location.search;
            console.log(url);
            window.open(url);
        }
        function zdedownload(){
            var url =  'https://11112.com:8443/#/auth' +document.location.search;
            console.log(url);
            window.open(url);
        }
        function zdsdownload(){
            var url =  'https://1111.com:8443/#/auth' +document.location.search;
            console.log(url);
            window.open(url);
        }
    </script>
</body>
```



## 二，获取当前输入的url？后面的参数，并自动转入新网站的url参数字符串



### 1,判断C的值，跳转

**只需在`<head>  </head>`之间加上代码和新的网址**

```

 <script>
        const from_gameid = getQueryString("from_gameid");
        const channelCode = getQueryString("channelCode");
        const c = getQueryString("c");
        function getQueryString(name) {
            let reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
            let r = window.location.search.substr(1).match(reg);
            if (r != null) {
                return unescape(r[2]);
            };
            return null;
        }


function DownSoft() {
            if(c == null) {
                window.location.href = "https://www.yichenxiu.com";
            } else if (c != null) {
                window.location.href = "https://www.yichenxiu.com/?c=" + c;
            } 
        }
    </script>

```

###  2,判断from_gameid和channelCode的值，跳转

```
 <script>
        const from_gameid = getQueryString("from_gameid");
        const channelCode = getQueryString("channelCode");

        function getQueryString(name) {
            let reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
            let r = window.location.search.substr(1).match(reg);
            if (r != null) {
                return unescape(r[2]);
            };
            return null;
        }


 function DownSoft() {
            if (from_gameid == null && channelCode == null) {
                window.location.href = "https://www.yichenxiu.com";
            } else if (from_gameid != null && channelCode != null) {
                window.location.href = "https://www.yichenxiu.com/?from_gameid=" + from_gameid + "&channelCode=" + channelCode;
            } else if (from_gameid != null) {
                window.location.href = "https://www.yichenxiu.com/?from_gameid=" + from_gameid;
            } else {
                window.location.href = "https://www.yichenxiu.com/?channelCode=" + channelCode;
            }
        }
    </script>

```

### 3 获取当前uri?后面的所有参数的值都10秒自动跳转

```
<html>
<head>
<title>正在跳转</title>
<meta http-equiv="Content-Language" content="zh-CN">
<meta HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=gb2312">

//主要代码
<script>
  var argsStr = location.search;
  var oMeta = document.createElement('meta');
    oMeta.httpEquiv = 'refresh';
    oMeta.content = '10;url=https://www.yichenxiu.com/'+argsStr;

    document.getElementsByTagName('head')[0].appendChild(oMeta);
</script>

</head>

<body>
<div style="display:none">
<script type="text/javascript">var cnzz_protocol = (("https:" == document.location.protocol) ? "https://" : "http://");document.write(unescape("%3Cspan id='cnzz_stat_icon_1278199398'%3E%3C/span%3E%3Cscript src='" + cnzz_protocol + "s4.cnzz.com/z_stat.php%3Fid%3D1278199398%26show%3Dpic1' type='text/javascript'%3E%3C/script%3E"));</script>
</div>
</body>
</html>
```

