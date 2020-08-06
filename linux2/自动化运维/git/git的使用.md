[toc]

# 1,git的使用

### 1.官网账号

```
https://github.com

windos下载
 https://git-scm.com/download/win
```

### 2.设置 

```
配置用户名   git config --global user.name "你自己GitHub的用户名"
配置邮箱    git config --global user.email "你自己Github的注册邮箱"


去创建一个空目录lukegit
然后cd到lukegit  
执行git init 

```

### 3,上传文件到仓库

首先把文件下拉到本地初始化好的git目录

**通过pull方法**

```

添加远程仓库，origin只是一个远程仓库的别名，可以随意取
git remote add origin http://47.244.62.17:8989/dev/scripts.git

先把远程的pull到本地。把自己的代码修改好，移动到对应的目录  
git pull origin master


开始修改代码。或新增目录。

1.把文件添加到仓库
	 git add .   提交当前目录的所有代码。
2.把文件提交到仓库
	git commit -m "注释信息"
	
```

**通过clone方法**

```
#新建目录初始化
mkdir luketest
cd luketest   
git init 

#clone到本地
git clone http://47.244.62.17:8989/luke/luke.git
cd 到luke目录
cd luke

此时的目录下已经有一个远程仓库了
git remote -v
origin  http://47.244.62.17:8989/luke/luke.git (fetch)
origin  http://47.244.62.17:8989/luke/luke.git (push)


开始修改代码。或新增目录。

1.把文件添加到仓库
	 git add .   提交当前目录的所有代码。
2.把文件提交到仓库
	git commit -m "注释信息"
	
```



### 4,上传到远程仓库

```
将本地仓库push远程仓库，并将origin设为默认远程仓库
git push -u origin master


推送现有的git仓库内容
git remote add origin http://47.244.62.17:8989/luke/bet365.git
git push -u origin --all
git push -u origin --tags

远程版本库操作命令：
git rm filename				#删除版本库永久存放区的指定文件
 git remote 		#查看当前版本库已经添加的所有远程版本库

 git remote -v		#长格式查看所有添加的远程版本库

 git remote add [版本库名称] [链接地址]	#添加一个远程版本库

 git remote remove [版本库名称]			#删除一个远程版本库

 git push -u [版本库名称] [分支名称]		#将本地版本库内容推送到指定远程版本库

 git clone [版本库链接地址]				#克隆(下载)一个远程版本库的内容到本地
 
删除缓存区所有文件命令
git rm -r --cached .   #主要这个点一定要写


fetch与pull

fetch是将远程主机的最新内容拉到本地，不进行合并

git fetch origin master
　　
pull 则是将远程主机的master分支最新内容拉下来后与当前本地分支直接合并 fetch+merge

git pull origin master
```







