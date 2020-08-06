

 如何在nginx的web服务器上设置更强的SSL。通过使SSL无效来减弱CRIME攻击的这种方法实现。不使用在协议中易受攻击的SSLv3以及以下版本并且我们会设置一个更强的密码套件为了在可能的情况下能够实现[Forward Secrecy](http://en.wikipedia.org/wiki/Forward_secrecy)，同时还启用HSTS和HPKP。这样就有了一个更强、不过时的SSL配置

在nginx的设置文档中如下编辑 

/etc/nginx/conf.d/nginx.conf (On RHEL/CentOS).

编辑服务器配置的服务器那块和443端口（SSL配置）

编辑之前做备份！

### SSL 压缩（犯罪攻击）

通常来说，犯罪攻击使用 SSL 压缩来施展它的魔法。SSL 压缩在 nginx1.1.6+/1.0.9+ 中默认是关闭的（如果使用 openssl 1.0.0+).

如果你正在使用 nginx 或者 OpenSSL 其他早期版本，并且你的发行版并没有回迁此选项，那么你需要重新编译不支持 ZLIB 的 OpenSSL。这将禁止使用DEFLATE压缩方法来使用 OpenSSL。如果你这样做，那么你仍然可以使用常规的HTML DEFLATE压缩。

### SSLV2 与 SSLv3

SSL v2 并不安全，因此我们需要禁用它。我们也可以禁用 SSL v3，当 TLS 1.0 遭受一个降级攻击时，可以允许一个攻击者强迫使用 SSL v3 来连接，因此禁用“向前保密”。

再次编辑此配置文件：

```
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
```



 

### 贵宾犬攻击和TLS-FALLBACK-SCSV

