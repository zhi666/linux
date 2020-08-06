

一键自动生成ssl证书

**acme.sh**实现了`acme`协议，可以从letsencrypt生成免费的证书。
[toc]
下面详细介绍。

# 1.安装**acme.sh**

安装很简单，一个命令：

```
curl  https://get.acme.sh | sh
```

普通用户和root用户都可以安装使用。安装过程进行了以下几步：

1. 把acme.sh安装到你的**home**目录下：

```
~/.acme.sh/
```

并创建一个bash的别名，方便你的使用： `alias acme.sh=~/.acme.sh/acme.sh`

2）。自动为您创建cronjob，每天0:00点自动检测所有的证书，如果快过期了，需要更新，即可自动更新证书。

更高级的安装选项请参考：[https](https://github.com/Neilpang/acme.sh/wiki/How-to-install) : [//github.com/Neilpang/acme.sh/wiki/操作方法](https://github.com/Neilpang/acme.sh/wiki/How-to-install)

**安装过程不会污染现有的系统任何功能和文件**，所有的修改都限制在安装目录中：`~/.acme.sh/`

# 2.生成证书

**acme.sh**实现了**acme**协议支持的所有验证协议。一般有两种方式验证：http和dns验证。

**1. http方式需要在你的网站根目录下放置一个文件，来验证你的域名所有权，完成验证。然后就可以生成证书了。**

```
acme.sh  --issue  -d mydomain.com -d www.mydomain.com  --webroot  /home/wwwroot/mydomain.com/
```

只需要指定域名，并指定域名所在的网站根目录。**acme.sh**会自动的生成验证文件，并放到网站的根目录，然后自动完成验证。最后会聪明的删除验证文件。整个过程没有任何争议。

如果您用的**apache**服务器，**acme.sh**还可以智能的从**apache**的配置中自动完成验证，您不需要指定网站根目录：

```
acme.sh --issue  -d mydomain.com   --apache
```

如果您用的**nginx**服务器，或反代，**acme.sh**还可以智能的从**nginx**的配置中自动完成验证，您不需要指定网站根目录：

```
acme.sh --issue  -d mydomain.com   --nginx
```

**请注意，无论是apache还是nginx模式，acme.sh在完成验证之后，会恢复到之前的状态，都不会私自更改您本身的配置。好处是你不用担心配置被搞坏，也有一个缺点，你需要自己配置ssl的配置，否则只能成功生成证书，你的网站还是无法访问https。但是为了安全，你还是自己手动改配置吧。**

如果您还没有运行任何web服务，**80**端口是重置的，那么**acme.sh**还是假装自己是一个web服务器，临时听在**80**端口，完成验证：

```
acme.sh  --issue -d mydomain.com   --standalone
```

更高级的用法请参考：[https](https://github.com/Neilpang/acme.sh/wiki/How-to-issue-a-cert) : [//github.com/Neilpang/acme.sh/wiki/How-to-issue-a-cert](https://github.com/Neilpang/acme.sh/wiki/How-to-issue-a-cert)

**2.手动dns方式，手动在域名上添加一条txt解析记录，验证域名所有权**

这种方式的好处是，您不需要任何服务器，不需要任何公网ip，只需要dns的解析记录即可完成验证。坏处是，如果不同时配置自动DNS API，使用这种方式acme.sh将无法自动更新证书，每次都需要手动重新重新解析验证域名所有权。

```
acme.sh  --issue  --dns   -d mydomain.com
```

然后，**acme.sh**会生成相应的解析记录显示出来，你只需要在你的域名管理面板中添加这条txt记录即可。

等待解析完成之后，重新生成证书：

```
acme.sh  --renew   -d mydomain.com
```

注意第二次这里用的是 `--renew`

dns方式的真正强大之处在于可以使用域名解析商提供的api自动添加txt记录完成验证。

**acme.sh**目前支持cloudflare，dnspod，cloudxns，godaddy以及ovh等数十种解析商的自动集成。

以dnspod特别，你需要先登录到dnspod账号，生成你的api id和api key，都是免费的。然后：

```
export DP_Id="1234"

export DP_Key="sADDsdasdgdsf"

acme.sh   --issue   --dns dns_dp   -d aa.com  -d www.aa.com
```

证书就会自动生成了。这里称为的api id和api key会被自动记录下来，将来你在使用dnspod api的时候，就不需要再次指定了。直接生成就好了：

```
acme.sh  --issue   -d  mydomain2.com   --dns  dns_dp
```

更详细的api用法：[https](https://github.com/Neilpang/acme.sh/blob/master/dnsapi/README.md) : [//github.com/Neilpang/acme.sh/blob/master/dnsapi/README.md](https://github.com/Neilpang/acme.sh/blob/master/dnsapi/README.md)

# 3.复制/安装证书

前面证书生成以后，接下来需要把证书副本复制到真正需要用它的地方。

请注意，默认生成的证书都放在安装目录下：`~/.acme.sh/`，请不要直接使用此目录下的文件，例如：不要直接让nginx / apache的配置文件使用这下面的文件。这里面的文件都是内部使用，而且目录结构可能会变化。

正确的使用方法是使用`--installcert`命令，并指定目标位置，然后证书文件会被copy到相应的位置，例如：

```
acme.sh  --installcert  -d  <domain>.com   \
        --key-file   /etc/nginx/ssl/<domain>.key \
        --fullchain-file /etc/nginx/ssl/fullchain.cer \
        --reloadcmd  "service nginx force-reload"
```

（一个小提醒，这里用的是`service nginx force-reload`，不是`service nginx reload`，据测试，`reload`并不会重新加载证书，所以用的`force-reload`）

Nginx的配置`ssl_certificate`使用`/etc/nginx/ssl/fullchain.cer`，而非`/etc/nginx/ssl/.cer`，否则[SSL Labs](https://www.ssllabs.com/ssltest/)的测试会报`Chain issues Incomplete`错误。

`--installcert`命令可以携带很多参数，来指定目标文件。并且可以指定reloadcmd，当证书更新以后，reloadcmd会被自动调用，让服务器生效。

详细参数请参考：[https](https://github.com/Neilpang/acme.sh#3-install-the-issued-cert-to-apachenginx-etc) : [//github.com/Neilpang/acme.sh#3-install-the-issued-cert-to-apachenginx-etc](https://github.com/Neilpang/acme.sh#3-install-the-issued-cert-to-apachenginx-etc)

所谓的是，此处指定的所有参数都会被自动记录下来，并在将来证书自动更新以后，被再次自动调用。

# 4.更新证书

目前证书在60天以后会自动更新，你无需任何操作。未来有可能会缩短这个时间，不过都是自动的，你不用担心。

# 5.更新acme.sh

目前由于acme协议和letsencrypt CA都在不断更新，因此acme.sh也经常更新以保持同步。

升级acme.sh到最新版：

```
acme.sh --upgrade
```

如果你不想手动升级，可以开启自动升级：

```
acme.sh  --upgrade  --auto-upgrade
```

之后，acme.sh就会自动保持更新了。

你也可以随时关闭自动更新：

```
acme.sh --upgrade  --auto-upgrade  0
```

# 6.错误怎么办：

如果出错，请添加调试日志：

```
acme.sh  --issue  .....  --debug 
```

或者：

```
acme.sh  --issue  .....  --debug  2
```

请参考：[https](https://github.com/Neilpang/acme.sh/wiki/How-to-debug-acme.sh) : [//github.com/Neilpang/acme.sh/wiki/How-to-debug-acme.sh](https://github.com/Neilpang/acme.sh/wiki/How-to-debug-acme.sh)

最后，本文并非完全的使用说明，还有很多高级的功能，更高级的用法请参见其他Wiki页面。

https://github.com/Neilpang/acme.sh/wiki



