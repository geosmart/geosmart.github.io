---
title: Kafka学习笔记
date: 2017-10-09
tags: [Kafka]
categories: 中间件
---
Kafka is used for building `real-time` data pipelines and streaming apps. It is `horizontally scalable`, `fault-tolerant`, `wicked fast`, and runs in production in thousands of companies.
- - -
<!-- more --> 

Kafka学习笔记
---

# 关于消息中间件
>什么是消息中间件？

举个生产者/消费者的例子，生产者生产鸡蛋，消费者消费鸡蛋，生产者生产一个鸡蛋，消费者就消费一个鸡蛋。
* 假设消费者消费鸡蛋的时候噎住了（系统宕机了），生产者还在生产鸡蛋，那新生产的鸡蛋就丢失了。
* 再比如生产者很强劲（大交易量的情况），生产者1秒钟生产100个鸡蛋，消费者1秒钟只能吃50个鸡蛋，那要不了一会，消费者就吃不消了（消息堵塞，最终导致系统超时），消费者拒绝再吃了，”鸡蛋“又丢失了，
* 这个时候我们放个篮子在它们中间，生产出来的鸡蛋都放到篮子里，消费者去篮子里拿鸡蛋，这样鸡蛋就不会丢失了，都在篮子里
* 而这个篮子就是”kafka“。鸡蛋其实就是“数据流”，系统之间的交互都是通过“数据流”来传输的（就是tcp、http什么的），也称为报文，也叫“消息”。消息队列满了，其实就是篮子满了，”鸡蛋“ 放不下了，那赶紧多放几个篮子，其实就是kafka的扩容。
kafka是干什么的，它就是那个"篮子"。

# Kafka简介

![Alt text](Alt text.png)
Apache Kafka是由Apache软件基金会开发的一个开源消息系统项目，由Scala写成。Kafka最初是由LinkedIn开发，并于2011年初开源。
Kafka是一个分布式、分区的、多副本的、多订阅者，基于zookeeper协调的分布式日志系统(也可以当做MQ系统)，常见可以用于web/nginx日志、访问日志，消息服务等等，Linkedin于2010年贡献给了Apache基金会并成为顶级开源项目。

* 快速：单个kafka服务每秒可以处理数以千计从客户端发来的几百兆字节的读取和写入。
* 可扩展性：kafka被设计为允许单个集群作为中央数据骨干大型组织。它可以弹性地，透明地扩展，无需停机。数据流被划分并分布在机器的集群中，允许数据流比任何单一机器的性能大，并让集群来协调消费者。
* 可靠性：消息被保存在磁盘上,并在集群中复制，防止数据丢失。每个代理可以处理TB级的消息，而不影响性能。
* 分布式设计：kafka使用现代化的集群为中心设计，并提供了强大的耐用性和容错性保证。

# kafka名词解释
后面大家会看到一些关于kafka的名词，比如topic、producer、consumer、broker，我这边来简单说明一下。
* `topic`：Kafka将消息种子(Feed)分门别类， 每一类的消息称之为话题(Topic)。例如page view日志、click日志等都可以以topic的形式存在，Kafka集群能够同时负责多个topic的分发；
* `partion`：topic物理上的分组，一个topic可以分为多个partion，每个partion是一个有序的队列；
* `segment`：partion物理上由多个segment组成；
* `offset`：每个partion都由一系列有序的、不可变的消息组成，这些消息被连续的追加到partion中。每个partion中的每个消息都由一个连续的序列化叫做offset，由于partion唯一标识一条消息；
* `producer`： 发布消息的对象称之为话题生产者(Kafka topic producer)；
* `consumer`：订阅消息并处理发布的消息的Feed的对象称之为话题消费者(consumers)消费者；
* `broker`： 消息中间件处理节点，一个Kafka节点就是一个Broker，多个Broker可以组成一个Kafka集群；


Client和Server之间的通讯是通过一条简单、高能并且和开发语言无关的TCP协议。
除了Java Client外，还有非常多的其它编程语言的Client。

