---
title: Neo4j索引笔记之SchemaIndex和LegacyIndex
tags: [Neo4j,Lucene]
notebook: N02 数据库
categories: 数据库
date: 2016-05-01 09:57:20
---

neo4j包含schema indexes 和 legacy indexes两种类型，两者理念不同且不可互换或兼容，实际应用中应明确检索需求后采用合适的索引。
- - -
<!-- more -->

# schema index vs legacy index
参考[neo4j index-confusion](http://nigelsmall.com/neo4j/index-confusion)
* schema index和legacy index 都是基于lucene实现；
* 如果你正在使用Neo4j 2.0或者更高版本并且不需要支持2.0版本之前legacy index的代码，那么请只使用schema index同时避免legacy index；
* 如果你不得不使用Neo4j的早期版本，并且无法升级，无论如何你都只有一种索引可以选择（legacy index）；
* 如果你需要全文检索的索引，不管是什么版本，都将使用legacy index。

# schema index（schema based indexes）
`Neo4j is a schema-optional graph database. You can use Neo4j without any schema. Optionally you can introduce it in order to gain performance or modeling benefits.	This allows a way of working where the schema does not get in your way until you are at a stage where you want to reap the benefits of having one.`
* 在Neo4j 2.0版本之前，Legacy index被称作indexes。这个索引是在graph外部通过Lucene实现，允许“节点”和“关系”以键值对的形式被检索。从Neo4j 提供的REST接口来看，被称作`index`的变量通常是指Legacy indexes；
* Legacy index能够提供全文本检索的能力。这个功能并没有在schema index中被提供，这也是Neo4j 2.0* 版本保留legacy indexes的原因之一。

## 新建索引
create index on  :Node(property)，会对指定label property的所有node新建index ，index新建成功后，当graph更新时index会自动更新，index默认存储在根目录的/schema/index/lucene目录；
如：
``` sql
# 新建索引
CREATE INDEX ON :AddressNode( preAddressNodeGUIDs)
# 删除索引
DROP INDEX ON :AddressNode(_id)
```

## 存储方式
schema index存储方式为复合索引（Compound Index），除了段信息文件，锁文件，以及删除的文件外，其他的一系列索引文件压缩一个后缀名为cfs的文件，即所有的索引文件会被存储成一个单例的Directory，
此方式有助于减少索引文件数量，减少同时打开的文件数量，从而获取更高的效率。比如说，查询频繁，而不经常更新的需求，就很适合这种索引格式。

# legacy index
[Neo4j Legacy Index配置参数](http://neo4j.com/docs/stable/indexing-create-advanced.html)

参数            | 值               | 描述
:------------ | :-------------- | :-----------------------------------------------------------------------------------:
type          | exact, fulltext | exact采用Lucene keyword analyzer是默认配置. fulltext采用white-space tokenizer in its analyzer.
to_lower_case | true, false     | type=fulltext时生效，在新建索引和查询时会自动进行字母的大小写转换，默认为小写
analyzer      | Analyzer类全名     | 自定义Lucene Analyzer，注意：to_lower_case配置会默认将查询参数转换为小写.如果自定义analyzer索引写入的字母为大写，查询结果将会不匹配

## 新建索引
分exact和fulltext两类，两者可结合使用，可新建relationship索引，默认存储在根目录的index/lucene目录；  
fulltext索引新建方式参考笔记[Neo4j中实现自定义中文全文索引](http://geosmart.github.io/2016/04/21/Neo4j中实现自定义中文全文索引)
* 注意：使用legacy index查询往往需要一个start node；

## 存储方式
legacy index采用非复合索引，更灵活，可以单独的访问某几个索引文件

# Neo4j联合索引
参考：https://dzone.com/articles/indexing-neo4j-overview
Neo4j不支持联合索引，可采用拼接字段实现

Neo4j 3.0开始支持联合索引，但需要升级至JDK8
https://github.com/neo4j/neo4j/issues/6841
