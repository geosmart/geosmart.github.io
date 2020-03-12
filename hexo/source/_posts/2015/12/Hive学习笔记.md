---
title: Hive学习笔记
date: 2015-12-06 21:03:50
tags: [分布式,Hadoop,Hive]
categories: [大数据]
---


最近处理一个ETL的项目，技术选型是CDH的Hadoop方案，理所当然离不了Hive数据仓库，记录下Hive学习路上的点滴。
<!-- more -->

# Hive简介
Apache Hive是一个建立在Hadoop架构之上的数据仓库。它能够提供数据的精炼，查询和分析。
Hive是建立在 Hadoop 上的数据仓库基础构架。它提供了一系列的工具，可以用来进行数据提取转化加载（ETL）。
Hive定义了简单的类 SQL 查询语言，称为 HQL，它允许熟悉 SQL 的用户查询数据。同时，这个语言也允许熟悉 MapReduce 开发者的开发自定义的 mapper 和 reducer 来处理内建的 mapper 和 reducer 无法完成的复杂的分析工作。

# Hive Maven库
[Hive1.1.0离线包](http://maven.outofmemory.cn/org.apache.hive/hive-exec/1.1.0/)

# 参考资料
[Hive 官方Wiki](https://cwiki.apache.org/confluence/display/Hive/Home)

# hive Maven库
有时候中央库的没法下载，但是spring.io提供的CDH的可以。
``` xml
<!-- cdh  repository-->
<repository>
    <id>cdh-5.3.0</id>
    <url>http://repo.spring.io/libs-release-remote/</url>
</repository>

<!-- hive jdbc -->
<dependency>
    <groupId>org.apache.hive</groupId>
    <artifactId>hive-jdbc</artifactId>
    <version>${hive.version}</version>
</dependency>
```
# Hive With Hbase

# Hive存储Hbase数据 测试语句
## 参考资料
[hbase-via-hive1](http://zh.hortonworks.com/blog/hbase-via-hive-part-1/)
[hbase-via-hive2](http://www.n10k.com/blog/hbase-via-hive-pt2/)
## 示例SQL
```sql
CREATE TABLE  User (userId STRING, address STRING,name STRING ,photo STRING ,psd STRING)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,f:data')
TBLPROPERTIES ('hbase.table.name' = 'User');
```

# hive 新建表
```sql
CREATE EXTERNAL TABLE Geocoding_Address (
SID String,SAddress String
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;
--PARTITIONED BY(STR STRING)
```

## hive新增partion
alter table alter2 add partition (insertdate='2008-01-01') location '2008/01/01';

# Hive数据导入
## 导入hdfs数据到hive表
`load data inpath '/user/uadb/test.txt' into table test ;`

## 导入本地文件到hive表
`load data local inpath '/home/uadb/test.txt' into table test ;`

# Hive自定义函数
* UDF:一进一出（ 输入一行输出一行 On-to-one maping ）
>transformation of one row value into another one, which can be added with UDFs (User Defined Function);

* UDAF:多进一出（ 输入多行输出一行 Many-to-one maping ）
>transformation of multiple row values into one, which can be added with UDAFs (User Defined Aggregate Functions);

* UDTF:一进多出（ 输入一行输出多行 On-to-many maping ）
>transformation of one row value into many, which can be added with UDTFs (User Defined Table Functions).

## 查看UDF依赖的jar包
查看自定义函数依赖的jar包：`list jars`;

## hue导入/删除jar
```sql
add  jar /user/hive/test/test.jar;
delete jar /user/hive/test/test.jar;
```
## 新建临时UDF函数
```sql
create temporary function  testUDF  as "com.lt.uadb.match.udf.SkeletonAddressNodeMapUDF";
select a.skeleton_addressnode,testUDF(a.skeleton_addressnode,'一')   from matchingAddress as a
```

## Hive  UUID
select reflect("java.util.UUID", "randomUUID") from table

## UDF程序打包
UDF程序打包有两张方式：
1. 以类fatjar工具将UDF和依赖打成一个jar包，但是打包部署耗时；
2. 将jar包分为稳定和经常更新的两类；通过执行add和delete动态添加依赖

## CM中设置Hive自动加载UDTF依赖JAR
[参考cloudera mamager中配置hive加载自定义的jar包](http://blog.csdn.net/xiao_jun_0820/article/details/38302451)
1. 进入Hive配置页
2. 在高级选型中设置`Hive 辅助 JAR 目录`：`/etc/hive/udtflib`
3. 设置Gateway Default Group（hive-env.sh 的 Gateway 客户端环境高级配置代码段（安全阀））：`HIVE_AUX_JARS_PATH=/etc/hive/udtflib`
4. 重启集群，CM会自动将Hive辅助JAR目录中的jar包分发到Hive客户端

## UDF日志查看
除了开发环境的Junit单元测试外，生产环境的日志查看非常重要，
1. 通过在hue -jobbrowser中查看syslog；
2. 通过在YARN的ResourceManager UI中查看Mapreduce打印的详细日志，日志会打印syso的内容；

# Hive JDBC
HiveServer和HiveServer2都有两种模式，分别为嵌入式和单机服务器模式，
 1. 嵌入式URI为"jdbc:hive://"或者"jdbc:hive2://"；
 2. 单机服务器模式的URI为"jdbc:hive://host:port/dbname"或者"jdbc:hive2://host:port/dbname"；
 3. HiveServer使用的JDBC驱动类为org.apache.hadoop.hive.jdbc.HiveDriver，HiveServer2使用的驱动类为org.apache.hive.jdbc.HiveDriver；

# 问题记录
## /tmp/hive on HDFS should be writable
问题日志：Exception in thread "main" java.lang.RuntimeException: java.lang.RuntimeException: The root scratch dir: /tmp/hive on HDFS should be writable. Current permissions are: rwx-wx--x
解决方法：
1. 更新权限hdfs目录权限：`hadoop fs -chmod 777 /tmp/hive`
2. hdfs执行：`hadoop fs -rm -r /tmp/hive;  `
3. local执行：`rm -rf /tmp/hive`

## hive query can't generate result set via jdbc
解决：Use stmt.execute() for a query that makes a new table. of executeQuery. The executeQuery() is now only for select queries (DML) while execute is probably for DDL (data definition).
* DDL（Data Definition Language 数据定义语言）用于操作对象和对象的属性，这种对象包括数据库本身，以及数据库对象，像：表、视图等等，DDL对这些对象和属性的管理和定义具体表现在Create、Drop和Alter上；  
* DML（Data Manipulation Language 数据操控语言）用于操作数据库对象中包含的数据，也就是说操作的单位是记录；  

## Hive Jdbc调用UDTF问题
* 问题描述：在Java中以Hive的JDBC接口调用UDTF语句，逐行执行到create temporary function就会报错，但在Hue中（客户端连接）能正常执行
* 问题日志
```java
org.apache.hive.service.cli.HiveSQLException: Error while processing statement: FAILED: Execution Error, return code 1 from org.apache.hadoop.hive.ql.exec.FunctionTask
    at org.apache.hive.service.cli.operation.Operation.toSQLException(Operation.java:315)
```
* 解决方案：
