[toc]

# sed 的常用命令的使用

sed 会根据脚本命令来处理文本文件中的数据，这些命令要么从命令行中输入，要么存储在一个文本文件中，此命令执行数据的顺序如下：

1. 每次仅读取一行内容；
2. 根据提供的规则命令匹配并修改数据。注意，sed 默认不会直接修改源文件数据，而是会将数据复制到缓冲区中，修改也仅限于缓冲区中的数据；
3. 将执行结果输出。

当一行数据匹配完成后，它会继续读取下一行数据，并重复这个过程，直到将文件中所有数据处理完毕。

 sed 命令的基本格式如下： 

```

 [root@localhost ~]# sed [选项] [脚本命令] 文件名 
```

该命令常用的选项及含义，如表 1 所示。

| 选项            | 含义                                                         |
| --------------- | ------------------------------------------------------------ |
| -e 脚本命令     | 该选项会将其后跟的脚本命令添加到已有的命令中。               |
| -f 脚本命令文件 | 该选项会将其后文件中的脚本命令添加到已有的命令中。           |
| -n              | 默认情况下，sed 会在所有的脚本指定执行完毕后，会自动输出处理后的内容，而该选项会屏蔽启动输出，需使用 print 命令来完成输出。 |
| -i              | 此选项会直接修改源文件，要慎用。                             |

 成功使用 sed 命令的关键在于掌握各式各样的脚本命令及格式，它能帮你定制编辑文件的规则。 

## sed脚本命令

#### sed s 替换脚本命令

此命令的基本格式为：

[address]s/pattern/replacement/flags

其中，address 表示指定要操作的具体行，pattern 指的是需要替换的内容，replacement 指的是要替换的新内容。
此命令中常用的 flags 标记如表 2 所示。

| flags 标记 | 功能                                                         |
| ---------- | ------------------------------------------------------------ |
| n          | 1~512 之间的数字，表示指定要替换的字符串出现第几次时才进行替换，例如，一行中有 3 个 A，但用户只想替换第二个 A，这是就用到这个标记； |
| g          | 对数据中所有匹配到的内容进行替换，如果没有 g，则只会在第一次匹配成功时做替换操作。例如，一行数据中有 3 个 A，则只会替换第一个 A； |
| p          | 会打印与替换命令中指定的模式匹配的行。此标记通常与 -n 选项一起使用。 |
| w file     | 将缓冲区中的内容写到指定的 file 文件中；                     |
| &          | 用正则表达式匹配的内容进行替换；                             |
| \n         | 匹配第 n 个子串，该子串之前在 pattern 中用 \(\) 指定。       |
| \          | 转义（转义替换部分包含：&、\ 等）                            |

比如，可以指定 sed 用新文本替换第几处模式匹配的地方：

```
vim test.txt

This is a test of the test script.
This is the second test of the test script.
```

```
sed 's/test/trial/2' test.txt
This is a test of the trial script.
This is the second test of the trial script.
```

 可以看到，使用数字 2 作为标记的结果就是，sed 编辑器只替换每行中第 2 次出现的匹配模式。

如果要用新文件替换所有匹配的字符串，可以使用 g 标记： 

```
sed 's/test/trial/g' test.txt
This is a trial of the trial script.
This is the second trial of the trial script.
```

 -n 选项会禁止 sed 输出，但 p 标记会输出修改过的行，将二者匹配使用的效果就是只输出被替换命令修改过的行，例如： 

```
sed -n 's/test/trial/p' test1.txt 
This is a trial line.

```

 w 标记会将匹配后的结果保存到指定文件中，比如： 

```
sed 's/test/trial/w testnew.txt' test1.txt 
This is a trial line.
This is a different line.
```

cat testnew.txt 
This is a trial line.



在使用 s 脚本命令时，替换类似文件路径的字符串会比较麻烦，需要将路径中的正斜线进行转义，例如：

