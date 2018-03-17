---
title: Elasticsearch学习笔记
tags: Elasticsearch
notebook: N02 数据库
categories: 后端技术
date: 2016-07-22 10:23:27 
---

Elasticsearch是一个基于Apache Lucene(TM)的开源搜索引擎。
Lucene非常复杂，你需要深入了解检索的相关知识来理解它是如何工作的。Elasticsearch也使用Java开发并使用Lucene作为其核心来实现所有索引和搜索的功能，但是它的目的是通过简单的RESTful API来隐藏Lucene的复杂性，从而让全文搜索变得简单。
不过，Elasticsearch不仅仅是Lucene和全文搜索，我们还能这样去描述它：

* 分布式的实时文件存储，每个字段都被索引并可被搜索
* 分布式的实时分析搜索引擎
* 可以扩展到上百台服务器，处理PB级结构化或非结构化数据
而且，所有的这些功能被集成到一个服务里面，你的应用可以通过简单的RESTful API、各种语言的客户端甚至命令行与之交互。

在Elasticsearch中，文档归属于一种类型(type),而这些类型存在于索引(index)中，类比传统关系型数据库：

  Relational DB -> Databases -> Tables -> Rows -> Columns
  Elasticsearch -> Indices   -> Types  -> Documents -> Fields

Elasticsearch集群可以包含多个索引(indices)（数据库），每一个索引可以包含多个类型(types)（表），每一个类型包含多个文档(documents)（行），然后每个文档包含多个字段(Fields)（列）。

- - -
<!-- more --> 

# Document 文档

程序中大多的实体或对象能够被序列化为包含键值对的JSON对象，键(key)是字段(field)或属性(property)的名字，值(value)，可以是字符串、数字、布尔类型、另一个对象、值数组或者其他特殊类型，比如表示日期的字符串或者表示地理位置的对象。

通常，我们可以认为对象(object)和文档(document)是等价相通的。但他们还是有所差别：

* 对象(Object)是一个JSON结构体——类似于哈希、hashmap、字典或者关联数组；
* 对象(Object)中还可能包含其他对象(Object)。 
* Elasticsearch中，文档(document)这个术语有着特殊含义，它特指最顶层结构或者根对象(root object)序列化成的JSON数据（以唯一ID标识并存储于Elasticsearch中）。

## 文档元数据
一个文档不只有数据。它还包含了元数据(metadata)——关于文档的信息。三个必须的元数据节点是： 

节点          | 说明              
:------------ | :--------------  
_index        | 文档存储的地方
_type         | 文档代表的对象的类
_id           | 文档的唯一标识

### _index
索引(index)类似于关系型数据库里的“数据库”——它是我们存储和索引关联数据的地方。
>事实上，我们的数据被存储和索引在分片(shards)中，索引只是一个把一个或多个分片分组在一起的逻辑空间。
然而，这只是一些内部细节——我们的程序完全不用关心分片。
我们唯一需要做的仅仅是选择一个索引名。这个名字必须是全部小写，不能以下划线开头，不能包含逗号。

### _type
在应用中，我们使用对象表示一些“事物”，例如一个用户、一篇博客、一个评论，或者一封邮件。每个对象都属于一个类(class)，这个类定义了属性或与对象关联的数据。user类的对象可能包含姓名、性别、年龄和Email地址。

在Elasticsearch中，我们使用相同类型(type)的文档表示相同的“事物”，因为他们的数据结构也是相同的。

* 每个类型(type)都有自己的映射(mapping)或者结构定义，就像传统数据库表中的列一样。
* 所有类型下的文档被存储在同一个索引下，但是类型的映射(mapping)会告诉Elasticsearch不同的文档如何被索引。
* _type的名字可以是大写或小写，不能包含下划线或逗号。我们将使用blog做为类型名。

### _id
id仅仅是一个字符串，它与_index和_type组合时，就可以在Elasticsearch中唯一标识一个文档。当创建一个文档，你可以自定义_id，也可以让Elasticsearch帮你自动生成。

