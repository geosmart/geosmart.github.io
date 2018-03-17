title: CentOS常用脚本
date: 2015-07-06 16:41:15
tags: [CentOS,Shell]
categories: [运维]
---

CentOS日常使用过程中积累的Shell脚本或Linux命令，持续维护更新  


<!-- more -->

# 网络设置
## HostName主机名
``` shell
#查看hostname
hostname  
#设置指定的域名解析地址
/etc/hosts       
# 设置主机名和网络配置
/etc/sysconfig/network   
```

## 静态IP设置
[下载 static-ip-centos6.sh](static-ip-centos6.sh)  
参数: `static-ip.sh <hostname> <interface> <baseip> <ipaddress> <gateway/dns>`  
示例
``` shell
chmod +x  ./static-ip.sh && ./static-ip.sh localhost eth0 192.168.1 81 1
```

[下载 static-ip-centos7.sh](static-ip-centos7.sh)  
参数: 在文件中修改ip相关参数


手动设置IP  

``` shell
#临时设置IP
ifconfig eth0 192.168.1.160
# 设置DNS  
/etc/resolv.conf  
临时设置IP
ifconfig eth0 192.168.1.160
```

``` shell
#针对特定的网卡进行手动设置
vim /etc/sysconfig/network-scripts/ifcfg-eth0

DEVICE="eth0"
BOOTPROTO="static"
HWADDR="00:0C:29:86:3D:16"
IPV6INIT="yes"
NM_CONTROLLED="yes"
ONBOOT="yes"
TYPE="Ethernet"
UUID="dcf18d86-45ea-4b5c-9627-e75b19b3b6e7"
IPADDR=192.168.1.82
NETMAST=255.255.255.0
DNS1=192.168.1.1
```

## 集群环境下ssh免密码登陆认证脚本   
[todo-gitrepository]()
1. 确保各节点安装ssh,expect
2. 把所有文件拷贝到主节点上
3. 配置hosts.conf和slaves.conf
4. 执行keygen_master

``` shell
chmod +x keygen_master.sh
./keygen_master.sh
```

# PS查看进程
通常用ps查看进程PID，kill终止进程
* grep 是搜索  
例如：`ps -ef | grep java`表示查看所有进程里 CMD 是 java 的进程信息  
* -aux 显示所有状态   
`ps -aux | grep java`  
* kill 命令用于终止进程  
例如： `kill -9 [PID]`  
-9 表示强迫进程立即停止

# 端口查看
如查看80端口：`lsof -i tcp:80 `    
列出所有端口：`netstat -ntlp`

# nohup后台运行
后台运行test.jar  
`nohup java -jar test.jar`  
不输出nohup日志：>/dev/null 2>&1 &  
`nohup java -jar test.jar >/dev/null 2>&1 &`

# 重定向
* 0 表示标准输入  
* 1 标准输出,在一般使用时，默认的是标准输出  
* 2 标准错误信息输出  
可以用来指定需要重定向的标准输入或输出。例如，将某个程序的错误信息输出到log文件 中：./program 2>log。这样标准输出还是在屏幕上，但是错误信息会输出到log文件中。另外，也可 以实现0，1，2之间的重定向。2>&1：将错误信息重定向到标准输出。
* /dev/null  
它就像一个无底洞，所有重定向到它的信息都会消失得无影无踪。当我们不需要回显程序的所有信息时，就可以将输出重定到/dev/null。

# 读取文件头/尾/实时内容
* head filename读取头部，使用命令head。默认显示文件 filename 的前十行内容  
`head -n 20 filename `：显示文件的前20行内容  
`head -n -20 filename`  ：若n后面的整数为负数时，如则表示列出除尾部的20行外的所有行    
* tail filename 读取尾部，使用命令tail，使用方法同head相似  
`tail -n 20 filename `：显示文件的最后20行内容  
`tail -n +20 filename `：显示文件自第20行开始后的所有行（包括第20行）  
* `tail -f filename`：动态显示最新的文件内容  
具体用法man head或man tail获取  

# chkconfig问题
chkconfig --add myservice问题：service myservice does not support chkconfig
我们一般在脚本开头加入下面两句就好了
`vim  /etc/init.d/myservice`
添加下面两句到 #!/bin/bash 之后

``` shell
#!/bin/bash
# chkconfig: 2345 10 90
# description: myservice ....
```

# 图形化界面切换CentOS6
`vim /etc/inittab`

