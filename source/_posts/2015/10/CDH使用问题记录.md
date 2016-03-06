title: CDH使用问题记录
date: 2015-10-27 09:46:55
tags: [分布式,CDH,Hadoop]
categories: [大数据]
---


# 如何制作CDH Agent 虚拟机模板
*	问题描述：CDH Manager安装配置好一台Agent机器A（VM虚拟机）后，如果以A复制出B，在集群中B与A会冲突，每次Host Inspector只能检测到一个
*	问题定位：判断为SCM库中HOSTS表的HOST_IDENTIFIER字段冲突导致
*	解决思路：ClouderaManager是根据什么自动生成HOST_IDENTIFIER的？ 如何复制VM虚拟机才能不冲突？
* 问题解决：由于在复制cm-5.4.7到agent之前启动了cloudera-scm-agent，在/opt/cm-5.4.7/lib/cloudera-scm-agent中生成response.avro和uuid两个文件，cloudera的HOST_IDENTIFIER读取的就是uuid文件的文本，停止agent>删除response.avro和uuid>启动agent，问题解决

# Cloudera Manager无法删除某项服务
删除依赖关系或在命令中查看正在执行的（卡死）的命令，中止即可

# Key-Value Store Indexer服务总是异常终止
* 问题描述：重新构建的Solr Collection和Index，数据写入少量没问题，程序批量写入时（>250条）服务就自动终止   
* 问题定位：Java OOM虚拟机内存溢出问题
* 解决方式：hbase-indexer github-issues：[Lily Hbase Indexers always auto exit](https://github.com/NGDATA/hbase-indexer/issues/66)，
通过向hbase-indexer官方github提交issue寻求帮助，确认是OOM问题！
    * 运行`hbase-indexer server`在单个hbase-server服务器调试运行（不在cloudera管理下运行），不会发生OOM
    * CM集中修改参数*Lily HBase Indexer的Java堆栈大小*，默认设置的是131M，改为1GB后重新启动服务，往Hbase写入数据时，SOlr索引生成正常，Hbase-Indexer未自动退出。

其他参考资料：[LocalMorphlineResultToSolrMapper源码](https://github.com/NGDATA/hbase-indexer/blob/master/hbase-indexer-morphlines/src/main/java/com/ngdata/hbaseindexer/morphline/LocalMorphlineResultToSolrMapper.java)

#	创建 Hive Metastore 数据库表失败
问题日志：

``` java
++ exec /opt/cloudera/parcels/CDH-5.4.7-1.cdh5.4.7.p0.3/lib/hadoop/bin/hadoop jar /opt/cloudera/parcels/CDH-5.4.7-1.cdh5.4.7.p0.3/lib/hive/lib/hive-cli-1.1.0-cdh5.4.7.jar org.apache.hive.beeline.HiveSchemaTool -verbose -dbType mysql -initSchema
org.apache.hadoop.hive.metastore.HiveMetaException: Failed to load driver
org.apache.hadoop.hive.metastore.HiveMetaException: Failed to load driver
	at org.apache.hive.beeline.HiveSchemaHelper.getConnectionToMetastore(HiveSchemaHelper.java:79)
	at org.apache.hive.beeline.HiveSchemaTool.getConnectionToMetastore(HiveSchemaTool.java:113)
	at org.apache.hive.beeline.HiveSchemaTool.testConnectionToMetastore(HiveSchemaTool.java:159)
	at org.apache.hive.beeline.HiveSchemaTool.doInit(HiveSchemaTool.java:257)
	at org.apache.hive.beeline.HiveSchemaTool.doInit(HiveSchemaTool.java:243)
	at org.apache.hive.beeline.HiveSchemaTool.main(HiveSchemaTool.java:473)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:57)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:606)
	at org.apache.hadoop.util.RunJar.run(RunJar.java:221)
	at org.apache.hadoop.util.RunJar.main(RunJar.java:136)
Caused by: java.lang.ClassNotFoundException: com.mysql.jdbc.Driver
	at java.net.URLClassLoader$1.run(URLClassLoader.java:366)
	at java.net.URLClassLoader$1.run(URLClassLoader.java:355)
	at java.security.AccessController.doPrivileged(Native Method)
	at java.net.URLClassLoader.findClass(URLClassLoader.java:354)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:425)
	at sun.misc.Launcher$AppClassLoader.loadClass(Launcher.java:308)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:358)
	at java.lang.Class.forName0(Native Method)
	at java.lang.Class.forName(Class.java:195)
	at org.apache.hive.beeline.HiveSchemaHelper.getConnectionToMetastore(HiveSchemaHelper.java:70)
	... 11 more
	*** schemaTool failed ***
```

# CDH5使用端口
[ CDH 5 组件使用的端口](http://www.cloudera.com/content/cloudera/zh-CN/documentation/core/v5-3-x/topics/cdh_ig_ports_cdh5.html)


# Hbase运行中止问题

*	错误日志

```java
//cat /var/log/hbase/hbase-cmf-hbase-REGIONSERVER-slave3.lt.com.log.out

Error syncing, request close of wal
java.io.IOException: Failed on local exception: java.io.IOException: Connection reset by peer; Host Details : local host is: "slave3.lt.com/192.168.1.103"; destination host is: "server1.lt.com":8020;  
	at com.sun.proxy.$Proxy20.updateBlockForPipeline(Unknown Source)
Caused by: java.io.IOException: Connection reset by peer
```

``` yaml
Unable to reconnect to ZooKeeper service, session 0x1508e4d86eb8047 has expired, closing socket connection
```

``` yaml
Client session timed out, have not heard from server in 40003ms for sessionid 0x1508e4d86eb88ef, closing socket connection and attempting reconnect

Unable to reconnect to ZooKeeper service, session 0x1508e4d86eb88f5 has expired, closing socket connection
```

``` yaml
Opening socket connection to server server1.lt.com/192.168.1.91:2181. Will not attempt to authenticate using SASL (unknown error)
```

*	参数说明
hbase参数

``` yaml
hbase.regionserver.lease.period
默认值：60000
说明：客户端租用HRegion server 期限，即超时阀值。
调优：这个配合hbase.client.scanner.caching使用，如果内存够大，但是取出较多数据后计算过程较长，可能超过这个阈值，适当可设置较长的响应时间以防被认为宕机
```

zookeeper参数
``` yaml
zookeeper.session.timeout
默认值：60000
说明：ZooKeeper 服务器允许客户端协商的最大会话超时时间（以毫秒为单位）
调优：zookeeper的超时时间不要设置太大，在服务挂掉的情况下，会反映很慢。
```

*	解决方式
在CM的Hbase配置hbase.regionserver.lease.period默认值改为4（分钟）
在CM的Hbase配置hbase.rpc.timeout默认值改为5（分钟）

# Hbase数据操作失败
问题描述：connection to slave3.lt.com/192.168.1.103:60020 from geosmart: closing ipc connection to slave3.lt.com/192.168.1.103:60020: Connection refused: no further information
java.net.ConnectException: Connection refused: no further information

# Hive UDTF问题
问题日志：Error while compliling statement:Failed IndexOutOfBoundException Index.1 Size.1
解决方案：
init初始化中的ArrayList<ObjectInspector> 和fieldNames个数和类型要对应一致

# Hive UDTF code 2问题
问题日志：Error while processing statement: FAILED: Execution Error, return code 2 from org.apache.hadoop.hive.ql.exec.mr.MapRedTask
解决方案：/var/log/hive中查看错误日志定位错误

#  HUE新建HDFS目录
问题描述: you are a Hue admin but not a HDFS superuser, "hdfs" or part of HDFS supergroup, "supergroup"
解决方案：在hue中新增hdfs用户，以hdfs用户登录创建目录和上传文件

# Hive Metastore canary 创建数据库失败
问题描述： Hive Metastore canary 创建数据库失败
日志：

``` yaml
Caused by: org.datanucleus.exceptions.NucleusException: Attempt to invoke the "BONECP" plugin to create a ConnectionPool gave an error :
The specified datastore driver ("com.mysql.jdbc.Driver") was not found in the CLASSPATH. Please check your CLASSPATH specification, and the name of the driver
```
问题定位：读取hive数据时报找不到mysql驱动
问题解决：
	*	尝试1
`/opt/cloudera/parcels/CDH-5.4.7-1.cdh5.4.7.p0.3/lib/hive/lib`
`cp  /opt/cloudera/parcels/CDH-5.4.7-1.cdh5.4.7.p0.3/lib/sqoop/lib/mysql-connector-java-5.1.36-bin.jar   /opt/cloudera/parcels/CDH-5.4.7-1.cdh5.4.7.p0.3/lib/hive/lib`
	*  尝试2
在`/etc/hive/conf.cloudera.hive/hive-env.sh`中发现一句`$(find /usr/share/java/mysql-connector-java.jar`
于是将驱动拷贝到指定目录解决问题
`cp  /mnt/mysql-connector-java-5.1.36-bin.jar     /usr/share/java/mysql-connector-java.jar `
`cp  /mnt/mysql-connector-java-5.1.36-bin.jar    /opt/cloudera/parcels/CDH-5.4.7-1.cdh5.4.7.p0.3/lib/hadoop`
解决问题

2）hive数据库初始化问题
问题日志：

``` yaml
Query for candidates of org.apache.hadoop.hive.metastore.model.MVersionTable and subclasses resulted in no possible candidates
Required table missing : "`VERSION`" in Catalog "" Schema "". DataNucleus requires this table to perform its persistence operations. Either your MetaData is incorrect, or you need to enable "datanucleus.autoCreateTables"
org.datanucleus.store.rdbms.exceptions.MissingTableException: Required table missing : "`VERSION`" in Catalog "" Schema "". DataNucleus requires this table to perform its persistence operations. Either your MetaData is incorrect, or you need to enable "datanucleus.autoCreateTables"
    at org.datanucleus.store.rdbms.table.AbstractTable.exists(AbstractTable.java:485)
```

[解决参考:Reinstalling-Hive-Metastore-Database](http://community.cloudera.com/t5/Batch-SQL-Apache-Hive/Reinstalling-Hive-Metastore-Database/td-p/24015)

## 在cm中删除oozie、hue和hive服务，重建数据库
``` sql
# mysql -uroot -proot
drop database hive;
drop database hue;
drop database oozie;
create database hive DEFAULT CHARSET utf8 COLLATE utf8_general_ci;  
create database hue DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
create database oozie DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
```
## 重新添加hive服务
配置数据库192.168.1.1(server)/hive(db)/root(user)/root(psd)