# Index 索引
文档通过index API被索引——使数据可以被存储和搜索。
但是首先需要决定文档所在。文档通过其_index、_type、_id唯一确定。

# Elasticsearch CRUD
## 检索
request：`GET /{_index}/{_type}/{_id}?pretty`，如`/website/blog/123?pretty`；  
response：
```json
{
  "_index" :   "website",
  "_type" :    "blog",
  "_id" :      "123",
  "_version" : 1,
  "found" :    true,
  "_source" :  {
      "title": "My first blog entry",
      "text":  "Just trying this out...",
      "date":  "2014/01/01"
  }
}
```
### pretty
>在任意的查询字符串中增加pretty参数，类似于上面的例子。会让Elasticsearch美化输出(pretty-print)JSON响应以便更加容易阅读。_source字段不会被美化，它的样子与我们输入的一致。

### 检索部分文档
通常，GET请求将返回文档的全部，存储在_source参数中。

* 请求个别字段可以使用_source参数。多个字段可以使用逗号分隔，如`GET /website/blog/123?_source=title,text`；
* 只想得到_source字段而不要其他的元数据，你可以这样请求：`GET /website/blog/123/_source`；

### 检查文档是否存在
如果你想做的只是检查文档是否存在——你对内容完全不感兴趣——使用HEAD方法来代替GET。HEAD请求不会返回响应体，只有HTTP头：

* 存在返回`200 OK`状态：
* 不存在返回`404 Not Found`：

### mget批量查询
从Elasticsearch中检索多个文档，相对于逐条get检索，更快的方式是在一个请求中使用multi-get或者mget API。

## 更新
文档在Elasticsearch中是不可变的——我们不能修改他们。如果需要更新已存在的文档，可以使用index API 重建索引(reindex) 或者替换掉它。  
在内部，Elasticsearch已经标记旧文档为删除并添加了一个完整的新文档。旧版本文档不会立即消失，但你也不能去访问它。
Elasticsearch会在你继续索引更多数据时清理被删除的文档。

## 创建
当索引一个文档，如何确定是完全创建了一个新的还是覆盖了一个已经存在的呢？
请记住`_index、_type、_id`三者唯一确定一个文档。
### Elasticsearch自动生成唯一_id
所以要想保证文档是新加入的，最简单的方式是使用POST方法让Elasticsearch自动生成唯一_id：
`POST /website/blog/` 
### 自定义的_id
如果使用自定义的_id，必须告诉Elasticsearch应该在`_index、_type、_id`三者都不同时才接受请求。有两种实现方式

1. 使用op_type查询参数：`PUT /website/blog/123?op_type=create`；
2. 在URL后加/_create做为端点：`PUT /website/blog/123/_create`；

响应结果

* 如果请求成功的创建了一个新文档，Elasticsearch将返回正常的元数据且响应状态码是`201 Created`；
* 如果包含相同的_index、_type和_id的文档已经存在，Elasticsearch将返回`409 Conflict`响应状态码；

## 删除
使用DELETE方法：`DELETE /website/blog/123`；

* 如果文档被找到，Elasticsearch将返回200 OK状态码和以下响应体。注意_version数字已经增加了。 
* 如果文档未找到，我们将得到一个404 Not Found状态码， 

> *. 尽管文档不存在——"found"的值是false——_version依旧增加了。这是内部记录的一部分，它确保在多节点间不同操作可以有正确的顺序。
*. 除一个文档也不会立即从磁盘上移除，它只是被标记成已删除。Elasticsearch将会在你之后添加更多索引的时候才会在后台进行删除内容的清理。

## 批量操作
就像mget允许一次性检索多个文档一样，
`bulk API`允许我们使用单一请求来实现多个文档的`create、index、update或delete`'；这对索引类似于日志活动这样的数据流非常有用，它们可以以成百上千的数据为一个批次按序进行索引。
bulk请求体如下，它有一点不同寻常：

```json
{ action: { metadata }}\n
{ request body        }\n
{ action: { metadata }}\n
{ request body        }\n
```

