# Auto.js学习

## 1，入门第一章

###  常用代码

运行脚本，唤醒手机屏幕

```
device.wakeUp()
```

打开某个应用，

```
launchApp("微视");
```

点击某个坐标 指针位置

```
click(x,y);
```

代表暂停运行几毫秒时间，1秒等于1000毫秒

```
sleep(n),
```

```
setText([i,]text),  i{number} 表示要输入的为第i+ 1个输入框 text {string} 要输入的文本
```
## 2，入门第二章

**Auto插件源码地址**

```
https://github.com/hyb1996/Auto.js-VSCode-Extension
```

按`Ctrl+Shift+P`或单击“查看”->“命令面板”可调出命令面板，输入`Auto.js`可以看到几个命令，移动光标到命令`Auto.js: Start Server`，按回车键执行该命令。

此时VS Code会在右上角显示“ Auto.js服务器正在运行”，即开启服务成功。	

### 常用代码

屏幕输出内容

```
toast("hello");
```

把代码保存到手机

```
先按 Ctrl+Shift+P 然后输入命令：Auto.js: Save On Device 或者按Ctrl+F5
```

## 3，入门第三章

简单编写，1，找到评论按钮，2，点击评论按钮，3，等待弹窗出来。4.找到点赞按钮，5，点击点赞按钮

```
className("android.widget.lmageView").findOne
```

