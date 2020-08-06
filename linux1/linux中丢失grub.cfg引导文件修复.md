[toc]



#  一，linux中丢失grub.cfg引导文件修复

在Linux中不小心删除了grub文件，会导致系统起不来，那我们怎么解决这个问题呢？当然重装可以解决，但是就丢失了这么一个文件而重装系统未免有些小题大做了吧！下面有一个比较便捷的方法解决这个问题？

首先我们要知道系统在打开电源的那一刻，之后电脑都做了什么（即系统的启动流程）。

1.BIOS 初始化

2.启动加载器

3.内核初始化

4.init 启动

而grub或者是引导程序丢失，问题出现在BIOS的初始化阶段，下面以RedHat 7.0为列子来演示：

## 问题解决：
**当系统没有重新启动时**
```
grub2-mkconfig > /boot/grub2/grub.cfg 
## grub2-mkconfig输出的就是/boot/grub2/grub.cfg的文件内容
   grub2-mkconfig中的内容与grub.cfg相同，将内容导到引导文件中
   使用该命令直接生成新的引导文件即可。
```

**当系统重新启动后**
1.丢失grub后再次启动系统时，系统会在grub那停住，如下：

[![aaGAaD.png](https://s1.ax1x.com/2020/08/03/aaGAaD.png)](https://imgchr.com/i/aaGAaD)

执行如下的命令：

![aaGJiQ.png](https://s1.ax1x.com/2020/08/03/aaGJiQ.png)




(1)set  查看环境变量，这里可以查看启动路径和分区。

(2)ls  查看设备

(3)insmod  加载模块

(4)root  指定用于启动系统的分区,在救援模式下设置grub启动分区

(5)prefix 设定grub启动路径

```


grub> ls 
grub> ls (hd0,msdos1)/ 
# 查看当前分区

 1， set root=’hd0,msdos1’   
   ##set root是找boot分区的挂载点
   ##hd0，msdos1是第一块硬盘的第一个分区，根据自己系统/boot分区的实际位置确定 
  （如果/boot分区单独列出，则写的是/boot分区所在的硬盘分区号
    如果不是独立出的，就写/分区所在的硬盘分区号)     
 2， linux16 /boot/vmlinuz-3.10.0-123.e17.x86_64 ro root=/dev/vda1 
   ##linux16...系统内核文件  ##/dev/vda1为/分区所在的设备名。
   指定内核文件以及根分区所在位置。
   （如果/boot分区独立出来，那么直接写/vm...；
   linux16 /vmlinuz-3.10.0-693.el7.x86_64 root=/dev/mapper/centos-root ro 
     如果/boot分区不是独立出的，那么就写/boot/vm...）
 3， initrd16 /boot/initramfs-3.10.0-123.e17.x86_64.img     
    ##系统初始化镜像文件 
   （如果/boot分区独立出来，那么直接写/in...；
     initrd16 /initramfs-3.10.0-693.el7.x86_64.img   
     如果/boot分区不是独立出的，那么就写/boot/vm...）
 4， grub>boot
```

以上操作可以使系统正常启动，进入系统后还需要执行，才能生成新的引导文件，确保下次正常系统正常启动。

```
cd /boot/grub2/
grub2-mkconfig > /boot/grub2/grub.cfg 

```



如果还有问题，那么要通过系统拯救来完成了，在进入grub界面后输入exit，进入系统安装菜单，选择Troubleshooting后在选择救援模式（rescue）按照提示来完成。挂载根后即（chroot /mnt/sysimage）,执行grub2-mkconfig > /boot/grub2/grub.cfg 命令后exit即可。

# 二，关于error file: /boot/grub2/i386-pc/normal.mod not found. Grub Rescue的修复问题



有时候不小心把/boot/grub2/i386-pc/的文件删掉或者其他原因丢失了，重启或服务器突然关机后，会出现问题，

![aaGXOP.png](https://s1.ax1x.com/2020/08/03/aaGXOP.png)



这时候只能通过进入系统救援模式来修复，以VMware虚拟机为例；

1、在VMware下首先确认是否挂载了需要的光盘映像，打开设置，按照下方图片进行设置。

2、然后选择'重新启动客户机'，在弹出的页面选择'确认重新启动'。

3、在VMware重启后，先将鼠标挪到开机界面上，按下鼠标左键点进去，然后快速按一下ESC键(只能按一次)，

4、在VMware下按ESC可以临时把启动菜单调出来，然后选择用哪个设备来引导，这时我们选用的是光盘引导，即第三项'CD-ROM Drive'，回车。

![aaJy0f.png](https://s1.ax1x.com/2020/08/03/aaJy0f.png)

5、到了下图界面，选择'Troubleshoooting'，回车。

![aaJRhQ.png](https://s1.ax1x.com/2020/08/03/aaJRhQ.png)

6、这时终于看到'Rescue a CentOS Linux system'即救援模式，选择此项，回车.

![aaJTBV.png](https://s1.ax1x.com/2020/08/03/aaJTBV.png)

7、接下来系统将试图查找根分区，出现如下图所示。因为要对系统进行修复，所以需要读写权限，一般选择默认选项'continue'，输入1，回车。

![aaYdET.png](https://s1.ax1x.com/2020/08/03/aaYdET.png)

8、可以看到系统提示'your system has been mounted under /mnt/sysimage.'此时挂载成功。我们还可以选择执行'chroot /mnt/sysimage'命令，可以将根目录挂载到我们硬盘系统的根目录中去。此时我们不执行这条命令，按enter直接进入shell。

![aaYcK1.png](https://s1.ax1x.com/2020/08/03/aaYcK1.png)



9、进入shell命令行，提示符为sh-4.2#

```
ls /mnt/sysimage/ 显示挂载的目录为根目录的文件

执行  chroot /mnt/sysimage/    ## 将/mnt/sysimage/目录下的文件移动到根目录；
```
命令后提示符为bash-4.2#

10，此时找到我们需要的文件ls  /usr/lib/grub/，复制到/boot/grub2/目录下即可。复制完成后，就可以执行'exit'命令，退出光盘shell，接着系统将重启，耐心等待。输入两次exit,

```
cp -a /usr/lib/grub/i386-pc /boot/grub2/i386-pc  

ls  /boot/grub2/i386-pc/normal.mod    #查看是否有这个文件
```

然后就修复了

![aaYOVf.png](https://s1.ax1x.com/2020/08/03/aaYOVf.png)