```
sed 's/\/bin\/bash/\/bin\/csh/' /etc/passwd
```

#### sed d 替换脚本命令

此命令的基本格式为：

[address]d

如果需要删除文本中的特定行，可以用 d 脚本命令，它会删除指定行中的所有内容。但使用该命令时要特别小心，如果你忘记指定具体行的话，文件中的所有内容都会被删除，举个例子：

cat test.txt 
The quick brown fox jumps over the lazy dog
The quick brown fox jumps over the lazy dog
The quick brown fox jumps over the lazy dog
The quick brown fox jumps over the lazy dog

sed 'd' test.txt

 \#什么也不输出，证明成了空文件 

 当和指定地址一起使用时，删除命令显然能发挥出大的功用。可以从数据流中删除特定的文本行。

address 的具体写法后续会做详细介绍，这里只给大家举几个简单的例子： 

```
cat test.txt 
This is line number 1.
This is line number 2.
This is line number 3.
This is line number 4.

 sed '3d' test.txt 
This is line number 1.
This is line number 2.
This is line number 4.
```

 或者通过特定行区间指定，比如删除 data6.txt 文件内容中的第 2、3行： 

```
sed '2,3d' test.txt 
This is line number 1.
This is line number 4.

```

 也可以使用两个文本模式来删除某个区间内的行，但这么做时要小心，你指定的第一个模式会“打开”行删除功能，第二个模式会“关闭”行删除功能，因此，sed 会删除两个指定行之间的所有行（包括指定的行），例如： 

```
sed '/1/,/3/d' test.txt 
This is line number 4.

```

 或者通过特殊的文件结尾字符，比如删除 data6.txt 文件内容中第 3 行开始的所有的内容： 

sed '3,$d' test.txt 
This is line number 1.
This is line number 2.

 在此强调，在默认情况下 sed 并不会修改原始文件，这里被删除的行只是从 sed 的输出中消失了，原始文件没做任何改变。 

#### sed a 和 i 脚本命令

a 命令表示在指定行的后面附加一行，i 命令表示在指定行的前面插入一行，这里之所以要同时介绍这 2 个脚本命令，因为它们的基本格式完全相同，如下所示：

 [address]a（或 i）\新文本内容 

 下面分别就这 2 个命令，举几个例子。比如说，将一个新行插入到数据流第三行前，执行命令如下： 

```
 sed '3i  This is an inserted line.' test.txt 
This is line number 1.
This is line number 2.
This is an inserted line.
This is line number 3.
This is line number 4.

```

 再比如说，将一个新行附加到数据流中第三行后，执行命令如下 

```
sed '3a  This is an inserted line.' test.txt 
This is line number 1.
This is line number 2.
This is line number 3.
This is an inserted line.
This is line number 4.

```

 如果你想将一个多行数据添加到数据流中，只需对要插入或附加的文本中的每一行末尾（除最后一行）添加反斜线即可，例如： 

```
sed '1i This is one line of new text.\
This another line of new text.' test.txt
This is one line of new text.
This another line of new text.
This is line number 1.
This is line number 2.
This is line number 3.
This is line number 4.

```

 可以看到，指定的两行都会被添加到数据流中。 

#### sed c 替换脚本命令

c 命令表示将指定行中的所有内容，替换成该选项后面的字符串。该命令的基本格式为：

```
sed '3cThis is a changed line of text.' test.txt 
This is line number 1.
This is line number 2.
This is a changed line of text.
This is line number 4.

```

#### sed r 脚本命令

r 命令用于将一个独立文件的数据插入到当前数据流的指定位置，该命令的基本格式为：

[address]r filename

sed 命令会将 filename 文件中的内容插入到 address 指定行的后面，比如说：
```
[root@server1 ~]# cat test2.txt 
This is an added line.
This is the second added line.
[root@server1 ~]# sed '3r test2.txt' test.txt 
This is line number 1.
This is line number 2.
This is line number 3.
This is an added line.
This is the second added line.
This is line number 4.
```


