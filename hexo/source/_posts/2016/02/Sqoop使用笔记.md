title: Sqoop使用笔记
date: 2016-02-24 09:43:28
tags: [Hadoop,Sqoop,Hive]
categories: [存储层]
---

Sqoop是Apache顶级项目，主要用来在Hadoop和关系数据库中传递数据。通过sqoop，可以方便的将数据从关系数据库导入到HDFS，或将数据从HDFS导出到关系数据库。
- - -
<!-- more -->

# 关于Sqoop
[官网](http://sqoop.apache.org/)
Sqoop架构整合了Hive、Hbase和Oozie，通过map-reduce任务来传输数据，从而提供并发特性和容错。  
Sqoop主要通过JDBC和关系数据库进行交互。理论上支持JDBC的database都可以使用sqoop和hdfs进行数据交互。但只有一小部分经过sqoop官方测试，如：HSQLDB（1.8.0+），MySQL（5.0+），Oracle（10.2.0+），PostgreSQL（8.3+ ）；
MySQL和PostgreSQL支持direct；较老的版本有可能也被支持，但未经过测试。出于性能考虑，sqoop提供不同于JDBC的快速存取数据的机制，可以通过--direct使用。

# Sqoop与MySQL数据交换
版本：sqoop-1.4.5-cdh5.4.0
[sqoop-1.4.5-cdh5.4.0官方文档](http://archive.cloudera.com/cdh5/cdh/5/sqoop-1.4.5-cdh5.4.0/SqoopUserGuide.html)
[数据导入示例](http://archive.cloudera.com/cdh5/cdh/5/sqoop-1.4.5-cdh5.4.0/SqoopUserGuide.html#_example_invocations)

## mysql drive导入sqoop
cp  /tmp/mysql-connector-java-5.1.36-bin.jar  /opt/cloudera/parcels/CDH-5.4.7-1.cdh5.4.7.p0.3/lib/sqoop/lib
cp  /opt/cloudera/parcels/CDH-5.4.7-1.cdh5.4.7.p0.3/lib/sqoop/lib/mysql-connector-java-5.1.36-bin.jar   /opt/cloudera/parcels/CDH-5.4.7-1.cdh5.4.7.p0.3/lib/hadoop/lib/
备注：官方文档是要导入到sqoop2目录，但copy到sqoop2目录无效，sqoop目录生效

## MySQL表导入HDFS然后导入Hive
* 切换到hdfs用户执行：`su hdfs`
* 将MySQL数据库geocodingdb的MatchingAddress表导入HDFS用户目录
``` shell
sqoop import --connect jdbc:mysql://192.168.1.161:3306/geocodingdb   \
--driver com.mysql.jdbc.Driver   \
--username geocodingdb --password geocodingdb  \
--table MatchingAddress       \
--fields-terminated-by '\t'  --lines-terminated-by '\n' --optionally-enclosed-by '\"'
--direct
```
* 附加`--direct`参数快速完成MySQL数据导入/导出操作
与selects和inserts操作相比，MySQL Direct Connector可以用mysqldump and mysqlimport工具对MySQL数据进行更快的导入和导出操作

* hive新建表结构并导入数据
```sql
DROP TABLE IF EXISTS geocodingdb.MatchingAddress;

create external table geocodingdb.MatchingAddress (source_address_id string,source_address string ,head_splitted_address string,splitted_skeleton_addressnode string,skeleton_addressnode string,skeleton_addressnode_type string,tail_address string,tail_splitted_address string)
row format delimited  fields terminated by '\t'  stored as textfile;

load data inpath '/user/hdfs/MatchingAddress/*'  into table geocodingdb.MatchingAddress;
```

## MySQL表直接导入Hive
* MySQL表授权
```sql
GRANT ALL PRIVILEGES ON *.* TO 'geocodingdb'@'%' IDENTIFIED BY 'geocodingdb' with grant option;
FLUSH PRIVILEGES;
```

* hive-import命令
注意导入MySQL表结构字段顺序需与Hive表结构字段顺序一致
```yaml
sqoop import --connect jdbc:mysql://192.168.1.161:3306/geocodingdb   \
--driver com.mysql.jdbc.Driver   \
--username geocodingdb --password geocodingdb  \
--table MatchingAddress       \
--fields-terminated-by '\t'  --lines-terminated-by '\n' --optionally-enclosed-by '\"'     \
--direct
```

# Hive表导出到MySQL
```yaml
sqoop export --direct --connect jdbc:mysql://192.168.1.161:3306/geocodingdb --driver com.mysql.jdbc.Driver   \
--username geocodingdb --password geocodingdb  \
--table MatchedAddressGroupbySkeleton \
--export-dir /user/hive/warehouse/geocodingdb.db/matchedaddressgroupbyskeleton  \
--input-fields-terminated-by "\t"   \
--input-null-string "\\\\N" --input-null-non-string "\\\\N"  
```

# Sqoop(MySQL)常用命令

## 指定列
sqoop import --connect jdbc:mysql://db.foo.com/corp --table EMPLOYEES \
--columns "employee_id,first_name,last_name,job_title"

## 使用8个线程
sqoop import --connect jdbc:mysql://db.foo.com/corp --table EMPLOYEES \
-m 8

## 快速模式
sqoop import --connect jdbc:mysql://db.foo.com/corp --table EMPLOYEES \
--direct

## 使用sequencefile作为存储方式
sqoop import --connect jdbc:mysql://db.foo.com/corp --table EMPLOYEES \
--class-name com.foocorp.Employee --as-sequencefile

## 分隔符
sqoop import --connect jdbc:mysql://db.foo.com/corp --table EMPLOYEES \
--fields-terminated-by '\t' --lines-terminated-by '\n' \
--optionally-enclosed-by '\"'

## 导入到hive
sqoop import --connect jdbc:mysql://db.foo.com/corp --table EMPLOYEES \
--hive-import

## 条件过滤
sqoop import --connect jdbc:mysql://db.foo.com/corp --table EMPLOYEES \
--where "start_date > '2010-01-01'"

## 用dept_id作为分个字段
sqoop import --connect jdbc:mysql://db.foo.com/corp --table EMPLOYEES \
--split-by dept_id

## 追加导入
sqoop import --connect jdbc:mysql://db.foo.com/somedb --table sometable \
--where "id > 100000" --target-dir /incremental_dataset --append

# 问题记录
## sqoop export --direct导出mysqlimport错误
错误描述：Cannot run program "mysqlimport": error=2, No such file or directory
解决办法：附加`--driver com.mysql.jdbc.Driver`参数

## sqoop export --direct导出mapreduce程序错误
错误描述1：Caused by: java.lang.RuntimeException: Can't parse input data: '长浜	STR	18119	B316D057CE523018E0430A23A2C13018'
解决办法：附加`--input-fields-terminated-by "\t" `参数

错误描述2：com.mysql.jdbc.exceptions.jdbc4.MySQLIntegrityConstraintViolationException: Duplicate entry '1614' for key 'PRIMARY'
解决办法：附加`--input-null-string "\\\\N" --input-null-non-string "\\\\N"  `如果遇到空值就插入null

## Sqoop 导入 Hive 导致发生 Null Pointer Exception (NPE)
解决办法：首先通过 Sqoop 将数据导入 HDFS，然后将其从 HDFS 导入 Hive。

## MySQL导入Hive表报错
Caused by: com.mysql.jdbc.exceptions.jdbc4.MySQLSyntaxErrorException: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '쀀' )' at line 1
解决：hive表编码问题；导入时不附加--hcatalog-table，手动新建表，然后导入数据

# Sqoop导入MySQL大表内存溢出问题
[SqoopUserGuide](https://sqoop.apache.org/docs/1.4.5/SqoopUserGuide.html)
抛出异常java.lang.OutOfMemoryError：GC overhead limit exceeded导致服务起不来

参考：http://www.hadooptechs.com/sqoop/handling-database-fetch-size-in-sqoop


修改yarn的nodemanager xmx还是sqoop 的xmx
# 分页查询写入
``` bash
sqoop import --connect jdbc:mysql://192.168.1.161:3306/geocodingdb  --username geocodingdb --password geocodingdb  \
--query 'select * from  MatchingAddress  WHERE $CONDITIONS  limit 0,100000'  \
--split-by  guid  \
--fields-terminated-by '\t'  --lines-terminated-by '\n' --optionally-enclosed-by '\"'  \
--target-dir /user/hive/warehouse/geocodingdb.db/matchingaddress  \
--append
```

```bash
sqoop import --connect jdbc:mysql://192.168.1.161:3306/geocodingdb  --username geocodingdb --password geocodingdb  \
--query 'select * from  MatchingAddress  WHERE $CONDITIONS'  \
--split-by  guid  \
--fields-terminated-by '\t'  --lines-terminated-by '\n' --optionally-enclosed-by '\"'  \
--target-dir /user/hive/warehouse/geocodingdb.db/matchingaddress  \
--append
```


sqoop import --connect jdbc:mysql://192.168.1.161:3306/geocodingdb?user=geocodingdb&password=geocodingdb&dontTrackOpenResources=true&defaultFetchSize=10000&useCursorFetch=true  --query 'select * from MatchingAddress  WHERE $CONDITIONS' --split-by  guid \
--fields-terminated-by '\t'  --lines-terminated-by '\n' --optionally-enclosed-by '\"'  \
--target-dir /user/hive/warehouse/geocodingdb.db/matchingaddress  \
--append


sqoop import --connect jdbc:mysql://192.168.1.161:3306/geocodingdb  \
--driver com.mysql.jdbc.Driver  \
--username geocodingdb --password geocodingdb  \
--direct  \
--table MatchingAddress1  \
--fields-terminated-by '\t'  --lines-terminated-by '\n' --optionally-enclosed-by '\"'  \
--target-dir /user/hive/warehouse/geocodingdb.db/matchingaddress  \
--append



sqoop import --connect jdbc:mysql://192.168.1.161:3306/geocodingdb  \
--driver com.mysql.jdbc.Driver  \
--username geocodingdb --password geocodingdb  \
--direct  \
--table MatchingAddress2  \
--fields-terminated-by '\t'  --lines-terminated-by '\n' --optionally-enclosed-by '\"'  \
--target-dir /user/hive/warehouse/geocodingdb.db/matchingaddress  \
--append

sqoop import --connect jdbc:mysql://192.168.1.161:3306/geocodingdb  \
--driver com.mysql.jdbc.Driver  \
--username geocodingdb --password geocodingdb  \
--direct  \
--table MatchingAddress3  \
--fields-terminated-by '\t'  --lines-terminated-by '\n' --optionally-enclosed-by '\"'  \
--target-dir /user/hive/warehouse/geocodingdb.db/matchingaddress  \
--append

sqoop import --connect jdbc:mysql://192.168.1.161:3306/geocodingdb  \
--driver com.mysql.jdbc.Driver  \
--username geocodingdb --password geocodingdb  \
--direct  \
--table MatchingAddress4  \
--fields-terminated-by '\t'  --lines-terminated-by '\n' --optionally-enclosed-by '\"'  \
--target-dir /user/hive/warehouse/geocodingdb.db/matchingaddress  \
--append

sqoop import --connect jdbc:mysql://192.168.1.161:3306/geocodingdb  \
--driver com.mysql.jdbc.Driver  \
--username geocodingdb --password geocodingdb  \
--direct  \
--table MatchingAddress5  \
--fields-terminated-by '\t'  --lines-terminated-by '\n' --optionally-enclosed-by '\"'  \
--target-dir /user/hive/warehouse/geocodingdb.db/matchingaddress  \
--append





Stack trace: ExitCodeException exitCode=255:
