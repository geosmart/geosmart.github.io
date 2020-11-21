---
title: DataSphereStudio的自动化部署
date: 2020-11-22
tags: [大数据]
---

DSS(DataSphereStudio)的实现强依赖于Linkis计算中间件，dss包含6个，而底层linkis需要部署18个服务，所以一般基于dss二次开发，关键就是对linkis的hadoop版本做适配，以及超多的微服务导致的的部署非常繁琐。

本文主要的关注点是如何将dss应用于生产环境并采用`gerrit+jenkins+ansible+docker`实施cicd。
实现对linkis和dss的自动化部署，封装每个微服务在不同运行环境的配置和启动脚本。
<!-- more -->  
# 关于DSS
DSS(DataSphereStudio)是一个一站式数据应用开发管理门户，基于插拔式的集成框架设计，基于计算中间件`Linkis`实现。

# linkis部署包结构说明
linkis总共18个微服务
## 服务列表
* eureka：注册中心
* linkis-gateway：网关
* linkis-resourcemanager：资源管理服务
* linkis-dsm-server：数据源服务
* linkis-mdm-server：元数据管理服务
* linkis-metadata：元数据服务
* linkis-bml：物料库
* linkis-cs-server：统一上下文服务
* linkis-publicservice：公共服务（variable,database,udf,workspace等）

>ujes 统一作业执行引擎

* linkis-ujes-hive-enginemanager
* linkis-ujes-hive-entrance
* linkis-ujes-jdbc-entrance
* linkis-ujes-python-enginemanager
* linkis-ujes-python-entrance
* linkis-ujes-shell-enginemanager
* linkis-ujes-shell-entrance
* linkis-ujes-spark-enginemanager
* linkis-ujes-spark-entrance

## 目录结构
每个服务的目录结构都一致，ujes部分会多一些引擎相关的配置：
* bin：服务启动/停止脚本
	* pid文件：linkis.pid
	* 用户切换脚本：rootScript.sh
	* 启动服务：start-${SERVICE_NAME}.sh
	* 停止服务：stop-${SERVICE_NAME}.sh
* config：服务配置文件
	* log4j2.xml：log4j日志配置
	* log4j.properties：日志变量
	* application.yml：spring boot配置
	* linkis.properties：linkis服务配置
	* linkis-engine.properties：linkis ujes引擎配置
	* log4j2-engine.xml：ujes引擎log4j日志配置
* lib：依赖jar包
* logs：日志文件
	* linkis.log：log4j日志，按天/大小回滚
	* linkis.out：jvm启动日志，每次启动覆盖
	* linkis-gc.log：jvm gc日志，每次启动覆盖

# 部署资源规划
安装linkis+dss服务测试环境，采用4核8G*6台虚机：
* Server1：linkis-gateway、linkis-publicservice、linkis-cs-server、linkis-dsm-server、linkis-bml、linkis-metadata、linkis-mdm-server
* Server2：enginemanager（spark、python）、entrance（spark、python）
* Server3：enginemanager（hive、shell）、entrance（hive、shell）、jdbc-entrance
* Server4：eureke、linkis-resourcemanager
* Server5：dss-server、linkis-appjoint-entrance、dss-flow-execution-entrance
* Server6：qualitis-server、azkaban、visualis-server

>测试采用简化部署结构，生产eureke，linkis-resourcemanager需要HA部署;
>每个服务的堆大小默认设置为1G;
>服务间存在依赖关系，需按顺序启动：比如需先启动eureka，gateway，resoucemanager等基础服务,再启动其他应用层服务；

