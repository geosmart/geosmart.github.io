---
title: Elasticsearch常用API
tags: Elasticsearch
notebook: N02 数据库
date: 2016-07-30 08:52:39
categories: 后端技术
---

 

- - -
<!-- more --> 

/_nodes/ 下有一个监控接口：
curl -XGET 'http://127.0.0.1:9200/_nodes/_local/hot_threads?interval=60s'
该接口会返回在 interval 时长内，该节点消耗资源最多的前三个线程的堆栈情况。这对于性能调优初期，采集现状数据，极为有用。
默认的，资源消耗是按照 CPU 来衡量，还可以用 ?type=wait 或者 ?type=block 来查看在等待和堵塞状态的当前线程排名。

curl -XGET 'http://v3es1:9200/_nodes/v3es1/stats/jvm'
查看：JVM stats, memory pool information, garbage collection, buffer pools, number of loaded/unloaded classes
你看看目前jvm状态如何

如果你的 ES 集群监控里发现经常有很耗时的 GC，说明集群负载很重，内存不足。
严重情况下，这些 GC 导致节点无法正确响应集群之间的 ping ，可能就直接从集群里退出了。
然后数据分片也随之在集群中重新迁移，引发更大的网络和磁盘 IO，正常的写入和搜索也会受到影响。


# 动态修改Replica
curl -XPUT 'localhost:9200/my_index/_settings' -d '
{
    "index" : {
        "number_of_replicas" : 1
    }
}'

# 修改 queue_size
https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-update-settings.html
curl -XPUT  _cluster/settings -d '{
    "persistent" : {
        "threadpool.bulk.queue_size" : 1000
    }
}'

参考：http://jfzhang.blog.51cto.com/1934093/1685530


# ES高频写优化配置
	http://edgeofsanity.net/article/2012/12/26/elasticsearch-for-logging.html