# Kafka的保证(Guarantees)
生产者发送到一个特定的Topic的分区上的消息将会按照它们发送的顺序依次加入
消费者收到的消息也是此顺序
如果一个Topic配置了复制因子( replication facto)为N， 那么可以允许N-1服务器宕机而不丢失任何已经增加的消息
# Kafka的文件存储机制
一个商业化消息队列的好坏，其文件存储机制是衡量一个消息队列服务技术水平的最关键指标之一。
## topic中partion存储分布
在Kafka文件存储中，同一个topic下有多个不同partition，每个partition为一个目录，
partiton命名规则为topic名称+有序序号，第一个partiton序号从0开始，序号最大值为partitions数量减1。
## partion中文件存储方式
* 每个partion(目录)相当于一个巨型文件被平均分配到多个`大小相等segment`(段)数据文件中。但每个段segment file消息数量不一定相等，这种特性方便old segment file快速被删除。
* 每个partiton只需要支持顺序读写就行了，segment文件生命周期由服务端配置参数决定。
这样做的好处就是能快速删除无用文件，有效提高磁盘利用率。
## partion中segment文件存储结构
* segment file组成：由2大部分组成，分别为index file和data file，此2个文件一一对应，成对出现，后缀”.index”和“.log”分别表示为segment索引文件、数据文件.
* segment文件命名规则：partion全局的第一个segment从0开始，后续每个segment文件名为上一个segment文件最后一条消息的offset值。数值最大为64位long大小，19位数字字符长度，没有数字用0填充。
* 索引文件存储大量元数据，数据文件存储大量消息，索引文件中元数据指向对应数据文件中message的物理偏移地址。

message物理结构参数说明：

| 关键字|     解释说明  |
| :-------- |:-------- |
| 8 byte offset|在parition(分区)内的每条消息都有一个有序的id号，这个id号被称为偏移(offset),它可以唯一确定每条消息在parition(分区)内的位置。即offset表示partiion的第多少message			  |
| 4 byte message size    |	message大小		  |
| 4 byte CRC32    |	用crc32校验message		  |
| 1 byte “magic”|	表示本次发布Kafka服务程序协议版本号		  |
| 1 byte “attributes”| 表示为独立版本、或标识压缩类型、或编码类型。	  |
| 4 byte key length|表示key的长度,当key为-1时，K byte key字段不填			  |
| K byte key|	可选		  |
| value bytes payload|	表示实际消息数据		  |

## 在partion中如何通过offset找到message
![Alt text](Alt text.png)
![Alt text](Alt text.png)
例如读取offset=368776的message，需要通过下面2个步骤查找。
* 第一步查找segment file，其中00000000000000000000.index表示最开始的文件，起始偏移量(offset)为0.第二个文件00000000000000368769.index的消息量起始偏移量为368770 = 368769 + 1.同样，第三个文件00000000000000737337.index的起始偏移量为737338=737337 + 1，其他后续文件依次类推，以起始偏移量命名并排序这些文件，只要根据offset **二分查找**文件列表，就可以快速定位到具体文件。 当offset=368776时定位到00000000000000368769.index|log
* 第二步通过segment file查找message 通过第一步定位到segment file，当offset=368776时，依次定位到00000000000000368769.index的元数据物理位置和00000000000000368769.log的物理偏移地址，然后再通过00000000000000368769.log顺序查找直到offset=368776为止。

从上图可知这样做的优点，segment index file采取稀疏索引存储方式，它减少索引文件大小，通过mmap可以直接内存操作，稀疏索引为数据文件的每个对应message设置一个元数据指针,它比稠密索引节省了更多的存储空间，但查找起来需要消耗更多的时间。

## Kafka中读写message特点
### 写message
* 消息从java堆转入page cache(即物理内存)。
* 由异步线程刷盘,消息从page cache刷入磁盘。
### 读message
* 消息直接从page cache转入socket发送出去。
* 当从page cache没有找到相应数据时，此时会产生磁盘IO,从磁盘Load消息到page cache，然后直接从socket发出去；

## Kafka高效文件存储设计特点
* Kafka把topic中一个parition大文件分成多个小文件段，通过多个小文件段，就容易定期清除或删除已经消费完文件，减少磁盘占用。
* 通过索引信息可以快速定位message和确定response的最大大小。
* 通过index元数据全部映射到memory，可以避免segment file的IO磁盘操作。
* 通过索引文件稀疏存储，可以大幅降低index文件元数据占用空间大小。

# Kafka常见问题
* kafka节点之间如何复制备份的？
* kafka消息是否会丢失？为什么？
* kafka最合理的配置是什么？
* kafka的leader选举机制是什么？
* kafka对硬件的配置有什么要求？
* kafka的消息保证有几种方式？

# 参考
* [kafka中文教程](http://www.orchome.com/kafka/index)
* [enter link description here](http://blog.csdn.net/suifeng3051/article/details/48053965)