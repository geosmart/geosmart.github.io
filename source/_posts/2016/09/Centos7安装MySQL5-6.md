---
title: Centos7安装MySQL5.6
date: 2016-09-10 12:54:01  
tags: MySQL
notebook: N02 数据库
categories: 后端技术
---

Centos7系统，以rpm方式安装MySQL5.6

- - -
<!-- more -->

[参考教程](http://blog.csdn.net/liumm0000/article/details/18841197/)

# 卸载MySQL
rpm -qa | grep MySQL
rpm -e --nodeps mysql MySQL-server-5
rpm -e --allmatches MySQL-client-5.6.33-1.el7.x86_64 
rpm -e --allmatches MySQL-devel-5.6.33-1.el7.x86_64 
rpm -e --allmatches MySQL-server-5.6.33-1.el7.x86_64 
chkconfig --del mysql
rm -rf /user/local/mysql
rm -rf /etc/my.cnf
rm -rf /var/lib/mysql
 

# 准备mysql安装文件
下载 mysql包：`wget http://cdn.mysql.com//Downloads/MySQL-5.6/mysql-5.6.33-winx64.zip`
解压缩：`tar -xvf mysql-5.6.33-winx64.zip`

# 安装MySQL
```bash
su mysql
rpm -ivh MySQL-server-5.6.33-1.el7.x86_64.rpm
rpm -ivh MySQL-devel-5.6.33-1.el7.x86_64.rpm
rpm -ivh MySQL-client-5.6.33-1.el7.x86_64.rpm
```

# 修改配置文件位置
`cp /usr/share/mysql/my-default.cnf /etc/my.cnf`

# 初始化MySQL及设置密码
安装server会自动执行数据库初始化（perl）：/usr/bin/mysql_install_db
启动服务：service mysql start
查看默认密码：`cat /root/.mysql_secret` 
修改root密码：
```bash
mysql -uroot -pFiXBgAhVDgythr6B
SET PASSWORD = PASSWORD('root');   
exit 
```

# 允许远程登陆
```sql
mysql -uroot -proot
use mysql;
update user set host='%' where user='root' and host='localhost';
flush privileges;
exit
```

# 设置开机自启动
```bash
chkconfig mysql on
chkconfig --list | grep mysql
```

# 配置/etc/my.cnf
``` bash
#  whereis my.ini
[server]
bind-address           = 0.0.0.0
character-set-server   = utf8
collation-server       = utf8_unicode_ci
init_connect           = 'SET NAMES utf8'
max_connections = 5000
max_allowed_packet = 20M
max_connect_errors= 1000
lower_case_table_names=2

[mysqld]
data=/usr/local/mysql/data
socket=/var/lib/mysql/mysql.sock 

innodb_file_per_table = 1
innodb_flush_method=O_DIRECT
innodb_log_file_size=1G
innodb_buffer_pool_size=4G

[mysqld_safe]
log-error=/var/log/mysqld.log
long_query_time =1
log-slow-queries=slowqueris.log
log-queries-not-using-indexes = nouseindex.log
log=mylog.log
```

# mysql数据目录设置权限
```bash
su root
chown -R root:root /usr/local/mysql/data
chown -R root:root /var/lib/mysql
```