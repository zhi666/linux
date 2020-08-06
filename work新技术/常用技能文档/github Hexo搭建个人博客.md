[toc]



## github Hexo搭建个人博客

### 准备环境

准备node和git环境

安装node

```
https://nodejs.org

wget    https://nodejs.org/dist/v12.14.0/node-v12.14.0-linux-x64.tar.xz
tar -xvf node-v12.14.0-linux-x64.tar.xz  -C /usr/local/ #解压tar
cd /usr/local/

mv node-v12.14.0-linux-x64/ node

配置环境变量
vim /root/.bash_profile

PATH=$PATH:$HOME/bin:/usr/local/node/bin

#使环境变量生效
source /root/.bash_profile
```

查看环境是否安装好

```
node -v
v12.14.0

npm -v
6.13.4

git version
git version 1.8.3.1
```

### 安装Hexo

如果以上环境准备好了就可以使用 npm 开始安装 Hexo 了。也可查看 `https://hexo.io/zh-cn/`   的详细文档。

```
npm install -g hexo-cli
```

安装 Hexo 完成后，再执行下列命令，Hexo 将会在指定文件夹中新建所需要的文件。

```
hexo init myBlog
cd myBlog
npm install
```

新建完成后，指定文件夹的目录如下:

```
_config.yml #网站的配置信息，你可以在此配置大部分的参数。
package.json
scaffolds  #模板文件夹
source   #资源文件夹，除_posts 文件，其他以下划线_开头的文件或文件夹不会被编译打包到public文件夹。
  _drafts  #草稿文件
  _posts   #文章markdown文件
themes   #主题文件夹。
```

如果上面的命令都没有报错的话，就可以运行hexo s 命令 ，在浏览器输入ip:4000就可以访问看效果了

```
hexo g #生成
hexo s #部署到本地，看看效果

hexo g -d  #部署到远程github
```

### init

```
$ hexo init [folder]
```

新建一个网站。如果没有设置 `folder` ，Hexo 默认在目前的文件夹建立网站。

### new

```
$ hexo new [layout] <title>
```