``` shell
# Default runlevel. The runlevels used by RHS are:
# 0 - halt (Do NOT set initdefault to this)          --停机
# 1 - Single user mode           --单用户模式
# 2 - Multiuser, without NFS (The same as 3, if you do not havenetworking)           --多用户模式，不支持NFS
# 3 - Full multiuser mode          --多用户模式     
# 4 - unused          --没有使用
# 5 - X11          --图形界面方式
# 6 - reboot (Do NOT set initdefault to this)          --重新启动
# --默认运行等级是5
id:5:initdefault:      
```
# 图形化界面切换CentOS7
使用systemd创建符号链接指向默认运行级别。

1. 首先删除已经存在的符号链接 
`rm /etc/systemd/system/default.target `
2. 默认级别转换为3(文本模式) 
`ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target `
或者默认级别转换为5(图形模式) 
`ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target `
3. 重启 
`reboot`

# 文件操作
## mkdir 新建目录
mkdir -p 无目录新建目录

## touch 新建文件
eg：`touch test.log`

## 追加文本到文件
eg：`echo "/opt/cm/etc/init.d/cloudera-scm-server start" >> /etc/rc.local `

## rm 文件删除参数：

``` shell
-r 就是向下递归，不管有多少级目录，一并删除
-f 就是直接强行删除，不作任何提示的意思
-rf 递归强制删除
```
需要提醒的是：使用这个rm -rf的时候一定要格外小心，linux没有回收站的  

## tar文件解压
tar在linux上是常用的打包、压缩、加压缩工具，他的参数很多，折里仅仅列举常用的压缩与解压缩参数   

``` shell
-c ：create 建立压缩档案的参数；
-x ： 解压缩压缩档案的参数；
-z ： 是否需要用gzip压缩；
-v： 压缩的过程中显示档案；
-f： 置顶文档名，在f后面立即接文件名，不能再加参数
1 将tgz文件解压到指定目录
tar   zxvf    test.tgz  -C  指定目录
比如将/source/kernel.tgz解压到  /source/linux-2.6.29 目录
tar  zxvf  /source/kernel.tgz  -C /source/ linux-2.6.29
```

# VIM操作
http://www.eepw.com.cn/article/48018.htm

vi删除*.swp临时文件删除
i插入
esc命令行
:底行（x或:wq保存）


# 查找操作
## find
find是最常见和最强大的查找命令，你可以用它找到任何你想找的文件。
find的使用格式如下：
```
　　$ find <指定目录> <指定条件> <指定动作>
　　- <指定目录>： 所要搜索的目录及其所有子目录。默认为当前目录。
　　- <指定条件>： 所要搜索的文件的特征。
　　- <指定动作>： 对搜索结果进行特定的处理。
```

如果什么参数也不加，find默认搜索当前目录及其子目录，并且不过滤任何结果（也就是返回所有文件），将它们全都显示在屏幕上。
find的使用实例：
```
　　$ find . -name "my*"
搜索当前目录（含子目录，以下同）中，所有文件名以my开头的文件。
　　$ find . -name "my*" -ls
搜索当前目录中，所有文件名以my开头的文件，并显示它们的详细信息。
　　$ find . -type f -mmin -10
搜索当前目录中，所有过去10分钟中更新过的普通文件。如果不加-type f参数，则搜索普通文件+特殊文件+目录。
```

## locate
locate命令其实是“find -name”的另一种写法，但是要比后者快得多，原因在于它不搜索具体目录，而是搜索一个数据库（/var/lib/locatedb），这个数据库中含有本地所有文件信息。Linux系统自动创建这个数据库，并且每天自动更新一次，所以使用locate命令查不到最新变动过的文件。为了避免这种情况，可以在使用locate之前，先使用updatedb命令，手动更新数据库。
locate命令的使用实例：

```
　　$ locate /etc/sh
搜索etc目录下所有以sh开头的文件。
　　$ locate ~/m
搜索用户主目录下，所有以m开头的文件。
　　$ locate -i ~/m
搜索用户主目录下，所有以m开头的文件，并且忽略大小写。
```

## whereis
whereis命令只能用于程序名的搜索，而且只搜索二进制文件（参数-b）、man说明文件（参数-m）和源代码文件（参数-s）。如果省略参数，则返回所有信息。
whereis命令的使用实例：`$ whereis grep`

## which
which命令的作用是，在PATH变量指定的路径中，搜索某个系统命令的位置，并且返回第一个搜索结果。也就是说，使用which命令，就可以看到某个系统命令是否存在，以及执行的到底是哪一个位置的命令。
which命令的使用实例：`$ which grep`