单机资源够的情况下，测试时可以将ujes都部署在一台服务器；
![DataSphereStudio部署图](dss_deploy.png)
实际生产环境，根据服务使用人数，具体可参考官方的文档[Linkis生产部署参考指南](https://github.com/WeBankFinTech/Linkis/wiki/Linkis生产部署参考指南)做容量规划。

# dss部署包
* dss-web：前端服务（可包含visualis-web）
* dss-server：dss后端服务
* dss-flow-execution-entrance：工作流执行入口
* linkis-appjoint-entrance：linkis任务提交入口
* dss-init-db：仅用于第一次初始化数据库

由于linkis和dss都是微众开源的，dss部署包的目录结构和linkis类似；

# 部署定制流程
## 服务自定义编译
自定义hadoop版本，修改linkis根目录和linkis-ujes-spark-engine项目的pom.xml文件
比如修改hadoop到2.6
```xml 
<hadoop.version>2.6.5</hadoop.version>    
<hive.version>1.1.0</hive.version>    
<spark.version>2.3.0</spark.version>
```

编译问题
>shell-enginemanager存在jackson包冲突会导致启动失败，保留2.10.0，其他版本exclude即可
>遇到Assembly is incorrectly configured问题，将useStrictFiltering属性改成false即可

## 部署包jenkins准备
* mvn -N install
* mvn -Pspark2.3 clean install
* 将assembly/target/wedatasphere-linkis-{version}-dist.tar.gz解压后挂载到docker中

## 多环境自动部署
在官方的config目录下添加dev、test、prod等配置，按不同部署环境的环境变量配置config.sh和db.sh，并通过docker挂载到容器内；

linkis和dss的目录结构比较规范，做容器化时，只需要参考install.sh中的脚本，拆分成多个entrypoint即可。

## log4j运行日志挂载
* 在`bin/start-{SERVICE_NAME}.sh`脚本然后将`SERVER_LOG_PATH`改为`/var/log/{SERVICE_NAME}`，`SERVER_LOG_PATH`并挂载到docker中，以便在容器重启后能够保持日志;
* 将官方`log4j.properties`中的`logs/linkis.log`改为${env:SERVER_LOG_PATH}/linkis.log；
* gc和jvm日志也可参考log4j日志路径修改;

# docker镜像准备
* CDH环境配置：参考CDH Agent机器配置即可，配置好后需设置HADOOP_HOME，SPARK_HOME，HIVE_HOME等环境变量
* 根据不同的运行环境，挂载不同的hadoop/yarn的核心site.xml文件;
* 确保terminal能正常使用hdfs,spark-sql,hive,kinit等服务；

## docker启动入口
实现`startup.sh ${SERVICE_NAME}`,通过SERVICE_NAME参数实现启动指定的微服务；
每个微服务的entrypoint脚本主要实现几个步骤：
* 复制公共模块包
* 复制服务压缩包；
* 删除当前部署目录；
* 解压服务压缩包；
* 读取config中的变量，用sed替换spring和log4j等配置文件；
* 调用服务压缩包`bin/start-{SERVICE_NAME}.sh`启动服务；
* 检查服务是否启动成功并打印启动日志；

>linkis-gateway的entrypoint示例
```bash
#!/bin/sh
# linkis-gateway.sh
source ${workDir}/bin/entrypoint/functions.sh
EUREKA_URL=http://$EUREKA_INSTALL_IP:$EUREKA_PORT/eureka/

##GateWay Install
PACKAGE_DIR=springcloud/gateway
APP_PREFIX="linkis-"
SERVER_NAME="gateway"
SERVER_PATH=${APP_PREFIX}${SERVER_NAME}
SERVER_IP=$GATEWAY_INSTALL_IP
SERVER_PORT=$GATEWAY_PORT
SERVER_HOME=$LINKIS_WORK_HOME

###install dir
installPackage

###update linkis.properties
echo "$SERVER_PATH-update linkis conf"
SERVER_CONF_PATH=$SERVER_HOME/$SERVER_PATH/conf/linkis.properties
executeCMD $SERVER_IP "sed -i \"s#wds.linkis.ldap.proxy.url.*#wds.linkis.ldap.proxy.url=$LDAP_URL#g\" $SERVER_CONF_PATH"
executeCMD $SERVER_IP "sed -i \"s#wds.linkis.ldap.proxy.baseDN.*#wds.linkis.ldap.proxy.baseDN=$LDAP_BASEDN#g\" $SERVER_CONF_PATH"
executeCMD $SERVER_IP "sed -i \"s#wds.linkis.gateway.admin.user.*#wds.linkis.gateway.admin.user=$deployUser#g\" $SERVER_CONF_PATH"
isSuccess "subsitution linkis.properties of $SERVER_PATH"
echo "<----------------$SERVER_PATH:end------------------->"
##GateWay Install end

# start and check
startApp
sleep 10
checkServer
```

# 其他部署踩坑
## eureke配置
需要设置instance-id和prefer-ip-address，不然显示的是docker内部ip，且服务间不能正常通信（使用的默认是docker内部ip）；

## todo
