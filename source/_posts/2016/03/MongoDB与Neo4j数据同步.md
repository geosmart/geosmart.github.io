title: MongoDB与Neo4j数据同步
date: 2016-03-23 17:18:13
tags: [Neo4j,MongoDB]
categories: [数据库]
---

采用mongo-connector及Neo4j Doc Manager将MongoDB中数据导入Neo4j（嵌套结构形成关系）
- - -
<!-- more -->

[参考文档](http://neo4j.com/developer/mongodb/#_neo4j_doc_manager)
[neo4j_doc_manager项目地址](https://github.com/neo4j-contrib/neo4j_doc_manager)

# MongoDB启用副本
## Windows安装MongoDB服务 bat脚本
```bash
@echo off
title  卸载MongoDB
sc delete MongoDB
cmd /k
```
## Windows卸载MongoDB服务 bat脚本
```bash
@echo off
title 安装MongoDB
D:\mongodb\bin\mongod --logpath "D:\mongodb\log\mongo.log" --logappend --dbpath "D:\mongodb\data" --directoryperdb --replSet myDevReplSet --serviceName "MongoDB" --serviceDisplayName "MongoDB"  --install
cmd /k
```
## 初始化MongoDB Replica set
进入mongo shell执行`rs.initiate()`

# 安装Neo4j Doc Manager
```bash
# 新增python环境neo4j.venv
virtualenv  --no-site-packages neo4j.venv
#  进入neo4j.venv
workon neo4j.venv
#  安装neo4j-doc-manager   --pre
pip install -i  http://pypi.douban.com/simple  neo4j-doc-manager --trusted-host pypi.douban.com
```
# 启动mongo-connector

进入Python环境：`workon neo4j.venv`
运行neo4j_doc_manager：`mongo-connector -m 192.168.1.188:27017 -t http://127.0.0.1:7474/db/data -d neo4j_doc_manager`
同步指定Databse.Collection：` mongo-connector -m 127.0.0.1:27017 -n uadb_suzhou_gyyq.AddressNode -t http://127.0.0.1:7474/db/data -d neo4j_doc_manager `
neo4j_doc_manager运行后，当MongoDB插入数据时，mongodb Document将会实时转换为图结构存储到Neo4j，文档Key会转换为Node,值对象作为Node的属性值。

# 问题记录
## No handlers could be found for logger "mongo_connector.util"
实际错误：py2neo.database.status.Unauthorized: http://127.0.0.1:7474/db/manage/server/jmx/domain/org.neo4j
解决方案：
1. 停用 authorization
考虑到性能和测试便捷可停用Neo4j安全授权机制。
在`neo4j-server.properties`中设置`dbms.security.auth_enabled=false`
2. 设置NEO4J_AUTH环境变量
若生产环境已启用授权，设置NEO4J_AUTH环境变量`export NEO4J_AUTH=user:password`

## AttributeError: 'Graph' object has no attribute 'cypher'
解决方案：[neo4j_doc_manager github issue](https://github.com/neo4j-contrib/neo4j_doc_manager/issues/59)
参考官网文档，安装时附加--pre参数，然而运行dev版有问题，老实安装stable版本即可

## OplogThread: Last entry no longer in oplog cannot recove
修改mongo-connector配置参数后报错
解决：删除日志文件（mongo-connector.log）所在根目录的`oplog.timestamp`文件，上次异常终止mongo-connector写入了xxx，导致无法正常运行

## 如何提高同步速度
[how-do-i-increase-the-speed-of-mongo-connector](https://github.com/mongodb-labs/mongo-connector/wiki/FAQ#how-do-i-increase-the-speed-of-mongo-connector)
[mongo-connector Configuration-Options](https://github.com/mongodb-labs/mongo-connector/wiki/Configuration-Options)