## type
type命令其实不能算查找命令，它是用来区分某个命令到底是由shell自带的，还是由shell外部的独立二进制文件提供的。如果一个命令是外部命令，那么使用-p参数，会显示该命令的路径，相当于which命令。
type命令的使用实例：

```
　　$ type cd
系统会提示，cd是shell的自带命令（build-in）。
　　$ type grep
系统会提示，grep是一个外部命令，并显示该命令的路径。
　　$ type -p grep
加上-p参数后，就相当于which命令。
```

#	系统时间
*	date 查看系统时间  
*	date -s 修改时间  
如：date -s  03/04/2013（将系统日期设定为2013年03月04日）
*	date -s  110:38（将系统时间设定为上午 10:38）   
修改完后执行：clock -w  ,强制将时间写入COMS！


# chmod命令详解　　
使用权限：所有使用者
使用方式：chmod [-cfvR] [--help] [--version] mode file...
说明：
Linux/Unix 的档案存取权限分为三级 : 档案拥有者、群组、其他。利用 chmod 可以藉以控制档案如何被他人所存取。
mode ：权限设定字串，格式如下 ：[ugoa...][[+-=][rwxX]...][,...]，其中u 表示该档案的拥有者，g 表示与该档案的拥有者属于同一个群体(group)者，o 表示其他以外的人，a 表示这三者皆是。
```shell
+ 表示增加权限、- 表示取消权限、= 表示唯一设定权限。
r 表示可读取，w 表示可写入，x 表示可执行，X 表示只有当该档案是个子目录或者该档案已经被设定过为可执行。
-c : 若该档案权限确实已经更改，才显示其更改动作
-f : 若该档案权限无法被更改也不要显示错误讯息
-v : 显示权限变更的详细资料
-R : 对目前目录下的所有档案与子目录进行相同的权限变更(即以递回的方式逐个变更)
--help : 显示辅助说明
--version : 显示版本
　　范例：
　　将档案 file1.txt 设为所有人皆可读取
chmod ugo+r file1.txt
　　将档案 file1.txt 设为所有人皆可读取
chmod a+r file1.txt
　　将档案 file1.txt 与 file2.txt 设为该档案拥有者，与其所属同一个群体者可写入，但其他以外的人则不可写入
chmod ug+w,o-w file1.txt file2.txt
　　将 ex1.py 设定为只有该档案拥有者可以执行
chmod u+x ex1.py
　　将目前目录下的所有档案与子目录皆设为任何人可读取
chmod -R a+r *
　　此外chmod也可以用数字来表示权限如 chmod 777 file
　　语法为：chmod abc file
　　其中a,b,c各为一个数字，分别表示User、Group、及Other的权限。
　　r=4，w=2，x=1
　　若要rwx属性则4+2+1=7；
　　若要rw-属性则4+2=6；
　　若要r-x属性则4+1=7。
　　范例：
　　chmod a=rwx file 和 chmod 777 file 效果相同
　　chmod ug=rwx,o=x file 和 chmod 771 file 效果相同
　　若用chmod 4755 filename可使此程式具有root的权限
```
# chown命令详解　　
使用权限：root
使用方式：chown [-cfhvR] [--help] [--version] user[:group] file...
说明：Linux/Unix 是多人多工作业系统，所有的档案皆有拥有者。利用chown 可以将档案的拥有者加以改变。一般来说，这个指令只有是由系统管理者(root)所使用，一般使用者没有权限可以改变别人的档案拥有者，也没有权限可以自己的档案拥有者改设为别人。只有系统管理者(root)才有这样的权限。
```shell
user : 新的档案拥有者的使用者
IDgroup : 新的档案拥有者的使用者群体(group)
-c : 若该档案拥有者确实已经更改，才显示其更改动作
-f : 若该档案拥有者无法被更改也不要显示错误讯息
-h : 只对于连结(link)进行变更，而非该 link 真正指向的档案
-v : 显示拥有者变更的详细资料
-R : 对目前目录下的所有档案与子目录进行相同的拥有者变更(即以递回的方式逐个变更)
--help : 显示辅助说明
--version : 显示版本
　　范例：
　　将档案 file1.txt 的拥有者设为 users 群体的使用者 jessie
chown jessie:users file1.txt
　　将目前目录下的所有档案与子目录的拥有者皆设为 users 群体的使用者 lamport
chown -R lamport:users *
-rw------- (600) -- 只有属主有读写权限。
-rw-r--r-- (644) -- 只有属主有读写权限；而属组用户和其他用户只有读权限。
-rwx------ (700) -- 只有属主有读、写、执行权限。
-rwxr-xr-x (755) -- 属主有读、写、执行权限；而属组用户和其他用户只有读、执行权限。
-rwx--x--x (711) -- 属主有读、写、执行权限；而属组用户和其他用户只有执行权限。
-rw-rw-rw- (666) -- 所有用户都有文件读、写权限。这种做法不可取。
-rwxrwxrwx (777) -- 所有用户都有读、写、执行权限。更不可取的做法。
以下是对目录的两个普通设定：
drwx------ (700) - 只有属主可在目录中读、写。
drwxr-xr-x (755) - 所有用户可读该目录，但只有属主才能改变目录中的内容
suid的代表数字是4，比如4755的结果是-rwsr-xr-x
sgid的代表数字是2，比如6755的结果是-rwsr-sr-x
sticky位代表数字是1，比如7755的结果是-rwsr-sr-t
```
# scp命令详解　
## 关于scp　
scp是secure copy的缩写，scp是linux系统下基于ssh登陆进行安全的远程文件拷贝命令。linux的scp命令可以在linux服务器之间复制文件和目录。
## scp命令的用途
scp在网络上不同的主机之间复制文件，它使用ssh安全协议传输数据，具有和ssh一样的验证机制，从而安全的远程拷贝文件。
scp命令基本格式：`scp [-1246BCpqrv] [-c cipher] [-F ssh_config] [-i identity_file]
[-l limit] [-o ssh_option] [-P port] [-S program]
[[user@]host1:]file1 [...] [[user@]host2:]file2`
## scp命令的参数说明
```shell
-1    强制scp命令使用协议ssh1
-2    强制scp命令使用协议ssh2
-4    强制scp命令只使用IPv4寻址
-6    强制scp命令只使用IPv6寻址
-B    使用批处理模式（传输过程中不询问传输口令或短语）
-C    允许压缩。（将-C标志传递给ssh，从而打开压缩功能）
-p 保留原文件的修改时间，访问时间和访问权限。
-q    不显示传输进度条。
-r    递归复制整个目录。
-v 详细方式显示输出。scp和ssh(1)会显示出整个过程的调试信息。这些信息用于调试连接，验证和配置问题。
-c cipher    以cipher将数据传输进行加密，这个选项将直接传递给ssh。
-F ssh_config    指定一个替代的ssh配置文件，此参数直接传递给ssh。
-i identity_file        从指定文件中读取传输时使用的密钥文件，此参数直接传递给ssh。
-l limit    限定用户所能使用的带宽，以Kbit/s为单位。
-o ssh_option    如果习惯于使用ssh_config(5)中的参数传递方式，
-P port 注意是大写的P, port是指定数据传输用到的端口号
-S program    指定加密传输时所使用的程序。此程序必须能够理解ssh(1)的选项。
```