如果你想将指定文件中的数据插入到数据流的末尾，可以使用 $ 地址符，例如：

```
 sed '$r test2.txt' test.txt 
This is line number 1.
This is line number 2.
This is line number 3.
This is line number 4.
This is an added line.
This is the second added line.
```



#### sed q 退出脚本命令

q 命令的作用是使 sed 命令在第一次匹配任务结束后，退出 sed 程序，不再进行对后续数据的处理。
比如：

```
sed '2q' test.txt 
This is line number 1.
This is line number 2.

```



可以看到，sed 命令在打印输出第 2 行之后，就停止了，是 q 命令造成的，再比如：

```
sed '/number 1/{ s/number 1/number 0/;q; }' test.txt
This is line number 0.

```



[root@localhost ~]# sed '/number 1/{ s/number 1/number 0/;q; }' test.txt
This is line number 0.

使用 q 命令之后，sed 命令会在匹配到 number 1 时，将其替换成 number 0，然后直接退出。

#### sed 脚本命令的寻址方式

前面在介绍各个脚本命令时，我们一直忽略了对 address 部分的介绍。对各个脚本命令来说，address 用来表明该脚本命令作用到文本中的具体行。



[address]脚本命令

或者

address {
  多个脚本命令
}

以上两种形式在前面例子中都有具体实例，因此这里不再做过多赘述。

#### 以数字形式指定行区间

当使用数字方式的行寻址时，可以用行在文本流中的行位置来引用。sed 会将文本流中的第一行编号为 1，然后继续按顺序为接下来的行分配行号。

 在脚本命令中，指定的地址可以是单个行号，或是用起始行号、逗号以及结尾行号指定的一定区间范围内的行。这里举一个 sed 命令作用到指定行号的例子： 

```

 [root@localhost ~]#sed '2s/dog/cat/' data1.txt
The quick brown fox jumps over the lazy dog
The quick brown fox jumps over the lazy cat
The quick brown fox jumps over the lazy dog
The quick brown fox jumps over the lazy dog 
```

 可以看到，sed 只修改地址指定的第二行的文本。下面的例子中使用了行地址区间： 

```
[root@localhost ~]# sed '2,3s/dog/cat/' data1.txt
The quick brown fox jumps over the lazy dog
The quick brown fox jumps over the lazy cat
The quick brown fox jumps over the lazy cat
The quick brown fox jumps over the lazy dog
```

 在此基础上，如果想将命令作用到文本中从某行开始的所有行，可以用特殊地址——美元符（$）： 

```
[root@localhost ~]# sed '2,$s/dog/cat/' data1.txt
The quick brown fox jumps over the lazy dog
The quick brown fox jumps over the lazy cat
The quick brown fox jumps over the lazy cat
The quick brown fox jumps over the lazy cat
```

# sed 常用选项 -i 的使用

替换指定文件的内容


```
sed -i 's/This/这个/g' test.txt
cat test.txt 
这个 is line number 1.
这个 is line number 2.
这个 is line number 3.
这个 is line number 4.
```

s 是替换，g是全局替换

**替换指定目录下所有文件的指定内容**

```
ls test/
test.txt  test.txt1  test.txt2  test.txt3
[root@server1 ~]# cat test/test.txt
This is line number 1.
This is line number 2.
This is line number 3.
This is line number 4.

test.txt 和test.txt1-3的内容是一样的
下面这条命令是查看test目录下所有有This内容的文件名，
grep -rl "This" test
test/test.txt
test/test.txt1
test/test.txt2
test/test.txt3
现在开始替换
sed -i 's/This/这个/g' `grep -rl "This" test`
现在test目录下的所有的文件都替换好了

cat test/test.txt
这个 is line number 1.
这个 is line number 2.
这个 is line number 3.
这个 is line number 4.



```