SSLv3允许利用“[贵宾犬](https://raymii.org/s/articles/Check_servers_for_the_Poodle_bug.html) POODLE”漏洞，这是禁用它的一个主要原因。Google已经提议一种叫[TLSFALLBACKSCSV](https://tools.ietf.org/html/draft-ietf-tls-downgrade-scsv-00)的SSL/TLS的拓展，旨在防止强制SSL降级。以下是升级后自动启用的OpenSSL版本：

- OpenSSL 1.0.1 有 TLS*FALLBACK*SCSV 在 1.0.1j 及更高的版本.
- OpenSSL 1.0.0 有 TLS*FALLBACK*SCSV 在 1.0.0o 及更高的版本.
- OpenSSL 0.9.8 有 TLS*FALLBACK*SCSV 在 0.9.8zc 及更高的版本.

## 密码套件

[Forward Secrecy](http://en.wikipedia.org/wiki/Forward_secrecy) 确保了在永久密钥被泄漏的事件中，会话密钥的完整性。PFS 实现这些是通过执行推导每个会话的新密钥来完成。

这意味着当私有密钥被泄露不能用来解密SSL流量记录。

密码套件提供 Perfect Forward Secrecy 暂时使用 Diffie-Hellman 密钥交换的形式。他们的缺点是开销大，这可以通过使用椭圆曲线的变异的改进。





我建议以下两个密码套件，后者来自 Mozilla 基金会。

推荐的密码套件:

```
ssl_ciphers 'AES128+EECDH:AES128+EDH';
```

推荐的密码套件向后兼容(IE6 / WinXP):

```
ssl_ciphers "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
```

 如果您的 OpenSSL 是旧版本，不可用密码将被自动丢弃。总是使用完整的密码套件，让OpenSSL选它所支持的。

密码套件的顺序非常重要，因为它决定在优先级算法将被选中。上面的建议重视算法提供完美的向前保密。

老版本的 OpenSSL 可能不会返回算法的完整列表。AES-GCM 和一些 ECDHE 相当近，而不是出现在大多数版本的 Ubuntu OpenSSL 附带或 RHEL。

**优先级逻辑**

- 首先选择 ECDHE + AESGCM 密码。这些都是 TLS 1.2 密码并没有受到广泛支持。这些密码目前没有已知的攻击目标。

- PFS 密码套件是首选，ECDHE 第一，然后 DHE。

- AES 128 更胜 AES 256。有讨论是否 AES256 额外的安全是值得的成本，结果远不明显。目前，AES128 是首选的，因为它提供了良好的安全，似乎真的是快，更耐时机攻击。

- 向后兼容的密码套件，AES 优先 3DES。暴力攻击 AES 在 TLS1.1 及以上，减轻和 TLS1.0 中难以实现。向后不兼容的密码套件，3DES 不存在.

- RC4 被完全移除. 3DES 用于向后兼容。

  **强制性的丢弃**

  - aNULL 包含未验证 diffie - hellman 密钥交换，受到中间人这个攻击
  - eNULL 包含未加密密码(明文)
  - EXPORT 被美国法律标记为遗留弱密码
  - RC4 包含了密码，使用废弃ARCFOUR算法
  - DES 包含了密码，使用弃用数据加密标准
  - SSLv2 包含所有密码,在旧版本中定义SSL的标准,现在弃用
  - MD5 包含所有的密码，使用过时的消息摘要5作为散列算法

## 其它的设置

确保你已经添加了以下几行：
```
ssl_prefer_server_ciphers on;
ssl_session_cache shared:SSL:10m;
```
在SSLv3或这是TLSv1握手时选择一个密码，通常是使用客户端的偏好。如果这个指令是启用的，那么服务器反而是使用服务器的偏好。

## 向前保密（[Forward Secrecy](http://en.wikipedia.org/wiki/Forward_secrecy)）与[Diffie Hellman Ephemeral Parameters](http://wiki.openssl.org/index.php/Diffie_Hellman)

向前保密的概念很简单：客户端和服务器协商一个可靠的密钥，并在会话结束后销毁。服务器中的RSA私钥用来签名客户端和服务器之间交换的Diffie-Hellman密钥。副主密钥从Diffie-Hellman握手中得到，并用于加密。由于副主密钥在客户端和服务器之间的连接中是明确具体的，并用于有限的时间，因此被叫作Ephemeral(短暂的)。

由于有Forward Secrecy，即使攻击者持有服务器的私钥，也不能够解密过去的会话。私钥仅仅用来签名DH（Diffie-Hellman）的握手，它并没有泄漏副主密钥。Diffie-Hellman确保了副主密钥不会离开客户端和服务器，也不会被中间人截获。



 

1.4.4所有的nginx版本在往Diffiel-Hellman输入参数时依赖OpenSSL。不幸的时，这就意味着Ephemeral Diffiel-Hellman（DHE）会使用OpenSSL的这一缺陷，包括一个1024位的交换密钥。由于我们正在使用一个2048位的证书，DHE客户端比非ephemeral客户端将使用一个更弱的密钥交换。

我们需要产生一个更强的DHE参数：这需要大约30分钟时间，取决于服务器的性能

```
cd /etc/ssl/certs
openssl dhparam -out dhparam.pem 4096
```

如果nginx是在容器里边，就把文件cp到容器的目录下

```
docker cp /etc/ssl/certs/dhparam.pem app_nginx_1:/etc/ssl/certs/
```



然后告诉nginx在DHE密钥交换的时候使用它：

```
ssl_dhparam /etc/ssl/certs/dhparam.pem;
```

### OCSP 适用

在和服务器连接的时候，客户端通过使用证书撤销列表（CRL）来验证服务器证书的有效性，或者是使用在线证书状态协议（OCSP）记录。但是CRL的问题是：CRL的列表项不断增多，而且需要不断地下载。



 

OCSP是更轻量级的，因为它一次只获取一条记录。但是副作用是，当连接到服务器的时候，OCSP请求必须发送到第三方响应者，这增加了延迟，以及失败的可能。实际上，OCSP响应者由CA操控，由于它常常不可靠，导致浏览器由于收不到适时的响应而失败。这减少了安全性，因为它允许攻击者对OCSP响应者进行DoS攻击来取消验证。

解决方案是在TLS握手期间，允许服务器发送缓存的OCSP记录，这样来绕过OCSP响应者。这个技术节省了在客户端和OCSP响应者之间的一个来回，称为OCSP闭合（OCSP Stapling）。

服务器只在客户端请求的时候，发送一个缓存的OCSP响应，通过对CLIENT HELLO的status_request TLS拓展来声明支持。

大多数服务器都会缓存OCSP响应到48小时。在常规间隔，服务器会连接到CA的OCSP响应者来获取最新的OCSP记录。OCSP响应者的位置是从签名证书的Authority Information Access 字段来获取。

解决方案是允许服务器在TLS握手期间发送其缓存的OCSP记录，从而绕过OCSP响应器。此机制节省了客户端和OCSP响应者之间的往返时间，称为OCSP装订。

通过在客户端HELLO中声明对status_request TLS扩展的支持，服务器仅在客户端请求时才发送缓存的OCSP响应。

大多数服务器最多可以缓存OCSP响应48小时。服务器将以固定的时间间隔连接到CA的OCSP响应者，以检索新的OCSP记录。OCSP响应者的位置来自已签名证书的“权限信息访问”字段。



### 什么是OCSP装订

OCSP装订在[IETF RFC 6066中](http://tools.ietf.org/html/rfc6066)定义。术语“装订”是一个流行的术语，用于描述Web服务器如何获得OCSP响应。Web服务器缓存来自颁发证书的CA的响应。启动SSL / TLS握手后，Web服务器通过将缓存的OCSP响应附加到CertificateStatus消息，将响应返回到客户端。要使用OCSP装订，客户端必须在其SSL / TSL客户端“ Hello”消息中包括“ status_request”扩展名。

OCSP装订具有以下优点：

- 依赖方在需要时（在SSL / TLS握手期间）会收到Web服务器证书的状态。
- 无需与发布CA设置其他HTTP连接。
- OCSP装订通过减少攻击媒介的数量提供了更高的安全性。

[阅读](http://en.wikipedia.org/wiki/OCSP_stapling) [一个](http://en.wikipedia.org/wiki/Online_Certificate_Status_Protocol) [的](http://security.stackexchange.com/questions/29686/how-does-ocsp-stapling-work) [在](https://blog.mozilla.org/security/2013/07/29/ocsp-stapling-in-firefox/) [以下](http://www.thawte.com/assets/documents/whitepaper/ocsp-stapling.pdf) [链接](http://news.netcraft.com/archives/2013/04/16/certificate-revocation-and-the-performance-of-ocsp.html)进行[更多](https://wiki.mozilla.org/Security/Server_Side_TLS) 的OCSP和OCSP装订信息。

### 要求

您至少需要nginx 1.3.7才能起作用。当前的Ubuntu LTS版本（12.04）中不提供此功能，[它具有1.1.19](http://packages.ubuntu.com/precise/nginx)，在CentOS上，您需要EPEL或官方存储库。但是，[安装最新版本的nginx](http://wiki.nginx.org/Install)很容易[。](http://wiki.nginx.org/Install)

您还需要创建防火墙例外，以允许您的服务器建立与上游OCSP的出站连接。您可以使用这一种衬垫从网站上查看所有OCSP URI：

```
OLDIFS=$IFS; IFS=':' certificates=$(openssl s_client -connect google.com:443 -showcerts -tlsextdebug -tls1 2>&1 </dev/null | sed -n '/-----BEGIN/,/-----END/ {/-----BEGIN/ s/^/:/; p}'); for certificate in ${certificates#:}; do echo $certificate | openssl x509 -noout -ocsp_uri; done; IFS=$OLDIFS
```

结果是google.com在：

```
http://clients1.google.com/ocsp
http://gtglobal-ocsp.geotrust.com
```

### nginx配置

将以下配置添加到您的https（443）`server`块：

```
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
```

为了使OCSP装订工作，应该知道服务器证书颁发者的证书。如果`ssl_certificate`文件不包含中间证书，则服务器证书颁发者的证书应存在于`ssl_trusted_certificate`文件中。

我的raymii.org证书由发行`Positive CA 2`。该证书由颁发`Addtrust External CA Root`。在我的nginx `ssl_certificate`文件中，所有这些证书都存在。如果不是这种情况，请使用证书链创建一个文件，并按以下方式使用它：

```
  ssl_trusted_certificate /etc/ssl/certs/domain.chain.stapling.pem;
```

在版本1.1.7之前，只能配置一个名称服务器。从版本1.3.1和1.2.2开始，支持使用IPv6地址指定名称服务器。默认情况下，nginx将在解析时同时查找IPv4和IPv6地址。如果不需要查找IPv6地址，则`ipv6=off` 可以指定该参数。从版本1.5.8开始，支持将名称解析为IPv6地址。

默认情况下，nginx使用响应的TTL值缓存答案。（可选）`valid`参数允许将其改写为5分钟。在1.1.9版之前，无法调整缓存时间，nginx始终将答案缓存5分钟。

重新启动您的nginx以加载新配置：

```
service nginx restart
```

它应该工作。让我们测试一下。

### 测试它

启动终端并使用以下OpenSSL命令连接到您的网站：

```
openssl s_client -connect example.org:443 -tls1 -tlsextdebug -status
```

在响应中，查找以下内容：

```
OCSP response:
======================================
OCSP Response Data:
    OCSP Response Status: successful (0x0)
    Response Type: Basic OCSP Response
    Version: 1 (0x0)
    Responder Id: 99E4405F6B145E3E05D9DDD36354FC62B8F700AC
    Produced At: Feb  3 04:25:39 2014 GMT
    Responses:
    Certificate ID:
      Hash Algorithm: sha1
      Issuer Name Hash: 0226EE2F5FA2810834DACC3380E680ACE827F604
      Issuer Key Hash: 99E4405F6B145E3E05D9DDD36354FC62B8F700AC
      Serial Number: C1A3D8D00D72FCE483CD84759E9EC0BC
    Cert Status: good
    This Update: Feb  3 04:25:39 2014 GMT
    Next Update: Feb  7 04:25:39 2014 GMT
```

这意味着它正在工作。如果收到如下响应，则该响应不起作用：

```
OCSP response: no response sent
```

您还可以使用[SSL Labs](https://ssllabs.com/)测试来查看OCSP装订是否有效。





### HTTP Strict Transport Security 

如果可能，你应该开启 [HTTP Strict Transport Security (HSTS)](https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security)，它指示浏览器只通过HTTPS来访问你的站点。

### HTTP Public Key Pinning Extension

你同样应该开启 [HTTP Public Key Pinning Extension](https://wiki.mozilla.org/SecurityEngineering/Public_Key_Pinning)。

 Public Key Pinning 意味着证书链必须包含处于白名单之中的公钥。它确保只在白名单中的CA可以对*.example.com进行签名，而不是浏览器中保存的任何一个CA。 

```
server {

  listen [::]:443 default_server;

  ssl on;
  ssl_certificate_key /etc/ssl/cert/raymii_org.pem;
  ssl_certificate /etc/ssl/cert/ca-bundle.pem;

  ssl_ciphers 'AES128+EECDH:AES128+EDH:!aNULL';

  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_session_cache shared:SSL:10m;

  ssl_stapling on;
  ssl_stapling_verify on;
  resolver 8.8.4.4 8.8.8.8 valid=300s;
  resolver_timeout 10s;

  ssl_prefer_server_ciphers on;
  ssl_dhparam /etc/ssl/certs/dhparam.pem;

  add_header Strict-Transport-Security max-age=63072000;
  add_header X-Frame-Options DENY;
  add_header X-Content-Type-Options nosniff;
```