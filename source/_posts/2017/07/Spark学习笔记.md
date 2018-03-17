---
title: Spark学习笔记
date: 2017-07-23 08:52:58
tags: [Spark]
categories: 人工智能
---

- - -
<!-- more --> 
目前的大数据处理可以分为如以下三个类型。 
1. 复杂的批量数据处理（batch data processing），通常的时间跨度在数十分钟到数小时之间。
2. 基于历史数据的交互式查询（interactive query），通常的时间跨度在数十秒到数分钟之间。
3. 基于实时数据流的数据处理（streaming data processing），通常的时间跨度在数百毫秒到数秒之间。 

目前已有很多相对成熟的开源软件来处理以上三种情景，
* 我们可以利用MapReduce来进行批量数据处理，
* 可以用Impala来进行交互式查询，
* 对于流式数据处理，我们可以采用Storm。


[Apache Spark 的设计与实现](https://www.gitbook.com/book/yourtion/sparkinternals)

[spark系列博客](http://ifeve.com/category/spark/)

[spark java api doc](http://spark.apache.org/docs/latest/api/java/index.html)
# 问题记录
## csv 转 parquet
## parquet 转csv
## parquet join操作