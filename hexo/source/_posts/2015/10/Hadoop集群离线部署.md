title: Hadoop集群离线部署
date: 2015-10-20 11:04:32
tags: [分布式,CDH,Hadoop] 
categories: [运维] 
---

GFW墙的没人性，只能费时费力搞个离线安装教程，一路遇到很多问题，稍微深入了解了一些ClouderaManager的内部实现，步骤概要：
IP配置>Host配置>关闭iptables防火墙>关闭SELinux>配置NTP时钟服务>SSH无密码登陆>安装JDK>
配置CM安装包>配置Parcel>配置MySQL>初始化SCM数据库>复制到Agent机器>
启动CM Server>配置Service>设置Server/Agent开机启动

- - -
<!-- more -->

# 部署文档参考
[离线安装Cloudera Manager5.3.4与CDH5.3.4](http://blog.csdn.net/scgaliguodong123_/article/details/46661881)
[离线安装Cloudera Manager 5和CDH5(最新版5.1.3) 完全教程](http://www.tuicool.com/articles/ENjmeaY)
[离线安装 Cloudera ( CDH 5.x )](http://www.cnblogs.com/modestmt/p/4540818.html)
[离线安装 Cloudera](http://www.aboutyun.com/thread-8921-1-1.html)
[官方教程](http://www.cloudera.com/content/cloudera/zh-CN/documentation/core/v5-3-x/topics/cm_ig_install_path_b.html#cmig_topic_6_6)
[cdh对应hadoop版本](http://www.cloudera.com/content/www/en-us/documentation/enterprise/latest/topics/cdh_vd_cdh5_maven_repo.html#concept_emz_fg3_kq_unique_2)

#	软件准备
[官方资源地址](http://www.cloudera.com/content/www/en-us/documentation/enterprise/latest/topics/cm_vd.html)

*	JDK7最低版本：1.7.0_67
*	cloudera-manager-installer：[下载地址](http://archive.cloudera.com/cm5/installer/latest/cloudera-manager-installer.bin)
*	cloudera-manager-bin:[下载地址](https://archive.cloudera.com/cm5/cm/5/)
*	CDH Parcel：[下载地址](http://archive.cloudera.com/cdh5/parcels/latest/)


# 虚拟机准备  

Cloudera Manager+MySQL

```
Cloudera Manager
HostMonitor
Event Server
Activity Monitor
Service Monitor
Alert Publisher 
MySQL
```

Master

```
HDFS：Active NameNode
Hbase：Active Master
YARN：Active ResourceManager,JobHistory Server 
```

Standby Master 

```
HDFS：Standby NameNode、DataNode
Hbase：Standby Master、RegionServer
YARN：Standby ResourceManager,Node Manager
HUE：Hue Server
```

Slave1

```
HDFS：DataNode、FailoverController、JournalNode
Hbase：RegionServer
YARN：Node Manager
Impala：Impala CatalogServer,Impala StateStore,Impala lama ApplicationMaster
Oozie：Oozie Server
Hive：Hive Server
Sor：Solr Server
ZoomKeeper：zoomKeeper Server
```

Slave2

```
HDFS：DataNode、FailoverController、JournalNode
Hbase：RegionServer
YARN：Node Manager
Impala：Impala Daemon
Hive：Hive Metastore Server
Sor：Solr Server
ZoomKeeper：zoomKeeper Server
```

Slave3

```
HDFS：DataNode、FailoverController、JournalNode
Hbase：RegionServer
YARN：Node Manager
Impala：Impala Daemon
Spark：Spark History Server
Hive：Hive Metastore Server
Sor：Solr Server
ZoomKeeper：zoomKeeper Server
```

Slave4

```
HDFS：DataNode
Hbase：RegionServer
YARN：Node Manager
Impala：Impala Daemon
```
 

# 安装JDK
将 JDK 提取至 /usr/java/jdk-version；例如：/usr/java/jdk1.7.0_80
将装有 JDK 的目录通过符号链接至 /usr/java/default；例如：
ln -s /usr/java/jdk.1.7.0_80 /usr/java/default 

# MySQL数据库配置 
## 安装配置MySQL

## 配置SCM数据库
```sql
--hive数据库
create database hive DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
--集群监控数据库
create database amon DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
--hue数据库
create database hue DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
--oozie数据库
create database oozie DEFAULT CHARSET utf8 COLLATE utf8_general_ci;

grant all privileges on *.* to 'root'@'%' identified by 'root' with grant option;

grant all privileges on *.* to 'root'@'master' identified by 'root' with grant option;
grant all privileges on *.* to 'root'@'192.168.1.100' identified by 'root' with grant option;
grant all privileges on *.* to 'root'@'192.168.1.183' identified by 'root' with grant option;
flush privileges;

```
 
# 安装cloudera-manager 
主节点解压安装 
cloudera manager的目录默认位置在/opt下，
解压：`cd /opt && tar xzvf cloudera-manager*.tar.gz`

# 添加cloudera-scm用户：
Agent节点执行：useradd --system --home=/opt/cm/run/cloudera-scm-server/ --no-create-home --shell=/bin/false --comment  "Cloudera SCM User" cloudera-scm

#	更改cloudera-scm用户目录
*	查看用户ID:id cloudera-scm
*	查看用户home：echo ~cloudera-scm
*	修改用户home：usermod -d /opt/cm/run/cloudera-scm-server/ -u ${用户ID} cloudera-scm  
如：usermod -d /opt/cm/run/cloudera-scm-server/ -u 493 cloudera-scm

#	安装 mysql connector： 
[外部MySQL数据库配置](http://www.cloudera.com/content/cloudera/zh-CN/documentation/core/v5-3-x/topics/cm_ig_mysql.html?scroll=cmig_topic_5_5)
[mysql-connector-java与mysql的版本对应关系](http://www.cnblogs.com/peijie-tech/articles/4446011.html)
*	下载[mysql-connector-java-5.1.36.tar.gz](http://ftp.ntu.edu.tw/MySQL/Downloads/Connector-J/)文件中提取 JDBC 驱动程序 JAR 文件。
*	解压：`tar zxvf mysql-connector-java-5.1.36.tar.gz`，
*	解压后找到mysql-connector-java-5.1.33-bin.jar，放到/opt/cm/share/cmf/lib/中。

#	初始化CM5的数据库：
在SCM主节点初始化SCM数据库
格式:scm_prepare_database.sh 数据库类型 数据库 服务器IP 用户名 密码 –scm-host Cloudera_Manager_Server机器IP scm scm scm 
如：`/opt/cm/share/cmf/schema/scm_prepare_database.sh  mysql -h 192.168.1.161 -uroot -proot --scm-host 192.168.1.100 scm scm scm`
重新执行的话，需要在mysql服务器执行  `drop database scm; `

#	Agent配置 
*	修改配置文件
`/opt/cm/etc/cloudera-scm-agent/config.ini`中的server_host为主节点的主机名。
*	务必解压后不能启动server和agent，纯净版本同步Agent到其他节点 
`scp -r /opt/cm root@192.168.1.91:/opt/`  

复制运行中的agent需执行以下脚本后复制

``` shell
service cloudera-scm-agent stop 
chkconfig cloudera-scm-agent off  
poweroff
```

* 修改hostname、hosts

# 准备Parcels，用以安装CDH5

将CHD5相关的Parcel包放到主节点的/opt/cloudera/parcel-repo/目录中（parcel-repo需要手动创建）。
相关的文件如下：
>CDH-5.4.7-1.cdh5.4.7.p0.3-el6.parcel
CDH-5.4.7-1.cdh5.4.7.p0.3-el6.parcel.sha1
manifest.json

将CDH-5.4.7-1.cdh5.4.7.p0.3-el6.parcel.sha1，重命名为CDH-5.4.7-1.cdh5.4.7.p0.3-el6.parcel.sha，这点必须注意，否则，系统会重新下载CDH-5.4.7-1.cdh5.4.7.p0.3-el6.parcel文件。

# 启动脚本
*	启动cloudera manager server服务：` /opt/cm/etc/init.d/cloudera-scm-server start `
*	启动cloudera manager agent服务：`/opt/cm/etc/init.d/cloudera-scm-agent start `

#	设置为 开机自动启动 
*	server端

```shell  
echo "/opt/cm/etc/init.d/cloudera-scm-server start" >> /etc/rc.local 
echo "/opt/cm/etc/init.d/cloudera-scm-agent start" >> /etc/rc.local
cat  /etc/rc.local
```

*	agent端

```shell  
#启动cloudera manager agent服务
echo "/opt/cm/etc/init.d/cloudera-scm-agent start" >> /etc/rc.local
cat  /etc/rc.local
```

*	chkconfig服务方式更优，但目前无效，待完善TODO

```shell 
#启动cloudera manager server服务 
cp /opt/cm/etc/init.d/cloudera-scm-server /etc/init.d/cloudera-scm-server
chkconfig cloudera-scm-server on

#启动cloudera manager agent服务
cp /opt/cm/etc/init.d/cloudera-scm-agent /etc/init.d/cloudera-scm-agent
chkconfig cloudera-scm-agent on
```


# CDH5的安装配置
进入cm网站：192.168.1.100:7180