## 从本地服务器复制到远程服务器    
复制文件命令格式：
```shell
scp local_file remote_username@remote_ip:remote_folder
scp local_file remote_username@remote_ip:remote_file
scp local_file remote_ip:remote_folder
scp local_file remote_ip:remote_file
```
实例
```shell
scp /home/linux/soft/scp.zip root@www.mydomain.com:/home/linux/others/soft
scp /home/linux/soft/scp.zip root@www.mydomain.com:/home/linux/others/soft/scp2.zip
scp /home/linux/soft/scp.zip www.mydomain.com:/home/linux/others/soft
scp /home/linux/soft/scp.zip www.mydomain.com:/home/linux/others/soft/scp2.zip
```
复制目录命令格式：
```shell
scp -r local_folder remote_username@remote_ip:remote_folder
scp -r local_folder remote_ip:remote_folder
```
实例:将 本地 soft 目录 复制 到 远程 others 目录下，即复制后远程服务器上会有/home/linux/others/soft/ 目录
```shell
scp -r /home/linux/soft/ root@www.mydomain.com:/home/linux/others/
scp -r /home/linux/soft/ www.mydomain.com:/home/linux/others/
```
## 从远程服务器复制到本地服务器
从远程复制到本地的scp命令与上面的命令雷同，只要将从本地复制到远程的命令后面2个参数互换顺序就行了。
例如
```shell
scp root@www.mydomain.com:/home/linux/soft/scp.zip /home/linux/others/scp.zip
scp  -r www.mydomain.com:/home/linux/soft/ /home/linux/others/
```

# rpm命令
命令格式 rpm {-q|--query} [select-options] [query-options]

# yum命令
## yum切换阿里云源
```bash
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum makecache
```
## 查询 
`yum search {name}`

## 安装
`yum install {name}`