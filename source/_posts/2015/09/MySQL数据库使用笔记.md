title: MySQL数据库使用笔记
date: 2015-09-21 11:57:27
tags: [MySQL]
categories: [数据库]
---

记录一些常用的MysQL运维脚本和常见问题

- - -
<!-- more -->
[MySQL函数文档](http://dev.mysql.com/doc/refman/5.7/en/string-functions.html)

# linux重置mysql root密码
```sql
# 新建文件
touch /mnt/script/mysql-init
# 文件内容为
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('MyNewPass');
# 查看mysqld进程ID并杀掉
service mysqld status
kill ${pid}
# 重启mysql服务并重置root密码
mysqld_safe --init-file=/mnt/script/mysql-init &
```

# 重启mysql服务
service mysqld restart

# MySQL开启远程连接
问题：Access denied for user 'root'@'192.168.1.172' (using password: YES)
解决：

``` sql
mysql -uroot -proot
show grants;
use mysql
select host,user,password from user;
update user set host='%' where user="root" and host;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

# mysql 新建用户，设置权限   
DROP USER 'ugc'@'%';
CREATE USER 'ugc'@'%' IDENTIFIED BY 'ugc';  
GRANT ALL PRIVILEGES ON * . * TO 'ugc'@'%'  Identified by 'ugc';
GRANT ALL PRIVILEGES ON * . * TO 'ugc'@'localhost'  Identified by 'ugc';
FLUSH PRIVILEGES;

# 登陆
mysql -uugc -pugc

# 建库
CREATE DATABASE  ugc;

# 数据导入
单个导入：`source  data.sql`
如：`cd /tmp/ugc-data/ && find . -name 'echzutravel.sql' | awk '{ print "source",$0 }' | mysql --batch -u ugc -p ugc`

批量导入：`find . -name '*.sql' | awk '{ print "source",$0 }' | mysql --batch -u root -p db_name`
如导入/tmp/ugc-data/目录的所有sql文件到ugc库：`cd /tmp/ugc-data/ && find . -name '*.sql' | awk '{ print "source",$0 }' | mysql --batch -u ugc -p ugc`

# 数据导出
1. 导出整个数据库
mysqldump -u 用户名 -p 数据库名 > 导出的文件名
mysqldump -u wcnc -p smgp_apps_wcnc > wcnc.sql
2. 导出一个表
mysqldump -u 用户名 -p 数据库名表名> 导出的文件名
mysqldump -u wcnc -p smgp_apps_wcnc users> wcnc_users.sql
3. 导出一个数据库结构
mysqldump -u wcnc -p -d --add-drop-table smgp_apps_wcnc >d:wcnc_db.sql
-d 没有数据 --add-drop-table 在每个create语句之前增加一个drop table

# 问题记录
## Too many connections
查看最大连接数：show variables like 'max_connections';
查询一下服务器响应的最大连接数： show global status like 'Max_used_connections';
show status like '%connection%';
显示当前运行的Query： show processlist;
设置新的最大连接数为5000：
1）shell临时修改： set GLOBAL max_connections=5000;
2）在/etc/my.cnf 中修改连接max_connections = 5000

# Packet for query is too large
* 关于max_allowed_packet参数
MySQL根据配置文件会限制Server接受的数据包大小。有时候大的插入和更新会受 max_allowed_packet 参数限制，导致写入或者更新失败。
* 查询：show VARIABLES like '%max_allowed_packet%';
* 命令行中修改：set global max_allowed_packet = 2*1024*1024*10;
* 在windows（my.ini），Linux（/etc/my.cnf）中 修改：max_allowed_packet = 20M

# Host is blocked because of many connection errors
* 错误描述：An error occurred while establishing the connection: message from server: "Host '192.168.1.174' is blocked because of many connection errors; unblock with 'mysqladmin flush-hosts'"
* 查询：show VARIABLES like '%max_connect_errors%';
* 命令行中修改：set global max_connect_errors =1000;
* 在windows（my.ini），Linux（/etc/my.cnf）中 修改：max_connect_errors= 1000

#  No buffer space available (maximum connections reached?)
* 错误描述：大量数据库连接运行sql，抛出异常java.net.SocketException: No buffer space available (maximum connections reached?): JVM_Bind,在运行 Windows Server 2008 R2 或 Windows 7 的多处理器计算机上的内核套接字泄漏
* 解决：winServer2008多处理器计算机上的内核套接字泄漏bug，下载补丁修复
The reason we got this error is a bug in Windows Server 2008 R2 / Windows 7. The kernel leaks loopback sockets due to a race condition on machines with more than one core,
[patch 2577795](http://support.microsoft.com/kb/2577795) fixes the issue:

## You can't specify target table 'Place' for update in FROM clause
执行错误：DELETE   FROM  Place where guid in (select guid  from  Place  where address like '%市%区' and address   not  like '%南海区%') ;
修改为：DELETE   FROM  Place whereguid in (select  * from (select guid  from  Place  where address like '%市%区' and address   not  like '%南海区%')  as t);

## mysql表名区分大小写
MySQL在Windows下数据库名、表名、列名、别名都不区分大小写。
如果想大小写区分，在my.ini 里面的mysqld部分，加入 lower_case_table_names=0

## 查询表的字段名称
select column_name from information_schema.columns where table_name = 'ExtractedAddress' and column_name like '地名%' and  column_name <> '地名'
