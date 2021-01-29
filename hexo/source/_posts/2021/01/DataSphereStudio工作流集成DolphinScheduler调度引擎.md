---
title: DataSphereStudio工作流集成DolphinScheduler调度引擎
date: 2021-01-28 10:12:09
tags: [大数据,Scheduler]
---

# DSS接入第三方应用（AppJoint）
DSS(DataSphere Studio)从一开始就被设计成为一个开放的、具有强扩展能力的系统。
DSS系统希望第三方系统是能以插拔式的方式接入，为了实现上述的理念，DSS提出了AppJoint(应用关节)的概念。
AppJoint从作用上来说是连接两个系统，并为两个系统的协调运行提供服务。 

## 接入问题
任务提交到DSS系统，并由DSS系统转发给第三方外部系统进行执行，必须要考虑并实现下面的几点功能。
1. 解决双方系统用户的鉴权问题；
2. 双方系统都需要对用户提交任务的元数据进行正确处理；
3. DSS系统要能以同步或者异步的方式正确地提交任务给第三方系统进行执行；
4. 任务提交到第三方系统之后，外部系统需要能将日志、状态等信息返回给DSS系统；
5. 第三方系统在任务执行完毕之后，将可能产生的任务结果等信息持久化到执行的路径；

# 具体实现
为了方便外部系统的接入，DSS提供了SDK的方式,maven依赖引入`dss-appjoint-core`，具体如下
```xml
<dependency>
    <groupId>com.webank.wedatasphere.dss</groupId>
    <artifactId>dss-appjoint-core</artifactId>
    <version>${dss.version}</version>
</dependency>
```
dss-appjoint-core提供了的AppJoint的顶级接口，想要接入DSS系统的第三方系统都需要实现该顶层接口，此接口有以下方法需要用户进行实现
## getSecurityService
SecurityService是用来进行解决DSS系统与第三方系统的鉴权问题。
用户在DSS系统进行登录之后，并希望提交任务到第三方系统，首先第三方系统需要能够将这个用户进行鉴权。

## getProjectSerivice
ProjectService是用来进行解决DSS系统与第三方系统的工程管理问题。
用户在DSS系统进行新增、删除、修改工程的时候，第三方系统也需要进行同步进行相同的动作，这样的目的是为了双方系统能够在工程层面实现统一。

## getNodeService
NodeService是用来解决用户在DSS提交的任务在第三方系统生成相应的任务的问题。
用户如果在DSS系统的工作流中新建了一个工作流节点并进行任务的编辑，第三方系统需要同步感知到

## getNodeExecution
NodeExecution接口是用来将任务提交到第三方系统进行执行的接口，NodeExecution 接口有支持短时间任务的和支持长时间任务的。
* 短时间任务（NodeExecution），如邮件发送等，可以直接实现NodeExecution接口，并重写execute方法，DSS系统同步等待任务结束。
* 长时间任务（LongTermNodeExecution），如数据质量检测等，可以实现LongTermNodeExecution接口，并重写submit方法，返回一个NodeExecutionAction，DSS系统通过这个NodeExecutionAction可以向第三方系统获取任务的日志、状态等。

# 集成DolphinScheduler
针对DSS接入需要解决的问题，DolphinScheduler（下面简称ds）中如何对应解决

## 用户鉴权
* ds调用linkis gateway：cookie中写入bdp-user-ticket-id
* linkis调用ds：dss ldap登陆ds后可自动创建token，linkis调用ds接口前，先查询token并缓存（设置ttl)，然后用token调用ds接口；

## 资源同步
ds中以下资源更新时，同步到dss：
* 项目（project）
* 工作流（process_definition）：
* 文件：hdfs目录和文件：bml服务
* UDF包/函数定义：hdfs目录和jar包
* 数据源：jdbc连接配置
* 队列：任务执行时可选择的yarn队列
* 告警组：任务执行异常时选择的告警组（包含用户列表）

哪些需要在dss更新时，同步到ds
## 项目
项目增删改；

##  工作流
工作流增删改
每次dss保存时，dss和ds有各自的工作流版本维护，不用额外双方同步；

针对ds中的任务类型，dss需要对应做适配
### shell
脚本直接映射

### sql
dss中hive、sql、jdbc需要映射成对应的sql任务

### python
脚本直接映射

### flink
待支持

### sqoop
待支持

### http
待支持

### datax
待支持

### condition
考虑基于dss signal实现

### dependent
考虑基于dss signal实现

### mapreduce
待支持

### procedure
待支持

### subprocess
dss中subflow映射

## 文件
DSS中DAG保存，DAG节点脚本脚本保存，资源上传都需同步
* dag任务节点关联的脚本，会通过linkis-bml服务保存为hdfs文件，存储在linkis_resources_version表，此时需要调用ds接口同步到ds的resource表
* ds和linkis的source的根目录需设置一致，不然ds的web界面不能下载resource对应的文件
## UDF包/函数定义
dss的linkis_udf表新增udf时，需要调用ds接口同步到ds的t_ds_udfs表

## 数据源
dss有JDBC连接配置，但目前需要支持配置多个不同的数据源，不同类型的数据源配置参数会不一致。

如果要支持同步，dss的前后端都需要新增多jdbc源支持，改造好才能在dss编辑jdbc配置时同步到ds的数据源;

## 队列
* dss不同用户可以在配置中设置默认任务提交的yarn队列名，每个工作流及节点也可以配置执行的yarn队列；
* ds中每个工作流可以设置执行租户，租户可以预设置yarn队列；

这儿如果需要做到队列配置的同步，需要在dss中添加租户的管理，dss为租户设置队列时需要调用ds接口同步到队列（t_ds_queue），租户（t_ds_tenant）表

>等linkis1.0发布之后支持协同开发，通过设置工程的租户来同步租户队列

## 任务执行
dss任务执行分实时执行和定时执行2种，
* 实时执行直接调用linkis的对应engine执行任务；
* 定时执行，dss工作流同步到ds后，由ds的调度器定时触发worker执行，此处worker不直接启动任务，而是将任务跳过linkis-ujes-client提交给具体的linkis engine执行，worker实时获取任务的执行日志/进度/状态等数据；









