title: mongodb手动安装脚本
date: 2015-06-28 20:26
tags: [CentOS,MongoDB]
categories: [数据库]
---

![nosql](nosql.png)   

# 准备事项

## 下载安装包文件（二进制编译版）
``` bash
mkdir -p /usr/local/mongodb
cd /usr/local/mongodb
wget http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.6.3.tgz
tar -zvxf mongodb-linux-x86_64-2.6.3.tgz
```
## 重命名>新建数据/日志目录
``` bash
mv mongodb-linux-x86_64-2.6.3 mongodb
mkdir data
mkdir log
```
# 配置环境变量
CentOs中配置path环境变量,确保mongodb的bin目录包含在path环境变量中。
## 配置PATH
``` bash
vim /etc/profile
　　#set for mongodb
　　export MONGODB_HOME=/usr/local/mongodb
　　export PATH=$MONGODB_HOME/bin:$PATH
```
## 查看当前PATH
``` bash
echo $PATH
```
## 让环境变量生效
``` bash
source /etc/profile
//验证环境变量是否生效
mongod -version
echo $PATH
```  

## 添加CentOS开机启动项
```
vim  /etc/rc.d/rc.local
//将mongodb启动命令手动追加到本文件中：
/usr/local/mongodb/bin/mongod --dbpath /usr/local/mongodb/data --logpath /usr/local/mongodb/log/mongodb.log --maxConns=2000  --fork --smallfiles
```

# 启动MongoDB
## 配置文件形式
``` bash
vim  /usr/local/mongodb/mongodb.conf
dbpath=/usr/local/mongodb/data
logpath=/usr/local/mongodb/log/mongodb.log
logappend=true
port=27017
fork=true
noauth=true
journal=true
smallfiles=true
```  

## 命令行形式
``` Bash
/usr/local/mongodb/bin/mongod --dbpath /usr/local/mongodb/data --logpath /usr/local/mongodb/log/mongodb.log  --fork --smallfiles
//可选：--auth
```

# 增加用户
``` Bash
useradd mongodb -M -s /sbin/nologin
```

#  启动服务/测试服务状态
``` bash
service mongod start
service mongod status
shutdown -r now
service mongod status
mongo admin
show dbs；
db.test.find();
exit
```
# 部署问题记录
## MongoVUE不能连接
将27017端口加入信任列表；局域网测试直接关闭防火墙
``` bash
//关闭防火墙
service iptables stop
//开启
chkconfig iptables on
//关闭
chkconfig iptables off
//查询TCP连接情况
 netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
//查询端口占用情况：
 netstat   -anp   |   grep  portno
//（例如：netstat –apn | grep 80）
```
