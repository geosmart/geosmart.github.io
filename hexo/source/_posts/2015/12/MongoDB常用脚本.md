title: MongoDB常用脚本
date: 2015-12-28 20:47:12
tags: [MongoDB]
categories: [数据库]
---

记录一些工作过程中常用的MongoDB脚本。
- - -
<!-- more -->

# 数据库连接与关闭
## 数据库连接
mongo uadb
## 切换数据库
use uadb
## 强制关闭mongodb进程
pkill mongod


# 查询语句
模糊查询
查询条件中包含like时，格式为：` {"地址节全称":new RegExp(".*花园")}`

# 操作关键词
```yaml
>, >=, <, <=, !=, =
$gt, $gte, $lt, $lte,$ne,
And，OR，In，NotIn
无关键字, $or, $in，$nin
```

# 更新语句
MongoDB更新字段名，如将AddressNode的adalias字段改为adtext：`db.AddressNode.update({}, {$rename:{"adalias":"adtext"}}, false, true);`


# 数据备份恢复
```yaml
#数据备份
mongodump -d uadb  -u uadb -p psd  -o  /usr/local/mongodb/dump
#数据还原
mongorestore -drop  -d uadb   -u uadb -p psd  /usr/local/mongodb/dump/uadb
```  

# 删除数据库
db.dropDatabase();

# maxConns并发连接数设置
备注：V3.0版本以上参数为maxIncomingConnections，默认65536，详见
[V3.2官方configuration-options文档](https://docs.mongodb.org/v3.2/reference/configuration-options/)
## 查询并发数
db.serverStatus().connections
## ulimit 设置可以打开最大文件描述符的数量。
查看最大文件打开数：ulimite -n
临时生效：`ulimit -n 32768`
永久生效：`vim /etc/rc.local` 新增`ulimit -n 32768`

## 重启mongodb服务，带上--maxConns参数
`/usr/local/mongodb/bin/mongod --dbpath /usr/local/mongodb/data --logpath /usr/local/mongodb/log/mongodb.log --maxConns=20000  --fork --smallfiles`

# MongoDB全局变量设置
```yaml
# vim /etc/profile
export MONGODB_HOME=/usr/local/mongodb
export PATH=$MONGODB_HOME/bin:$PATH
```
