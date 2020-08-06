[toc]

linux 安装谷歌验证器

## 说明：
1、一般ssh登录服务器，只需要输入账号和密码。
2、本教程的目的：在账号和密码之间再增加一个
     验证码，只有输入正确的验证码之后，再输入
     密码才能登录。这样就增强了ssh登录的安全性。
3、账号、验证码、密码三者缺一个都不能登录，即使账号和密码正确，验证码错误，同样登录失败。
4、验证码：是动态验证码，并且是通过手机客户端自动获取（默认每隔30秒失效一次）。
5、最终目的：远程ssh登录一台服务器，需要正确的账号、密码、及一个可以获取到动态验证码的手机
    （目前支持Android和ios手机系统）。
具体操作：
操作系统：CentOS

## 一、关闭SELINUX
vim   /etc/selinux/config
#SELINUX=enforcing #注释掉
#SELINUXTYPE=targeted #注释掉
SELINUX=disabled #增加
:wq! #保存退出

setenforce 0 #使配置立即生效

## 二、安装epel

```
  yum install -y epel-release
```

## 三、安装google authenticator PAM插件

```
yum install -y google-authenticator
```

## 四、配置ssh服务调用google authenticator PAM插件

vim  /etc/pam.d/sshd #编辑，在第一行增加以下代码

```
auth required pam_google_authenticator.so
```
:wq! #保存退出

 vim /etc/ssh/sshd_config #编辑
```
ChallengeResponseAuthentication yes #修改no为yes    :69 行
```
:wq! #保存退出
service sshd restart #重启ssh服务，使配置生效
systemctl  restart  sshd

## 五、使用google authenticator PAM插件为ssh登录账号生成动态验证码
注意：哪个账号需要动态验证码，请切换到该账号下操作  yyyny
```
google-authenticator #运行此命令

```
**1,**Do you want authentication tokens to be time-based (y/n) y #提示是否要基于时间生成令牌，选择 y
Warning: pasting the following URL into your browser exposes the OTP secret to Google:
 ` https://www.google.com/chart?chs=200x200&chld=M|0&cht=qr&chl=otpauth://totp/root@server2.com%3Fsecret%3DAUM7DRYFWGW2YM6GKGQTPJU4WQ%26issuer%3Dserver2.com`

        中间是二维码

Your new secret key is: AUM7DRYFWGW2YM6GKGQTPJU4WQ
Your verification code is 666736
Your emergency scratch codes are:

  66604226
  68171408
  31625621
  38112312
  49895436
 上面的网址为生成的二维码图形地址（需要翻墙才能打开），还会生成密钥，以及5个紧急验证码(当无法获取动态验证码时使用，注意：这5个验证码用一个就会少一个！请保存好！)

**2,**Do you want me to update your "/home/jss/.google_authenticator" file (y/n) y #提示是否要更新验证文件，选择y

**3,**Do you want to disallow multiple uses of the same authentication
token? This restricts you to one login about every 30s, but it increases
your chances to notice or even prevent man-in-the-middle attacks (y/n) y #禁止使用相同口令

**4,**By default, tokens are good for 30 seconds and in order to compensate for
possible time-skew between the client and the server, we allow an extra
token before and after the current time. If you experience problems with poor
time synchronization, you can increase the window from its default
size of 1:30min to about 4min. **Do you want to do so (y/n)  n **

#默认动态验证码在30秒内有效，由于客户端和服务器可能会存在时间差，可将时间增加到最长4分钟，是否要这么做：这里选择是n，继续默认30秒

**5,**If the computer that you are logging into isn't hardened against brute-force
login attempts, you can enable rate-limiting for the authentication module.
By default, this limits attackers to no more than 3 login attempts every 30s.
Do you want to enable rate-limiting (y/n) y
#是否限制尝试次数，每30秒只能尝试最多3次，这里选择y进行限制


## 六、手机安装Google身份验证器，通过此工具扫描上一步生成的二维码图形，获取动态验证码
Android手机下载：

```
https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2
```


iOS手机下载：

```
https://itunes.apple.com/us/app/google-authenticator/id388497605
```

注意：打开google需要翻墙，或者自己想办法下载Google身份验证器安装。
另外，还需要安装条形码扫描器，用来扫描验证二维码，以获取动态验证码
以Android手机为例：
安装好Google身份验证器，打开如下图所示：
**两种设置的方法**
 1.开始设置-扫描条形码，然后扫描第六步中生成的二维码图形 或者输入网址获得 
然后就自动添加了，

 2.输入提供的密钥      然后输入账号详情
  账号名
 server2.com    
#账号名可以随便输入
您的密钥： AUM7DRYFWGW2YM6GKGQTPJU4WQ

 基于时间                                             添加  

然后手机上也添加成功了；

## 七、ssh远程登录服务器
这样设置之后就不能通过xshell直接连接了，只能通过xhell连接其他服务器，然后在通过ssh root@192.168.224.12 连接， 或者通过秘钥可以直接连接

输入账号之后，会提示输入验证码

login as: root
Using keyboard-interactive authentication.
Verification code:
打开手机上的Google身份验证器，输入动态验证码，回车。
注意：动态验证码没有回显，所以在屏幕上看不到输入的内容，但只要保证输入正确即可！

Using keyboard-interactive authentication.
Password:
接着输入密码，即可成功登录系统！
注意：以此步骤必须在30秒内完成。否则动态验证码过期，必须重新操作。
至此，Linux下使用Google Authenticator配置SSH登录动态验证码教程完成！