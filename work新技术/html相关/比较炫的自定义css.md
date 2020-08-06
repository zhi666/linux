

#  各种handsome主题改动集合



## 1.比较炫的自定义css




```
*首页文章版式圆角化*/
.panel{
    border: none;
    border-radius: 15px;
}

.panel-small{
    border: none;
    border-radius: 15px;
}

.item-thumb{
    border-radius: 15px;  
}
/*首页文章图片获取焦点放大*/
.item-thumb{
    cursor: pointer;  
    transition: all 0.6s;  
}

.item-thumb:hover{
      transform: scale(1.05);  
}

.item-thumb-small{
    cursor: pointer;  
    transition: all 0.6s;
}

.item-thumb-small:hover{
    transform: scale(1.05);
}

/*首页头像自动旋转*/
.thumb-lg{
    width:66px;
}

.avatar{
    -webkit-transition: 0.4s;
    -webkit-transition: -webkit-transform 0.4s ease-out;
    transition: transform 0.4s ease-out;
    -moz-transition: -moz-transform 0.4s ease-out; 
}

.avatar:hover{
    transform: rotateZ(360deg);
    -webkit-transform: rotateZ(360deg);
    -moz-transform: rotateZ(360deg);
}

#aside-user span.avatar{
    animation-timing-function:cubic-bezier(0,0,.07,1)!important;
    border:0 solid
}

#aside-user span.avatar:hover{
    transform:rotate(360deg) scale(1.2);
    border-width:5px;
    animation:avatar .5s
}

/*首页头像放大并自动旋转
.thumb-lg{
    width:66px;
}

@-webkit-keyframes rotation{
    from {
        -webkit-transform: rotate(0deg);
    }
    to {
        -webkit-transform: rotate(360deg);
    }
}

.img-full{
    -webkit-transform: rotate(360deg);
    animation: rotation 3s linear infinite;
    -moz-animation: rotation 3s linear infinite;
    -webkit-animation: rotation 3s linear infinite;
    -o-animation: rotation 3s linear infinite;
}
/*文章标题居中*/
.panel h2{
    text-align: center; 
}
.post-item-foot-icon{
    text-align: center;
}
*/


/*panel阴影*/
.panel{
   box-shadow: 1px 1px 5px 5px rgba(255, 112, 173, 0.35);
    -moz-box-shadow: 1px 1px 5px 5px rgba(255, 112, 173, 0.35);
}

.panel:hover{
    box-shadow: 1px 1px 5px 5px rgba(255, 112, 173, 0.35);
    -moz-box-shadow: 1px 1px 5px 5px rgba(255, 112, 173, 0.35);
}

.panel-small{
    box-shadow: 1px 1px 5px 5px rgba(255, 112, 173, 0.35);
    -moz-box-shadow: 1px 1px 5px 5px rgba(255, 112, 173, 0.35);
}

.panel-small:hover{
    box-shadow: 1px 1px 5px 5px rgba(255, 112, 173, 0.35);
    -moz-box-shadow: 1px 1px 5px 5px rgba(255, 112, 173, 0.35);
}

/*如果也想使盒子四周也有阴影，加上以下代码*/
.app.container {
    box-shadow: 0 0 30px rgba(255, 112, 173, 0.35);
}
/*定义滚动条高宽及背景 高宽分别对应横竖滚动条的尺寸*/
::-webkit-scrollbar{
    width: 3px;
    height: 16px;
    background-color: rgba(255,255,255,0);
}
 
/*定义滚动条轨道 内阴影+圆角*/
::-webkit-scrollbar-track{
    -webkit-box-shadow: inset 0 0 6px rgba(0,0,0,0.3);
    border-radius: 10px;
    background-color: rgba(255,255,255,0);
}
 
/*定义滑块 内阴影+圆角*/
::-webkit-scrollbar-thumb{
    border-radius: 10px;
    -webkit-box-shadow: inset 0 0 6px rgba(0,0,0,.3);
    background-color: #555;
}


/*文章内打赏图标跳动*/
.btn-pay {
    animation: star 0.5s ease-in-out infinite alternate;
}

@keyframes star {
    from {
        transform: scale(1);
    }

    to {
        transform: scale(1.1);
    }
}
```

