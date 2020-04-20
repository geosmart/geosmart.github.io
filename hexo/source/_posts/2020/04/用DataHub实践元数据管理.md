---
title: 用DataHub实践元数据管理
date: 2020-04-19 20:49:13
tags: [DataHub]
---

用linkedin开源框架datahub实现元数据管理
<!-- more -->

# Datahub
![datahub-architecture](datahub-architecture.png)

# 术语
## Metadata-Architecture
* GMA：Generalized Metadata Architecture，通用元数据架构，GMA通过Rest.li提供微服务（即GMS)。GMA的Generalized体现在存储层支持文档型CRUD，复杂Join，图遍历，全文索引；
* GMS：Generalized Metadata Service，通用元数据服务，需通过GMA DAOS访问元数据；
* GMA DAO：GMA的通用数据访问层，包含4种类型的DAO：
  * Key-value DAO（LocalDAO）:kv本地搜索
  * Search DAO：文档搜索
  * Query DAO：图/非图搜索
  * Remote DAO：只读形式访问远程GMS元数据

## Metadata-Model
* URN：Uniform Resource Name，统一资源名称，如`urn:<Namespace>:<Entity Type>:<ID>`；
* PDL： a schema definition language for Pegasus，用于服务端和客户端的数据序列化/反序列化，是Rest.li框架的一部分；
  * Pegasus：支持丰富的语法，可实现对复杂关系做表示和建模；
* AVSC：avro序列化生成的文件格式，datahub支持用`Pegasus's DataTranslator`实现pdsc和avsc格式的相互转换；
* PDSC：Pegasus schema definition language，一种定义schema的DSL语言，思想源于AVRO1.4.1；；

## Metadata-Event
* MXE(Metadata Events)元数据事件
  * MCE：Metata Change Event，元数据change事件，
    * snapshot-oriented metadata change proposal
    * delta-oriented metadata change proposal
  * FMCE：Failed Metadata Change Event
  * MAE：Metadata Audit Event，元数据commited change事件，

## FrameWork
* Rest.li：实现REST协议，服务端/客户端协议对象生成
* Kafka：元数据事件异步解耦
* ElasticSearch：全文索引
* Neo4j：图检索

# 参考
* [datahub-what](https://github.com/linkedin/datahub/tree/master/docs/what)