新建一篇文章。如果没有设置 `layout` 的话，默认使用 [_config.yml](https://hexo.io/zh-cn/docs/configuration) 中的 `default_layout` 参数代替。如果标题包含空格的话，请使用引号括起来。

```
$ hexo new "linux基础"
```

| 参数              | 描述                                          |
| :---------------- | :-------------------------------------------- |
| `-p`, `--path`    | 自定义新文章的路径                            |
| `-r`, `--replace` | 如果存在同名文章，将其替换                    |
| `-s`, `--slug`    | 文章的 Slug，作为新文章的文件名和发布后的 URL |

默认情况下，Hexo 会使用文章的标题来决定文章文件的路径。对于独立页面来说，Hexo 会创建一个以标题为名字的目录，并在目录中放置一个 `index.md` 文件。你可以使用 `--path` 参数来覆盖上述行为、自行决定文件的目录：

```
hexo new page --path about/me "About me"
```

以上命令会创建一个 `source/about/me.md` 文件，同时 Front Matter 中的 title 为 `"About me"`

注意！title 是必须指定的！如果你这么做并不能达到你的目的：

```
hexo new page --path about/me
```

此时 Hexo 会创建 `source/_posts/about/me.md`，同时 `me.md` 的 Front Matter 中的 title 为 `"page"`。这是因为在上述命令中，hexo-cli 将 `page` 视为指定文章的标题、并采用默认的 `layout`。



### generate

```
$ hexo generate
```

生成静态文件。

| 选项                  | 描述                                                         |
| :-------------------- | :----------------------------------------------------------- |
| `-d`, `--deploy`      | 文件生成后立即部署网站                                       |
| `-w`, `--watch`       | 监视文件变动                                                 |
| `-b`, `--bail`        | 生成过程中如果发生任何未处理的异常则抛出异常                 |
| `-f`, `--force`       | 强制重新生成文件 Hexo 引入了差分机制，如果 `public` 目录存在，那么 `hexo g` 只会重新生成改动的文件。 使用该参数的效果接近 `hexo clean && hexo generate` |
| `-c`, `--concurrency` | 最大同时生成文件的数量，默认无限制                           |

修改后直接部署的命令

```
hexo g -f -d
```



以下是预先定义的参数，您可在模板中使用这些参数值并加以利用。

| 参数         | 描述                 | 默认值       |
| :----------- | :------------------- | :----------- |
| `layout`     | 布局                 |              |
| `title`      | 标题                 | 文章的文件名 |
| `date`       | 建立日期             | 文件建立日期 |
| `updated`    | 更新日期             | 文件更新日期 |
| `comments`   | 开启文章的评论功能   | true         |
| `tags`       | 标签（不适用于分页） |              |
| `categories` | 分类（不适用于分页） |              |
| `permalink`  | 覆盖文章网址         |              |

### 分类和标签

只有文章支持分类和标签，您可以在 Front-matter 中设置。在其他系统中，分类和标签听起来很接近，但是在 Hexo 中两者有着明显的差别：分类具有顺序性和层次性，也就是说 `Foo, Bar` 不等于 `Bar, Foo`；而标签没有顺序和层次。

```
categories:
- Diary
tags:
- PS3
- Games
```

> 分类方法的分歧
>
> 如果您有过使用 WordPress 的经验，就很容易误解 Hexo 的分类方式。WordPress 支持对一篇文章设置多个分类，而且这些分类可以是同级的，也可以是父子分类。但是 Hexo 不支持指定多个同级分类。下面的指定方法：
>
> ```
> categories:
>   - Diary
>   - Life
> ```
>
> 会使分类`Life`成为`Diary`的子分类，而不是并列分类。因此，有必要为您的文章选择尽可能准确的分类。
>
> 如果你需要为文章添加多个分类，可以尝试以下 list 中的方法。
>
> ```
> categories:
> - [Diary, PlayStation]
> - [Diary, Games]
> - [Life]
> ```
>
> 此时这篇文章同时包括三个分类： `PlayStation` 和 `Games` 分别都是父分类 `Diary` 的子分类，同时 `Life` 是一个没有子分类的分类。



## 完整教程参考文章

```
https://segmentfault.com/a/1190000017986794
```



#### 更换主题

```

比较不错的主题。
https://github.com/removeif/hexo-theme-amazing
克隆
git clone https://github.com/removeif/hexo-theme-amazing.git themes/amazing

git clone https://github.com/theme-next/hexo-theme-next themes/next

需要安装模块和指定版本。
npm install ajv 
npm install bulma-stylus@0.8.0
npm install hexo@4.2.0
npm install hexo-log@1.0.0
npm install hexo-renderer-inferno
npm install hexo-util@^1.8.0
npm install inferno
npm install inferno-create-element

```

#### 置顶设置：

.md文章头部数据中加入top值，top值越大越靠前，大于0显示置顶图标。 修改依赖包中文件removeif/node_modules/hexo-generator-index/lib/generator.js如下：

```
'use strict';
const pagination = require('hexo-pagination');
module.exports = function(locals){
    var config = this.config;
    var posts = locals.posts;
    posts.data = posts.data.sort(function(a, b) {
        if(a.top == undefined){
            a.top = 0;
        }
        if(b.top == undefined){
            b.top = 0;
        }
        if(a.top == b.top){
            return b.date - a.date;
        }else{
           return b.top - a.top;
        }
    });
    var paginationDir = config.pagination_dir || 'page';
    return pagination('', posts, {
        perPage: config.index_generator.per_page,
        layout: ['index', 'archive'],
        format: paginationDir + '/%d/',
        data: {
            __index: true
        }
    });
};
```

#### 配置文章中推荐文章模块

根据配置的recommend值（必须大于0），值越大越靠前，相等取最新的，最多取5条。recommend（6.中top值也在下面示例）配置在.md文章头中，如下

```
title: 博客源码分享
top: 1
toc: true
recommend: 1 
keywords: categories-github
date: 2019-09-19 22:10:43
thumbnail: https://cdn.jsdelivr.net/gh/removeif/blog_image/img/2019/20190919221611.png
tags: 工具教程
categories: [工具教程,主题工具]
```

#### 文章中某个代码块折叠的方法

代码块头部加入标记 `>folded`，如下代码块中使用。

```
    // 使用示例，.md 文件中头行标记">folded"
    // ```java main.java >folded
    // import main.java
    // private static void main(){
    //     // test
    //     int i = 0;
    //     return i;
    // }
    // \\``` 
```

#### 加入加密文章

```
https://github.com/MikeCoder/hexo-blog-encrypt/blob/master/ReadMe.zh.md
官方教程

安装插件
npm install --save hexo-blog-encrypt
```



如下需要加密的文章 头部加入以下代码

```

---
title: python之Selenium模块的使用
top: -1
toc: true
date: 2020-08-04 17:10:43
tags: python
categories: python
keywords: categories-java
encrypt: true
password: 123456 #此处为文章密码
abstract: 咦，这是一篇加密文章，好像需要输入密码才能查看呢！
message: 嗨，请准确无误地输入密码查看哟！
wrong_pass_message: 不好意思，密码没对哦，在检查检查呢！
wrong_hash_message: 不好意思，信息无法验证！
---

```

注：**加密文章不会出现在最新文章列表widget中，也不会出现在文章中推荐列表中，首页列表中需要设置top: -1 让它排在最后比较合理一些。**

显示文章的一部分内容。而不是全部内容

```
<!--more-->
这个只要在文章中加上<!--more--> 标记 ，该标记以后部分就不在显示了，只有展开全部才显示，这是hexo定义的。
这样每次添加这个标记有点麻烦，
```

