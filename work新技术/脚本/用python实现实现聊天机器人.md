

 使用图灵机器人的API需要先注册，获取key才行 :   自己到http://www.tuling123.com/注册一个账号即可。 

 下面就是一个简单的python调用API实现聊天机器人的简易脚本。 网络大佬写的，我个人作为收藏

```

#!/usr/bin/env python
# -*- encoding: utf-8 -*-

import urllib,urllib2
import json


while True:
    url = 'http://www.tuling123.com/openapi/api'    #图灵机器人API地址
    key = 'xxx'    #图灵机器人key

    info = raw_input('我: ')
    values = {'key': key,'info':info}
    data = urllib.urlencode(values)

    request = urllib2.Request(url=url,data=data)   #请求
    response = urllib2.urlopen(request).read()   #回应
    dic_json = json.loads(response)   #以json格式打开

    print u'机器人: ' + dic_json['text']
    if int(dic_json['code']) == 100000:   #文本类
        #print u'机器人: ' + dic_json['text']
        pass
    elif int(dic_json['code']) == 200000:  #链接类
        #print u'机器人: ' + dic_json['text'] + u'\n链接：' + dic_json['url']
        print u'链接：' + dic_json['url']
    elif int(dic_json['code']) == 302000:  # 新闻类
        #print u'机器人: ' + dic_json['text']
        for li in dic_json['list']:
            print u'标题：' + li['article']
            print u'来源：' + li['source']
            print u'图片：' + li['icon']
            print u'详情链接：' + li['detailurl']
    elif int(dic_json['code']) == 308000:  # 菜谱类
        #print u'机器人: ' + dic_json['text']
        for li in dic_json['list']:
            print u'菜名：' + li['name']
            print u'材料：' + li['info']
            print u'图片：' + li['icon']
            print u'详情链接：' + li['detailurl']
            
```



写好后直接运行就可以了



![image-20191210041352549](D:\文档\屏幕截图文档插入图片\3对话.png)