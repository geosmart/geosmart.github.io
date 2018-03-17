---
title: Elasticsearch批量插入测试
tags: Elasticsearch
notebook: N02 数据库
date: 2016-07-25 10:30:57
categories: 后端技术
---

Elasticsearch批量插入测试
数据：10万结构化document（json），每个1.3k；
测试结果：bulkProcess性能最优(4s)，bulkRequest次之（1m）；indexAPI适用于单条插入。
测试项目源码见[me.demo.elasticsearch](https://github.com/geosmart/me.demo.elasticsearch) 

- - -
<!-- more --> 

# 测试环境
两个Node(8G/4核)

# JMeter测试框架
TODO：模拟http测试rest

# 单条插入测试
以IndicesAdminClient新建Index,Type；以IndexAPI插入document(fields);

* [IndicesAdminClient ](https://www.elastic.co/guide/en/elasticsearch/client/java-api/2.3/java-admin-indices.html)
* [Index API](https://www.elastic.co/guide/en/elasticsearch/client/java-api/2.3/java-docs-index.html)

# 批量插入性能测试
以Bulk API进行手动批量插入，或采用BulkProcessor 进行自动分段插入；

* [bulk-api](https://www.elastic.co/guide/en/elasticsearch/client/java-api/2.3/java-docs-bulk.html)
* [bulk-processor](https://www.elastic.co/guide/en/elasticsearch/client/java-api/2.3/java-docs-bulk-processor.html)
* [bulk-api-examples](http://www.programcreek.com/java-api-examples/index.php?api=org.elasticsearch.action.bulk.BulkRequestBuilder)

# 问题记录
## EsRejectedExecutionException
bulkProcess执行成功，但设置.setConcurrentRequests(4)后，断开线程连接时会抛出如下错误
```java
transport: [Orchid] failed to notify response handler on rejection 
```
解决：todo

## ProcessClusterEventTimeoutException 

```shell 
##################################################################
# /etc/elasticsearch/elasticsearch.yml
#
# Base configuration for a write heavy cluster

# Force all memory to be locked, forcing the JVM to never swap
bootstrap.mlockall: true

## Threadpool Settings ##

# Search pool
threadpool.search.type: fixed
threadpool.search.size: 20
threadpool.search.queue_size: 100

# Bulk pool
threadpool.bulk.type: fixed
threadpool.bulk.size: 60
threadpool.bulk.queue_size: 300

# Index pool
threadpool.index.type: fixed
threadpool.index.size: 20
threadpool.index.queue_size: 100

# Indices settings
indices.memory.index_buffer_size: 30%
indices.memory.min_shard_index_buffer_size: 12mb
indices.memory.min_index_buffer_size: 96mb

# Cache Sizes
indices.fielddata.cache.size: 15%
indices.fielddata.cache.expire: 6h
indices.cache.filter.size: 15%
indices.cache.filter.expire: 6h

# Indexing Settings for Writes
index.refresh_interval: 30s
index.translog.flush_threshold_ops: 50000 
 
```
请教个es插入速度优化的问题，刚开始很快，但是现在目前每秒只能平均处理2个doc，
bulkProcess批量插入document，每个doc 25个字段，每个doc大小4k左右，3个Node(6个share,1个replica)；node配置（8G,4核）
配置了ES_HEAP_SIZE=3G

ElasticSearch索引优化
http://m635674608.iteye.com/blog/2289439