这种格式类似于用"\n"符号连接起来的一行一行的JSON文档流(stream)。两个重要的点需要注意：

* 每行必须以"\n"符号结尾，包括最后一行。这些都是作为每行有效的分离而做的标记。
* 每一行的数据不能包含未被转义的换行符，它们会干扰分析——这意味着JSON不能被美化打印。

[为什么bulk API需要带换行符的奇怪格式，而不是像mget API一样使用JSON数组？](http://es.xiaoleilu.com/040_Distributed_CRUD/35_Bulk_format.html)
在分布式环境下，Elasticsearch则从网络缓冲区中一行一行的直接读取数据。它使用换行符识别和解析action/metadata行，以决定哪些分片来处理这个请求。这利于任务分解，可以减少JSON序列化RAM消耗，从而降低JVM GC时间；

### 行为(action)
action/metadata这一行定义了文档行为(what action)发生在哪个文档(which document)之上。

行为(action)必须是以下几种：

行为    | 解释
:-------|:-----------
create  |当文档不存在时创建之。
index   | 创建新文档或替换已有文档。
update  | 局部更新文档。
delete  | 删除一个文档。

在索引、创建、更新或删除时必须指定文档的`_index、_type、_id`这些元数据(metadata)。

### 请求体(request body)
请求体由文档的_source组成——文档所包含的一些字段以及其值，即提供文档用来检索。

* update操作需要请求体，请求体的组成应该与update API（doc, upsert, script等等）一致。
* delete操作不需要请求体(request body)。

### 响应结果
每个子请求都被独立的执行，所以一个子请求的错误并不影响其它请求。
如果任何一个请求失败，顶层的error标记将被设置为true，然后错误的细节将在相应的请求中被报告：

### 请求最佳大小（sweetspot）
整个批量请求需要被加载到接受我们请求节点的内存里，所以请求越大，给其它请求可用的内存就越小。
有一个最佳的bulk请求大小。超过这个大小，性能不再提升而且可能降低。  
最佳大小，当然并不是一个固定的数字。它完全取决于硬件、文档的大小和复杂度以及索引和搜索的负载。  

如何找到最佳点(sweetspot)：

* 试着批量索引标准的文档，随着大小的增长，当性能开始降低，说明每个批次的大小太大了。
* 开始的数量可以在1000~5000个文档之间，如果文档非常大，可以使用较小的批次。
* 通常着眼于请求批次的物理大小是非常有用的。一千个1kB的文档和一千个1MB的文档大不相同。一个好的批次最好保持在5-15MB大小间。

# Shard和Replica 
## shard分片
每个Index（对应Database）包含多个Shard，默认是5个，分散在不同的Node上，但不会存在两个相同的Shard存在一个Node上，这样就没有备份的意义了。Shard是一个最小的Lucene索引单元。
当插入document的时候，Elasticsearch通过对docid进行hash来确定其放在哪个shard上面，然后在shard上面进行索引存储。  
shard代表索引分片，es可以把一个完整的索引分成多个分片，这样的好处是可以把一个大的索引拆分成多个，分布到不同的节点上。构成分布式搜索。分片的数量只能在索引创建前指定，并且索引创建后不能更改。

## replica副本  
replicas就是备份，Elasticsearch采用的是Push Replication模式，当你往 master主分片上面索引一个文档，该分片会复制该文档(document)到剩下的所有 replica副本分片中，这些分片也会索引这个文档。  
es可以设置多个索引的副本，副本的作用一是提高系统的容错性，当个某个节点某个分片损坏或丢失时可以从副本中恢复。二是提高es的查询效率，es会自动对搜索请求进行负载均衡。

# gateway
代表es索引的持久化存储方式，es默认是先把索引存放到内存中，当内存满了时再持久化到硬盘。当这个es集群关闭再 重新启动时就会从gateway中读取索引数据。es支持多种类型的gateway，有本地文件系统（默认），分布式文件系统，Hadoop的HDFS和 amazon的s3云存储服务。

# discovery.zen
代表es的自动发现节点机制，es是一个基于p2p的系统，它先通过广播寻找存在的节点，再通过多播协议来进行节点之间的通信，同时也支持点对点的交互。

# Transport
代表es内部节点或集群与客户端的交互方式，默认内部是使用tcp协议进行交互，同时它支持http协议（json格式）、thrift、servlet、memcached、zeroMQ等的传输协议（通过插件方式集成）。

# analyzer
分布式搜索elasticsearch中文分词集成：elasticsearch官方只提供smartcn这个中文分词插件，效果不是很好，好在国内有medcl大神写的两个中文分词插件，一个是[IKAnalyzer分词插件](https://github.com/medcl/elasticsearch-analysis-ik)的，一个是[mmseg](https://github.com/medcl/elasticsearch-analysis-mmseg)的

## IKAnalyzer分词安装
下载elasticsearch-analysis-ik源码并打包
```shell
git clone https://github.com/medcl/elasticsearch-analysis-ik
cd elasticsearch-analysis-ik
mvn clean
mvn compile
mvn package
```
拷贝和解压release下的文件: #{project_path}/elasticsearch-analysis-ik/target/releases/elasticsearch-analysis-ik-*.zip 到你的 elasticsearch 插件目录, 如: plugins/ik 重启elasticsearch 

## IKAnalyzer测试中文分词
IKAnalyzer分词测试：http://es1.es.com:9200/mycompany/_analyze?analyzer=ik&pretty=true&text=中华人民共和国国歌

## 对指定field建全文索引
* 对index=cloudx_web_v3,type=T_EVENT_LOG的name字段以IKAnalyzer建全文索引
curl -XPUT http://es1.es.com:9200/cloudx_web_v3/T_EVENT_LOG/_mapping?pretty -d '{"T_EVENT_LOG":{"properties":{"name":{"type":"string","analyzer":"ik","search_analyzer":"ik"}}}}'
* 测试索引：curl -XPOST http://es1.es.com:9200/cloudx_web_v3/_search?pretty  -d '{"query":{"match":{"name":{"query":"规则 专用","operator":"and"}}}}' 

## 问题记录
### field must be set when search_analyzer is set
* 请求参数：
curl -XPUT http://es1.es.com:9200/cloudx_web_v3/T_EVENT_LOG/_mapping?pretty -d '{"T_EVENT_LOG":{"properties":{"name":{"type":"string","indexAnalyzer":"ik","searchAnalyzer":"ik"}}}}'
* 问题日志：
{"error":{"root_cause":[{"type":"mapper_parsing_exception","reason":"analyzer on field [name] must be set when search_analyzer is set"}],"type":"mapper_parsing_exception","reason":"analyzer on field [name] must be set when search_analyzer is set"},"status":400}

* 问题解决：参考旧版本教程的坑，V2.3.4的参数改了，应为
curl -XPUT http://es1.es.com:9200/cloudx_web_v3/T_EVENT_LOG/_mapping?pretty -d '{"T_EVENT_LOG":{"properties":{"name":{"type":"string","analyzer":"ik","search_analyzer":"ik"}}}}'


# 常见问题

## 如何合理设置shard和replica
[ElasticSearch性能调优-Shard数](http://www.cnblogs.com/richaaaard/p/5231905.html)
### shard数
* shard数==node数时
此时性能最佳，但是由于ElasticSearch的不可变性（Immutable）的限制，系统无法对Shard进行重新拆分分配，除非重新索引这个文件集合，而重建索引开销巨大,所以，为了支持未来可能的水平扩展，一般会为集群分配比node数更多的shard数，也就是说每个节点会有多个Shard。

* shard数==node数*2
shard过多就会引入另外一系列的性能问题，如对于任意一次完整的搜索，ElasticSearch会分别对每个shard进行查询，最后进行汇总。当节点数和shard数是一对一的时候，所有的查询可以并行运行。但是，对于具有多个shard的节点，如果磁盘是15000RPM或SSD，可能会相对较快，但是这也会存在等待响应的问题，所以通常不推荐一个节点超过2个shard。

### replica数
Replica也是Shard，与shard不同的是，replica只会参与读操作，同时也能提高集群的可用性。
对于Replica来说，它的主要作用就是提高集群错误恢复的能力，所以replica的数目与shard的数目以及node的数目相关，
与shard不同的是，replica的数目可以在集群建立之后变更，且代价较小，所以相比shard的数目而言，没有那么重要。
3 node, 3 shard, 1 replica (each)，2个node宕机，服务仍然正常运行。


## [如何防止elasticsearch的脑裂问题](https://segmentfault.com/a/1190000004504225)
> 如果刚开始使用elasticsearch，建议配置一个3节点集群。这样你可以设置minimum_master_nodes为2，减少了脑裂的可能性，但仍然保持了高可用的优点：你可以承受一个节点失效但集群还是正常运行的。  
但如果已经运行了一个两节点elasticsearch集群怎么办？可以选择为了保持高可用而忍受脑裂的可能性，或者选择为了防止脑裂而选择高可用性。为了避免这种妥协，最好的选择是给集群添加一个节点。这听起来很极端，但并不是。  
对于每一个elasticsearch节点你可以设置node.data参数来选择这个节点是否需要保存数据。缺省值是“true”，意思是默认每个elasticsearch节点同时也会作为一个数据节点。  
在一个两节点集群，你可以添加一个新节点并把node.data参数设置为“false”。这样这个节点不会保存任何分片，但它仍然可以被选为主（默认行为）。因为这个节点是一个无数据节点，所以它可以放在一台便宜服务器上。  
现在你就有了一个三节点的集群，可以安全的把minimum_master_nodes设置为2，避免脑裂而且仍然可以丢失一个节点并且不会丢失数据。

> If discovery.zen.master_election.filter_client is true 

>1. pings from client nodes (nodes where node.client is true, or both node.data and node.master are false) are ignored during master election; the default value is true.   
2. pings from non-master-eligible data nodes (nodes where node.data is true and node.master is false) are ignored during master election; the default value is false.   
3. Pings from master-eligible nodes are always observed during master election.  

> Nodes can be excluded from becoming a master by setting node.master to false. 
Note, once a node is a client node (node.client set to true), it will not be allowed to become a master (node.master is automatically set to false).

master和data同时配置会产生一些神奇的效果：
1. 当master为false，而data为true时，会对该节点产生严重负荷；
2. 当master为true，而data为false时，该节点作为一个协调者； 
3. 当master为false，data也为false时，该节点就变成了一个负载均衡器。 

## [如何给Elasticsearch设置合适的Heap内存](https://www.elastic.co/guide/en/elasticsearch/guide/current/heap-sizing.html)
设置Elastic Heap内存（for Elasticsearch faster GCs）：`export ES_HEAP_SIZE=3g`，  
建议分配可用内存的50%给ElasticSearch（如`aggregating on analyzed string fields`比较少的话，可以设置更小，以留下足够的空闲内存给lucene），
注意Lucene的segments是不可变的，为提高聚合和倒排索引的性能，lucene需要占用系统内存作为缓存

## 如何删除document中的重复数据？ 
[minimizing-document-duplication-in-elasticsearch](https://qbox.io/blog/minimizing-document-duplication-in-elasticsearch)  
http://es1.es.com:9200/cloudx_web_v3/T_EVENT_LOG/_search?pretty=true -d `{json}`
```json
{
    "aggs": {
        "duplicateCount": {
            "terms": {
                "field": "name",
                "min_doc_count": 2
            },
            "aggs": {
                "duplicateDocuments": {
                    "top_hits": {}
                }
            }
        }
    }
}
```

# ES参考资料
* [Richaaaard的Elasticsearch系列教程](http://www.cnblogs.com/richaaaard/category/783901.html)
* [ES调优参数列表](https://github.com/garyelephant/blog/blob/master/elasticsearch_optimization_checklist.md)