## 2.qq链接
```
<div style="border:0px black solid;text-align:right">
<a  target="_blank" href="http://sighttp.qq.com/authd?IDKEY=7d3cffa8a4fe2045d40496043a0f5525b61d8a5006bc7dde"><img border="0"  src="https://wohenliu.com/tupian/tubiao/3动timg.gif" alt="点击这里给我发消息" title="点击这里给我发消息"/></a> </div>

QQ链接
```
## 3.9、鼠标点击特效
将以下代码放在主题的handsome/component/footer.php中的</body>之前即可。
```
<script type="text/javascript"> 
/* 鼠标特效 */
var a_idx = 0; 
jQuery(document).ready(function($) { 
    $("body").click(function(e) { 
        var a = new Array("富强", "民主", "文明", "和谐", "自由", "平等", "公正" ,"法治", "爱国", "敬业", "诚信", "友善"); 
        var $i = $("<span/>").text(a[a_idx]); 
        a_idx = (a_idx + 1) % a.length; 
        var x = e.pageX, 
        y = e.pageY; 
        $i.css({ 
            "z-index": 999999999999999999999999999999999999999999999999999999999999999999999, 
            "top": y - 20, 
            "left": x, 
            "position": "absolute", 
            "font-weight": "bold", 
            "color": "#ff6651" 
        }); 
        $("body").append($i); 
        $i.animate({ 
            "top": y - 180, 
            "opacity": 0 
        }, 
        1500, 
        function() { 
            $i.remove(); 
        }); 
    }); 
}); 
</script>
```
## 4.评论框特效
下载特效JS文件：[commentTyping.js](https://wohenliu.com/usr/js/commentTyping.js)，将其放在网站目录某个地方，然后编辑主题文件handsome/component/footer.php，在</body>后面添加以下代码。
```
<script type="text/javascript" src="(JS文件路径)"></script>
```

## 5.typecho下的彩色标签云实现方式

修改的有3个文件

1. component/sidebar.php

2. 新增CSS文件

3. component/header.php

< 一 > 用以下这段代码替换原有**非文章页面**的标签云

```
vim handsome/component/sidebar.php

<section id="tag_cloud-2" class="widget widget_tag_cloud wrapper-md clear">
       <h3 id="tag-cloud-title" class="widget-title m-t-none text-md"><?php _me("标签云") ?></h3>            
       <div class="tags l-h-2x">
       <?php Typecho_Widget::widget('Widget_Metas_Tag_Cloud','ignoreZeroCount=1&limit=30')->to($tags); ?>
       <?php if($tags->have()): ?>
           <?php while ($tags->next()): ?>
           <span id="tag-clould-color"  style="background-color:rgb(<?php echo(rand(0,255)); ?>,<?php echo(rand(0,255)); ?>,<?php echo(rand(0,255)); ?>)">
               <a  href="<?php $tags->permalink();?>"  title="<?php echo sprintf(_mt("该标签下有 %d 篇文章"),$tags->count); ?>" data-toggle="tooltip" >
               <?php $tags->name(); ?></a>
           </span>
           <?php endwhile; ?>
       <?php endif; ?>
       </div>
   </section>

```
< 二 > 新增CSS文件 文件名只要不是中文 都可以，放到handsome/assets/css/目录下



```
pwd
/data/app/typecho/usr/themes
vim handsome/assets/css/biaoqian.css

/* tag-clould-color 彩色标签云 */
#tag-clould-color {
    padding: 3px 10px 3px 10px;
    border-radius: 10px;
    color: #FFFFFF;
    margin: 3px 3px 3px 0;
    display: inline-block;
}
```
< 三 > 在header中引入文件  这步不做也行，不过这样的标签云样式没那么好，颜色还是有的。

![ar7S81.png](https://s1.ax1x.com/2020/08/05/ar7S81.png)


```
 vim handsome/component/header.php

	
<link rel="stylesheet" href="<?php echo STATIC_PATH; ?>css/你的CSS文件名.css" type="text/css">
```



## 6.给typecho加上心知天气-博客美化

把代码加入到后台设置的自定义Javascript 里面 或者将代码添加到`/usr/themes/handsome/component/headnav.php`第48行下方即可 

```


<!-- 心知天气-->
    <div id="tp-weather-widget" class="navbar-form navbar-form-sm navbar-left shift"></div>
<script>(function(T,h,i,n,k,P,a,g,e){g=function(){P=h.createElement(i);a=h.getElementsByTagName(i)[0];P.src=k;P.charset="utf-8";P.async=1;a.parentNode.insertBefore(P,a)};T["ThinkPageWeatherWidgetObject"]=n;T[n]||(T[n]=function(){(T[n].q=T[n].q||[]).push(arguments)});T[n].l=+new Date();if(T.attachEvent){T.attachEvent("onload",g)}else{T.addEventListener("load",g,false)}}(window,document,"script","tpwidget","//widget.seniverse.com/widget/chameleon.js"))</script>
<script>tpwidget("init", {
    "flavor": "slim",
    "location": "WX4FBXXFKE4F",
    "geolocation": "enabled",
    "language": "auto",
    "unit": "c",
    "theme": "chameleon",
    "container": "tp-weather-widget",
    "bubble": "enabled",
    "alarmType": "badge",
    "color": "#C6C6C6",
    "uid": "填写你的UID",
    "hash": "密钥"
});
tpwidget("show");</script>
<!-- 心知结束-->

```



 然后去知心天气官网`www.seniverse.com`注册申请API 密钥就可以了 

## 7.将QQ头像设置为左边导航栏图片

```
https://q1.qlogo.cn/g?b=qq&nk=1378373724&s=640
```

 复制上方地址修改1378373724为自己 QQ - 随后将地址添加到`初级设置 - 头像图片地址` 即可 

## 8.开启 Typecho 的 gzip 压缩以提升网站速度

## 开启

找到你的Typecho的网站根目录中的index.php
添加如下代码

```
/** 开启gzip压缩, add by yovisun */
ob_start('ob_gzhandler');
```

 此行代码需加在 index.php 中 ** 的下方，但不可放在最下方，否则网站可能无法访问 

## 结果

完成后，使用 [网页GZIP压缩检测](http://tool.chinaz.com/gzips/?q=wohenliu.com) 检查结果：



## 9,云雾特效

先获取两张背景图片

[图片1](https://wohenliu.com/tupian/ding/heiyun.png)

[图片2](https://wohenliu.com/tupian/ding/heiyun2.png)

 然后再复制下面css，添加到自定义css 

```

*{margin:0;padding:0;}
            html {
              box-sizing: border-box;
            }
            
            *,
            *:before,
            *:after {
              box-sizing: inherit;
            }
            
            figure {
              margin: 0;
            }
            
            .absolute-bg {
              position: absolute;
              top: 0;
              left: 0;
              z-index: 0;
              height: 100%;
              width: 100%;
              background-position: 50%;
              background-repeat: no-repeat;
              background-size: cover;
              overflow: hidden;
            }
            
            .fog {
              position: relative;
              height: 100vh;
              width: 100%;
              position: fixed;
              top: 0;
              z-index: -1;
            }
            .fog__container {
              position: absolute;
              height: 100%;
              width: 100%;
              overflow: hidden;
            }
            .fog__img {
              position: absolute;
              height: 100vh;
              width: 300vw;
            }
            
            .fog__img--first {
              background: url("https://wohenliu.com/tupian/ding/heiyun.png") repeat-x;
              background-size: contain;
              background-position: center;
              -webkit-animation: marquee 60s linear infinite;
                      animation: marquee 60s linear infinite;
            }
            .fog__img--second {
              background: url("https://wohenliu.com/tupian/ding/heiyun2.png") repeat-x;
              background-size: contain;
              background-position: center;
              -webkit-animation: marquee 40s linear infinite;
                      animation: marquee 40s linear infinite;
            }
            @media screen and (max-width: 767px){
                .fog__img--first{
                    -webkit-animation: marquee 6s linear infinite;
                            animation: marquee 6s linear infinite;
                }
                .fog__img--second{
                    -webkit-animation: marquee 6s linear infinite;
                            animation: marquee 6s linear infinite;
                }
            }
            @-webkit-keyframes marquee {
              0% {
                -webkit-transform: translate3d(0, 0, 0);
                        transform: translate3d(0, 0, 0);
              }
              100% {
                -webkit-transform: translate3d(-200vw, 0, 0);
                        transform: translate3d(-200vw, 0, 0);
              }
            }
            
            @keyframes marquee {
              0% {
                -webkit-transform: translate3d(0, 0, 0);
                        transform: translate3d(0, 0, 0);
              }
              100% {
                -webkit-transform: translate3d(-200vw, 0, 0);
                        transform: translate3d(-200vw, 0, 0);
              }
            }
```

1. 在component / footer.php中搜索`footer(); ?>`，在这一行上面添加

```
 <section class="fog">
        <div class="fog__container">
            <div class="fog__img fog__img--first"></div>
            <div class="fog__img fog__img--second"></div>
        </div>
    </section>
```

 这个时候您的博客应该有云在飘了 