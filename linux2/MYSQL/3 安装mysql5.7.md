[toc]

## 安装mysql5.7 



安装mysql源

```
 rpm -Uvh  http://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
```

安装mysql

```
yum -y install mysql-community-server
```

启动

```
systemctl start mysqld
systemctl enable mysqld

```

查看日志，看临时密码

```
grep 'temporary password' /var/log/mysql.log
```

登录后修改



```
alter user user() identified by "123.Shui!!$#";
flush privileges; 

或者
alter user 'root'@'localhost' identified by '123.Shui!!$#'; 
```

设置  root 远程访问，5.6之前可以直接通过修改表生效，5.7之后就不可以了

```
use mysql ;
update mysql.user set host="%" where user="root";
```

设置5.7 root 远程访问

```
grant all privileges on *.* to 'root'@'%' identified by '123.Shui!!$#' with grant option;

flush privileges   #需要执行这个语句，要不然就要重启，8.0的mysql不用执行这句。
```

注意

- [`SET PASSWORD ... = PASSWORD('*`auth_string`*')`](https://dev.mysql.com/doc/refman/5.7/en/set-password.html) 自MySQL 5.7.6起不赞成使用该语法，并且在将来的MySQL版本中将删除该语法。

- [`SET PASSWORD ... = '*`auth_string`*'`](https://dev.mysql.com/doc/refman/5.7/en/set-password.html) 语法不被弃用，而是[`ALTER USER`](https://dev.mysql.com/doc/refman/5.7/en/alter-user.html)用于帐户更改（包括分配密码）的首选语句。例如：

  ```sql
  ALTER USER user() IDENTIFIED BY 'auth_string';
  ```

官网

```
https://dev.mysql.com/doc/refman/5.7/en/grant.html
```



### 创建用户远程访问

```
create user 'test1' identified by '123.Yichen!!';     #密码不能太简单，8.0是可以简单
这是可以远程登录，但是没有权限。

GRANT ALL ON *.* TO 'test1'@'%';        
这时候就可以了。
```



**后期更换密码**

```
alter user 'root'@'%' indentified by '123.Shui!!$#@';

注意这里不用使用user()函数，使用user()会是'root'@'localhost' 会报错，因为表里已经没有这个主机了。
```



### 忘记密码修改

```
vim /etc/my.cnf   (在[mysqld]参数组下添加)
skip-grant-tables	  #跳过授权表

重启mysql 

```

登录 把user变里的authentication_string字段的内容清空。

```
mysql -u root 

update mysql.user set authentication_string='' where user='root' and host='%';

```

然后退出

退出，把Skip-grant-table语句删除，重新启动数据库

在重置密码

```
alter user'root'@'%' IDENTIFIED BY '123.Shui!!#@'; 
```



