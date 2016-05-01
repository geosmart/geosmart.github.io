title: Lucene学习笔记
date: 2016-04-29 21:49:36
tags: [Lucene]
categories: [数据库]
---

Neo4j图数据库的索引采用的是Lucene全文索引，特别是LegacyIndex部分，需要深入了解Lucene进行索引定制，之前以IK分词在Solr中建索引和检索浅尝辄止，对Lucene也是停留在概念层。  
Solr对Lucene商业封装后的易用性很强，提供了比Lucene更为丰富的查询语言，同时实现了可配置、可扩展并对查询性能进行了优化，并且提供了一个完善的功能管理界面。Solr的封装屏蔽了许多技术细节，但是对于开发人员来说，最好还是自下而上循序渐进比较好。
lucene（全文检索引擎工具包）>solr（企业级搜索应用服务器）>nutch（分布式检索引擎）和打Boss一样，得一个个来。
- - -
<!-- more -->
# Apache Lucene简介
The Apache LuceneTM project develops open-source search software, including:
* Lucene Core, our flagship sub-project, provides Java-based indexing and search technology, as well as spellchecking, hit highlighting and advanced analysis/tokenization capabilities.
* SolrTM  is a high performance search server built using Lucene Core, with XML/HTTP and JSON/Python/Ruby APIs, hit highlighting, faceted search, caching, replication, and a web admin interface.
* PyLucene is a Python port of the Core project.

# Lucene Core简介
Apache LuceneTM is a high-performance, full-featured text search engine library written entirely in Java. It is a technology suitable for nearly any application that requires full-text search, especially cross-platform.

# Lucene Features
## 可扩展、高性能索引
* over 150GB/hour on modern hardware
* small RAM requirements -- only 1MB heap
* incremental indexing as fast as batch indexing
* index size roughly 20-30% the size of text indexed

## 强大、精准、高效的检索算法
* ranked searching -- best results returned first
* many powerful query types: phrase queries, wildcard queries, proximity queries, range queries and more
* fielded searching (e.g. title, author, contents)
* sorting by any field
* multiple-index searching with merged results
* allows simultaneous update and searching
* flexible faceting, highlighting, joins and result grouping
* fast, memory-efficient and typo-tolerant suggesters
* pluggable ranking models, including the Vector Space Model and Okapi BM25
* configurable storage engine (codecs)

## 跨平台的解决方案
* Available as Open Source software under the Apache License which lets you use Lucene in both commercial and Open Source programs
* 100%-pure Java
* Implementations in other programming languages available that are index-compatible

# Lucene的总体架构
http://www.cnblogs.com/forfuture1978/archive/2009/12/14/1623596.html


# Lucene索引结构
Lucene的索引结构是有层次结构的，主要分以下几个层次：
## 索引(Index)
在Lucene中一个索引是放在一个文件夹中的，同一文件夹中的所有的文件构成一个Lucene索引。
## 段(Segment)
一个索引可以包含多个段，段与段之间是独立的，添加新文档可以生成新的段，不同的段可以合并。
具有相同前缀文件的属同一个段，segments.gen和segments_5是段的元数据文件，也即它们保存了段的属性信息。

## 文档(Document)
`A document is a sequence of fields. `
文档是我们建索引的基本单位，不同的文档是保存在不同的段中的，一个段可以包含多篇文档。
新添加的文档是单独保存在一个新生成的段中，随着段的合并，不同的文档合并到同一个段中。
## 域(Field)
`A field is a named sequence of terms.  `
一篇文档包含不同类型的信息，可以分开索引，比如标题，时间，正文，作者等，都可以保存在不同的域里（不同域的索引方式可以不同）。

### Field类型
* field的text以文本形式存储在index中，field倒排后即为index，也可配置为只存储不建index；    
Field.Store.* field存储选项通过倒排序索引来控制文本是否可以搜索；
* field的text看分词为term后建立index，或者field的text直接以原始文本作为term存储为index；大多数field是分词后建立索引的，但有时候指定一些identifier field只存储原始文本是很有用的；  
Field.Index.*  field索引选项确定是否要存储域的真实值；

