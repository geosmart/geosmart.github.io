title: Ne04j单机版和集群版部署
date: 2016-01-25 17:28:24
tags: [Neo4j]
categories: [数据库]
---

Neo4j HA(Neo4j High Availability)，高可用性主要指其包含容错机制和可进行水平扩展，即Neo4j Cluster
- - -
<!-- more -->

# 部署Ne04j单机版(windows)
## java se 8安装
[java8下载](http://download.oracle.com/otn-pub/java/jdk/8u71-b15/jdk-8u71-windows-x64.exe?AuthParam=1453700621_44741e28a0fd105dbfea10bad65c95b3)
安装java se8后，并临时设置环境变量：`set JAVA_HOME=E:\Software\jdk8x64\jre1.8`（避免与本机java7冲突）

## 下载Neo4j-3.0.0
[neo4j-enterprise-3.0.0-M02-windows](http://neo4j.com/artifact.php?name=neo4j-enterprise-3.0.0-M02-windows.zip)

## 下载Neo4j-2.3.2
[neo4j-enterprise-2.3.2-windows](http://neo4j.com/artifact.php?name=neo4j-community-2.3.2-windows.zip)
设置NEO4J_HOME，

## Neo4j Browser
* 运行bin\Neo4j.bat，如`cd F:\Dev\neo4j-enterprise-3.0.0-M02\bin && Neo4j.bat`
* 在浏览器打开Neo4j的在线REPL，即[Neo4j Browser](http://localhost:7474/),在命令行输入Cypher query语句进行查询
* 在浏览器打开[Neo4j Guide](http://localhost:7474/webadmin/#/info/)了解Neo4j
* 老版本的在线入口：[neo4j webAdmin](http://localhost:7474/webadmin/#/index/)

## 在Windows PowerShell运行Neo4j
```yaml
# 权限配置
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
# 导入Neo4j模块
Import-Module C:\Neo4j\bin\Neo4j-Management.psd1
# 查询Neo4j命令
Get-Command -Module Neo4j-Management
# 查询NEO4J_HOME路径
Get-Neo4jServer C:\Neo4j
# 启动Neo4j服务
Start-Neo4jServer
# 关闭Neo4j服务
Stop-Neo4jServer
# 重启Neo4j服务
Restart-Neo4jServer
```

## Neo4j Browser常用脚本
:help 帮助
shift+enter 多行书写
ctrl+enter 执行
:clear 清空执行结果
:play 打开入门教程

# 部署Neo4j集群(Linux)
[neo4j manual doc](http://neo4j.com/docs/3.0.0-M02/)
- TODO
Neo4j HA has been designed to make the transition from single machine to multi machine operation simple, by not having to change the already existing application.
Consider an existing application with Neo4j embedded and running on a single machine. To deploy such an application in a multi machine setup the only required change is to switch the creation of the GraphDatabaseService from GraphDatabaseFactory to HighlyAvailableGraphDatabaseFactory. Since both implement the same interface, no additional changes are required.
