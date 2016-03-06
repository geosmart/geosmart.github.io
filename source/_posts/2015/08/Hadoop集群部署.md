title: Hadoop集群部署
date: 2015-08-08 11:38:22
tags: [分布式,CDH,Hadoop]
categories: [大数据,运维]
---

# Hadoop版本区别
目前不收费的Hadoop版本主要有三个，分别是：
1. Apache（最原始的版本，所有发行版均基于这个版本进行改进）
2. Cloudera版本（Cloudera’s Distribution Including Apache Hadoop，简称CDH）
3. Hortonworks版本(Hortonworks Data Platform，简称“HDP”），对于国内而言，绝大多数选择CDH版本，

CDH和Apache版本主要区别：
- CDH对Hadoop版本的划分非常清晰，目前维护的有两个系列的版本，分别是cdh4和cdh5
- 由于Cloudera做Hadoop开发的，其他厂商仅是做Hadoop集成或CDH集成，和Hadoop trunk能最快的同步，保证业务的前向兼容性；
- 安全 CDH支持Kerberos安全认证，apache hadoop则使用简陋的用户名匹配认证
- CDH文档清晰（包括中文文档），很多采用Apache版本的用户都会阅读CDH提供的文档，包括安装文档、升级文档等。
- CDH支持Yum/Apt包，Tar包，RPM包，CM安装，Cloudera Manager三种方式安装,Apache hadoop只支持Tar包安装。

- - -
<!-- more -->

# 关于CDH
[官方介绍](http：//www.cloudera.com/content/cloudera/zh-CN/documentation/core/v5-3-x/topics/introduction.html)  
Cloudera 提供一个可扩展、灵活、集成的平台，可用来方便地管理您的企业中快速增长的多种多样的数据。业界领先的 Cloudera 产品和解决方案使您能够部署并管理 Apache Hadoop 和相关项目、操作和分析您的数据以及保护数据的安全。

Cloudera 提供下列产品和工具：
- CDH — Cloudera 分发的 Apache Hadoop 和其他相关开放源代码项目，包括 Impala 和 Cloudera Search。CDH 还提供安全保护以及与许多硬件和软件解决方案的集成。
- Cloudera Manager — 一个复杂的应用程序，用于部署、管理、监控您的 CDH 部署并诊断问题。Cloudera Manager 提供 Admin Console，这是一种基于 Web 的用户界面，使您的企业数据管理简单而直接。它还包括 Cloudera Manager API，可用来获取群集运行状况信息和度量以及配置 Cloudera Manager。
- Cloudera Navigator — CDH 平台的端到端数据管理工具。Cloudera Navigator 使管理员、数据经理和分析师能够了解 Hadoop 中的大量数据。Cloudera Navigator 中强大的审核、数据管理、沿袭管理和生命周期管理使企业能够遵守严格的法规遵从性和法规要求。
- Cloudera Impala — 一种大规模并行处理 SQL 引擎，用于交互式分析和商业智能。其高度优化的体系结构使它非常适合用于具有联接、聚合和子查询的传统 BI 样式的查询。它可以查询来自各种源的 Hadoop 数据文件，包括由 MapReduce 作业生成的数据文件或加载到 Hive 表中的数据文件。YARN 和 Llama 资源管理组件让 Impala 能够共存于使用 Impala SQL 查询并发运行批处理工作负载的群集上。您可以通过 Cloudera Manager 用户界面管理 Impala 及其他 Hadoop 组件，并通过 Sentry 授权框架保护其数据。

# Cloudera QuickStart VM
[下载地址](http：//www.cloudera.com/content/cloudera/en/downloads/quickstart_vms/cdh-5-4-x.html)
为方便开始使用CDH、Cloudera Manager、Cloudera Impala 和 Cloudera Search，这些虚拟机器包含您所需的一切。

# CDH安装步骤
## CDH安装参考资料
- [cloudera简介](http：//zh-cn.cloudera.com/content/cloudera/en/products-and-services/cloudera-enterprise.html)
- [cdh5官方文档](http：//www.cloudera.com/content/cloudera/zh-CN/documentation/core/v5-3-x/topics/introduction.html)
- [CDH5安装环境要求](http：//www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_req_supported_versions.html)
- [CDH5的3种安装方式](http：//www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/installation_installation.html)
- [在线Yum/Wget安装教程](http：//www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cm_ig_install_path_a.html#concept_vk4_psb_zm_unique_4)
- [在线Yum/Wget安装教程-中文](http：//www.aboutyun.com/thread-9219-1-1.html)

## 在线安装优势
1. 联网安装、升级，非常方便
2. 自动下载依赖软件包
3. Hadoop生态系统包自动匹配，不需要你寻找与当前Hadoop匹配的Hbase，Flume，Hive等软件，Yum/Apt会根据当前安装Hadoop版本自动寻找匹配版本的软件包，并保证兼容性。
4. 自动创建相关目录并软链到合适的地方（如conf和logs等目录）；自动创建hdfs, mapred用户，hdfs用户是HDFS的最高权限用户，mapred用户则负责mapreduce执行过程中相关目录的权限。

## 在线安装步骤
### 静态IP配置  
` cd /mnt/scripts/batch-update-ip && chmod +x static-ip.sh && ./static-ip.sh localhost eth1 192.168.1 81 1 `
示例：`cd /mnt/scripts/batch-update-ip && chmod +x static-ip.sh && ./static-ip.sh slave3.lt.com eth1 192.168.1 103 1`

[脚本地址](todo)

### HostName配置/FQDN配置  
FQDN是Fully Qualified Domain Name的缩写, 含义是完整的域名. 例如, 一台机器主机名(hostname)是www, 域后缀(domain)是example.com, 那么该主机的FQDN应该是www.example.com.
注意：hosts配置不当，后面server和agent间通讯会存在问题，参考host配置如下：
- server/agent配置(master)

``` shell
# vim /etc/hosts

# solr/hue/hive server
127.0.0.1 localhost.localdomain localhost

192.168.1.90   cdhagent.lt.com cdhagent

192.168.1.91   server1.lt.com server1
192.168.1.92   server2.lt.com server2
192.168.1.93   server3.lt.com server3
192.168.1.94   server4.lt.com server4
192.168.1.95   server5.lt.com server5

# HDFS NameNode
192.168.1.100  master.lt.com master

# HDFS DataNode
192.168.1.101  slave1.lt.com slave1
192.168.1.102  slave2.lt.com slave2
192.168.1.103  slave3.lt.com slave3
192.168.1.104  slave4.lt.com slave4
192.168.1.105  slave5.lt.com slave5
192.168.1.106  slave6.lt.com slave6
192.168.1.107  slave7.lt.com slave7
192.168.1.108  slave8.lt.com slave8
192.168.1.109  slave9.lt.com slave9
192.168.1.110  slave10.lt.com slave10

```

- network配置

``` shell
# vim /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=master.lt.com
NTPSERVERARGS=iburst
```

*TODO：可局域网搭建DNS服务器，Slave机器即可不配配置hosts*

### SSH无密码登陆配置  
*TODO：补充github脚本地址*
删除现有ssh配置（可选）：rm /root/.ssh/authorized_keys && rm /root/.ssh/known_hosts
`cd /mnt/scripts/batch-ssh && chmod +x keygen_master.sh && ./keygen_master.sh`

### iptables防火墙配置  

``` bash
#查看防火墙状态
service iptables status
#关闭防火墙
service iptables stop
#永久关闭防火墙
chkconfig iptables off
```

### selinux强制访问控制安全配置  

``` shell
#查看SELinux状态
/usr/sbin/sestatus -v
#或命令
getenforce
#关闭SELinux
#1. 临时关闭（不用重启机器）：
setenforce 0                  ##设置SELinux 成为permissive模式
                              ##setenforce 1 设置SELinux 成为enforcing模式
#2. 修改配置文件
vim /etc/selinux/config
#将SELINUX=enforcing改为SELINUX=disabled
#3. reboot
```

### swap配置
Cloudera 建议将 /proc/sys/vm/swappiness 设置为 0。默认设置为 60。
查看当前swap分区设置` cat /proc/sys/vm/swappiness`  
临时修改值：`sudo sysctl vm.swappiness=0`  
永久修改值：`vim /etc/sysctl.conf`，在最后加一行`vm.swappiness = 0`

```
swappiness的值的大小对如何使用swap分区是有着很大的联系
swappiness=0的时候表示最大限度使用物理内存，然后才是 swap空间
swappiness＝100的时候表示积极的使用swap分区，并且把内存上的数据及时的搬运到swap空间里面
```
### 安装NTP服务
[NTP配置教程](http://acooly.iteye.com/blog/1993484)
集群中所有主机必须保持时间同步，如果时间相差较大会引起各种问题。 具体思路如下：
master节点作为ntp服务器与外界对时中心同步时间，随后对所有datanode节点提供时间同步服务。
所有datanode节点以master节点为基础同步时间。
所有节点安装相关组件： `yum install ntp` 。
配置开机启动： `chkconfig ntpd on` ,
检查是否设置成功： `chkconfig --list ntpd` 其中2-5为on状态就代表成功。

*	主节点配置
在配置之前，先使用ntpdate手动同步一下时间，免得本机与对时中心时间差距太大，使得ntpd不能正常同步。 ntpdate -u 202.112.29.82
编辑`/etc/ntp.conf`配置文件，配置完成后启动服务`service ntpd start`

```shell
driftfile /var/lib/ntp/drift

restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery

restrict 127.0.0.1
restrict -6 ::1

#允许内网其他机器同步时间
restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap

# 中国这边最活跃的时间服务器 : http://www.pool.ntp.org/zone/cn
server 3.cn.pool.ntp.org perfer  
server 1.asia.pool.ntp.org         
server 3.asia.pool.ntp.org

# 外部时间服务器不可用时，以本地时间作为时间服务
server  127.127.1.0     # local clock
fudge   127.127.1.0 stratum 10

includefile /etc/ntp/crypto/pw

keys /etc/ntp/keys
server 127.127.1.0 iburst
```

查看配置结果：   
*	`netstat -tlunp | grep ntp` 查看服务连接和监听
*	`ntpq -p `查看网络中的NTP服务器，同时显示客户端和每个服务器的关系
*	`ntpstat` 查看时间同步状态

*	NTP客户端配置
编辑`/etc/ntp.conf`配置文件，配置完成后启动服务`service ntpd restart`

```shell
driftfile /var/lib/ntp/drift
restrict 127.0.0.1
restrict -6 ::1

# 配置时间服务器为本地的时间服务器
server 192.168.1.100

restrict 192.168.1.100 nomodify notrap noquery

server  127.127.1.0     # local clock
fudge   127.127.1.0 stratum 10

includefile /etc/ntp/crypto/pw

keys /etc/ntp/keys
```


### cloudera-manager-installer.bin安装  

``` shell
wget http：//archive.cloudera.com/cm5/installer/latest/cloudera-manager-installer.bin
chmod u+x cloudera-manager-installer.bin
sudo ./cloudera-manager-installer.bin
```

### 在线配置  
打开http：//{host}：7180/cmf/login  
默认用户名/密码：admin/admin  
[cloudera配置文件](http：//www.aboutyun.com/thread-9189-1-1.html)


# CDH5运维相关
## 系统服务
服务查询：`service --status-all| grep cloudera `  
_服务端_  
- cloudera-scm-server
- cloudera-scm-server-db  
_客户端_  
- cloudera-scm-agent

## 嵌入式 PostgreSQL 数据库
[嵌入式 PostgreSQL 数据库](http://www.cloudera.com/content/cloudera/zh-CN/documentation/core/v5-3-x/topics/cm_ig_embed_pstgrs.html)  
[修改postgresql配置允许远程访问](http://www.linuxidc.com/Linux/2013-10/91446.htm)  

*	scm数据库密码

```shell
# cat /etc/cloudera-scm-server/db.properties
com.cloudera.cmf.db.type=postgresql
com.cloudera.cmf.db.host=localhost:7432
com.cloudera.cmf.db.name=scm
com.cloudera.cmf.db.user=scm
com.cloudera.cmf.db.password=30MCe9Mxuk
```
*	root密码： `/var/lib/cloudera-scm-server-db/data/generated_password.txt`

## 卸载Cloudera
[卸载 Cloudera Manager 和托管软件](http://www.cloudera.com/content/cloudera/zh-CN/documentation/core/v5-3-x/topics/cm_ig_uninstall_cm.html)
[参考博客](http://student-lp.iteye.com/blog/2158887)


## Cloudera Manager API
[官方文档](http://zh-cn.cloudera.com/content/cloudera/en/documentation.html)
Cloudera Manager API 提供了配置和服务生命周期管理、服务运行状况信息和指标，并允许您配置 Cloudera Manager 本身。此 API 与 Cloudera Manager Admin Console 在同一主机和端口上接受服务，不需要任何额外过程或额外配置。此 API 支持 HTTP 基本验证，接受的用户和凭据与 Cloudera Manager Admin Console 相同。


## Cloudera Management Service
Cloudera Management Service 可作为一组角色实施各种管理功能：
Activity Monitor - 收集有关 MapReduce 服务运行的活动的信息。默认情况下未添加此角色。
Host Monitor - 收集有关主机的运行状况和指标信息
Service Monitor - 收集有关服务的运行状况和指标信息以及 YARN 和 Impala 服务中的活动信息
Event Server - 聚合 relevant Hadoop 事件并将其用于警报和搜索
Alert Publisher - 为特定类型的事件生成和提供警报
Reports Manager - 生成报告，它提供用户、用户组和目录的磁盘使用率的历史视图，用户和 YARN 池的处理活动，以及 HBase 表和命名空间。此角色未在 Cloudera Express 中添加。
Cloudera Manager 将单独管理每个角色，而不是作为 Cloudera Manager Server 的一部分进行管理，可实现可扩展性（例如，在大型部署中，它可用于将监控器角色置于自身的主机上）和隔离。

此外，对于特定版本的 Cloudera Enterprise 许可证，Cloudera Management Service 还为 Cloudera Navigator 提供 Navigator Audit Server 和 Navigator Metadata Server 角色。


# 安装问题记录

1. 无法发出查询：未能连接到 Host Monitor
解决方式：新增cloudera management services ,注意新增的目标机器因为scm-server安装的同一台机器，机器内存最好>=8G

2. urlopen error [Errno 111] Connection refused
- 问题场景：CM中主机CDH5安装Parcel完成后无法分配和激活Agent
- 详细日志：downloader INFO  Finished download [ url： http：//master.lt.com：7180/cmf/parcel/download/CDH-5.4.4-1.cdh5.4.4.p0.4-el6.parcel, state： exception, total_bytes： 0, downloaded_bytes： 0, start_time： 2015-08-11 22：18：32, download_end_time： , end_time： 2015-08-11 22：18：33, code： 600, exception： <urlopen error [Errno 111] Connection refused>, path： None ]
- 错误分析：在slave机器执行`nc -v master.lt.com  7182` 返回refused，判断是host配置有误导致dns解析不了
- 解决方式：在slave1的hosts中新增master的域名解析

3. 正在获取安装锁.问题
意外中止安装后重新安装提示”正在获取安装锁...“
在Manager节点运行`rm /tmp/.scm_prepare_node.lock`删除Manager的lock文件后重新安装即可

4. 对于此 Cloudera Manager 版本 (5.4.7) 太新的 CDH 版本不会显示
*	问题描述：Versions of CDH that are too new for this version of Cloudera Manager (5.4.7) will not be shown.
*	问题定位：PARCELS表fileName=CDH-5.4.7-1.cdh5.4.7.p0.3-el6.parcel的hash值为null，判断为parcel文件问题或scm数据库生成干扰问题
*	解决思路：判断为/opt/cloudera/parcel-repo/目录内的本地parcel应该在scm数据库初始化结束后再放入
*	问题解决：停止server>重置scm数据库>启动server>复制parcel到/opt/cloudera/parcel-repo/目录

[参考](https://community.cloudera.com/t5/Cloudera-Manager-Installation/Can-t-find-CM-5-4-2-for-Trusty-or-Precise/td-p/28685)


5. [Errno 2] No such file or directory: u'/opt/cloudera/parcels/CDH-5.4.7-1.cdh5.4.7.p0.3/meta/parcel.json' - master.lt.com
需要存在目录：/opt/cloudera/parcel-cache

6.	启用透明大页面问题
*	问题描述：已启用“透明大页面”，它可能会导致重大的性能问题。版本为“CentOS release 6.5 (Final)”且发行版为“2.6.32-431.el6.x86_64”的 Kernel 已将 enabled 设置为“[always] madvise never”，并将 defrag 设置为“[always] madvise never”。
*	问题解决：运行“echo never > /sys/kernel/mm/redhat_transparent_hugepage/defrag”以禁用此设置，然后将同一命令添加到一个 init 脚本中，如 /etc/rc.local，

7. 修改Cloudera Manager 管理机器的IP
[解决方案](http://www.cnblogs.com/chenfool/archive/2014/05/27/3756066.html)