## 词元(Term)
`A term is a string. `
词元是索引的最小单位，是经过词法分析和语言处理后的字符串。
在不同field中的相同字符串是不同的term，因此term表示一对字符串，第一个用以命名field，第二个用以命名field中的text；
文档是Lucene搜索和索引的原子单位，文档为包含一个或者多个域的容器，而域则是依次包含“真正的”被搜索的内容，域值通过分词技术处理，得到多个词元。

# 索引可视化工具
[Luke](https://github.com/DmitryKey/luke)

# 倒排/反向索引（[Inverted Indexing](https://zh.wikipedia.org/wiki/倒排索引)）
定义：存储在全文搜索下某个单词在一个文档或者一组文档中的存储位置的映射
为了使得基于term的检索更高效，index中存储了term的统计数据；lucene的索引在索引家族中被称为倒排/反向索引，这是因为它能列出所有包含某个term的document，而这与根据document列出terms的自然联系是倒置的

## Lucene索引中的正向信息
正向信息按层次保存了从index一直到term的包含关系：`索引(Index) –> 段(segment) –> 文档(Document) –> 域(Field) –> 词(Term)`
也即此索引包含了那些段，每个段包含了那些文档，每个文档包含了那些域，每个域包含了那些词。既然是层次结构，则每个层次都保存了本层次的信息以及下一层次的元信息，也即属性信息。
包含正向信息的文件有：
* segments_N保存了此索引包含多少个段，每个段包含多少篇文档。
* XXX.fnm保存了此段包含了多少个域，每个域的名称及索引方式。
* XXX.fdx，XXX.fdt保存了此段包含的所有文档，每篇文档包含了多少域，每个域保存了那些信息。
* XXX.tvx，XXX.tvd，XXX.tvf保存了此段包含多少文档，每篇文档包含了多少域，每个域包含了多少词，每个词的字符串，位置等信息。

示例：如一本介绍中国地理的书，应该首先介绍中国地理的概况，以及中国包含多少个省，每个省介绍本省的基本概况及包含多少个市，每个市介绍本市的基本概况及包含多少个县，每个县具体介绍每个县的具体情况。

## Lucene索引中的反向信息
反向信息保存了词典到倒排表的映射：`词(Term) –> 文档(Document)`
包含反向信息的文件有：
* XXX.tis，XXX.tii保存了词典(Term Dictionary)，也即此段包含的所有的词按字典顺序的排序。
* XXX.frq保存了倒排表，也即包含每个词的文档ID列表。
* XXX.prx保存了倒排表中每个词在包含此词的文档中的位置。

## 倒排索引的应用
* 反向索引数据结构是典型的搜索引擎检索算法重要的部分。
* 一个搜索引擎执行的目标就是优化查询的速度：找到某个单词在文档中出现的地方。以前，正向索引开发出来用来存储每个文档的单词的列表，接着掉头来开发了一种反向索引。 正向索引的查询往往满足每个文档有序频繁的全文查询和每个单词在校验文档中的验证这样的查询。
* 实际上，时间、内存、处理器等等资源的限制，技术上正向索引是不能实现的。
* 为了替代正向索引的每个文档的单词列表，能列出每个查询的单词所有所在文档的列表的反向索引数据结构开发了出来。
* 随着反向索引的创建，如今的查询能通过立即的单词标示迅速获取结果（经过随机存储）。随机存储也通常被认为快于顺序存储。

# Lucene索引文件的基本类型
Lucene索引文件中，用一下基本类型来保存信息：  
* Byte：是最基本的类型，长8位(bit)。
* UInt32：由4个Byte组成。
* UInt64：由8个Byte组成。
* VInt：变长的整数类型，它可能包含多个Byte，对于每个Byte的8位，其中后7位表示数值，最高1位表示是否还有另一个Byte，0表示没有，1表示有。
越前面的Byte表示数值的低位，越后面的Byte表示数值的高位。
例如130化为二进制为 1000, 0010，总共需要8位，一个Byte表示不了，因而需要两个Byte来表示，第一个Byte表示后7位，并且在最高位置1来表示后面还有一个Byte，所以为(1) 0000010，第二个Byte表示第8位，并且最高位置0来表示后面没有其他的Byte了，所以为(0) 0000001。
* Chars：是UTF-8编码的一系列Byte。
* String：一个字符串首先是一个VInt来表示此字符串包含的字符的个数，接着便是UTF-8编码的字符序列Chars。

# Lucene索引存储的基本规则
Lucene为了使的信息的存储占用的空间更小，访问速度更快，采取了一些特殊的技巧.
## 前缀后缀规则(Prefix+Suffix)
Lucene在反向索引中，要保存词典(Term Dictionary)的信息，所有的词(Term)在词典中是按照字典顺序进行排列的，然而词典中包含了文档中的几乎所有的词，并且有的词还是非常的长的，这样索引文件会非常的大，所谓前缀后缀规则，即当某个词和前一个词有共同的前缀的时候，后面的词仅仅保存前缀在词中的偏移(offset)，以及除前缀以外的字符串(称为后缀)。
## 差值规则(Delta)
在Lucene的反向索引中，需要保存很多整型数字的信息，比如文档ID号，比如词(Term)在文档中的位置等等。
整型数字是以VInt的格式存储的。随着数值的增大，每个数字占用的Byte的个数也逐渐的增多。所谓差值规则(Delta)就是先后保存两个整数的时候，后面的整数仅仅保存和前面整数的差即可。
## 或然跟随规则(A, B?)
Lucene的索引结构中存在这样的情况，某个值A后面可能存在某个值B，也可能不存在，需要一个标志来表示后面是否跟随着B。  
一般的情况下，在A后面放置一个Byte，为0则后面不存在B，为1则后面存在B，或者0则后面存在B，1则后面不存在B。  
## 跳跃表规则(Skip list)
为了提高查找的性能，Lucene在很多地方采取的跳跃表的数据结构。  
跳跃表(Skip List)是如图的一种数据结构，有以下几个基本特征：
* 元素是按顺序排列的，在Lucene中，或是按字典顺序排列，或是按从小到大顺序排列。
* 跳跃是有间隔的(Interval)，也即每次跳跃的元素数，间隔是事先配置好的，如图跳跃表的间隔为3。
* 跳跃表是由层次的(level)，每一层的每隔指定间隔的元素构成上一层，如图跳跃表共有2层。


#  TF-IDF
TF-IDF（term frequency–inverse document frequency）
是一种用于信息检索与数据挖掘的常用加权技术。

# Lucene检索
## TokenStream
TokenStream extends AttributeSource implements Closeable:
incrementToken,end,reset,close
## Tokenizer
Tokenizers perform the task of breaking a string into separate tokens.
Tokenizer直接继承至TokenStream,其输入input是一个reader
## TokenFilter
Token filters act on each token that is generated by a tokenizer and apply some set of operations that alter or normalize them.
TokenFilter也直接继承TokenStream,但input是一个TokenStream。
## TokenStreamComponents
TokenStreamComponents其实是将tokenizer和tokenfilter包装起来的(也可以只是tokenizer,两个成员叫source和sink),可以setReader,getTokenStream方法返回sink。
## Analyzer
[如何自定义Analyzer](http://www.citrine.io/blog/2015/2/14/building-a-custom-analyzer-in-lucene)
Analyzer就是一个TokenStreamComponents的容器，因此需要确定ReuseStrategy,重写createComponents(fieldName,reader)方法,使用时调用tokenStream(fieldName,reader)方法获取TokenStream就可以了。

# Lucene常用组件
lucene-core.jar
lucene-analyzers.jar
