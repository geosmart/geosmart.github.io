---
title: RPC中间件
date: 2017-10-06
tags: [RPC]
categories: A3中间件
---

@(A3中间件)[RPC]

- - -
<!-- more --> 

RPC中间件
---

[ ]  想深入的去了解，建议去阅读thrift源代码，很不错的实践代码。

# RPC简介
RPC（Remote Procedure Call）远程过程调用。为了实现分布式系统内，不同服务之间数据交换而产生的东东。他使得服务间的数据访问就像是函数调用一样简单和方便，方便写服务的人能聚焦到业务本身，而不用太关注网络交互、数据格式组织、跨平台等多个方面的问题。

## RPC的意义
* 简化跨机器跨进程的服务调用（简化分布式系统内，不同服务间的数据交换，使得这种交换看起来像本地函数调用一样）；
* 简化代码；
* 可帮助系统实现跨平台跨语言；我们可以根据不同的应用场景，使用不同的语言，来更方便的实现需求。
* 更高效的数据传输。因为RPC封装了数据交换的协议，所以可以在里面极大的优化数据传输的算法，从而压缩数据传输的量

# google的protobuf
IDL：protobuf
Server： netty
传输协议：TCP
数据协议：protobuf

# facebook的thrift
这个相比于protobuf，提供了server和传输协议的支持。
比如，java的实现代码中，就有TThreadPoolServer、TThreadedSelectorServer等多个server模型，便于我们根据业务规模选择不同的模型。
同时，他还提供了TSocket、TSaslTransport、THttpClient等多种传输协议，来实现数据的传输功能。
thrift 集成RPC的四个要素，用起来更简单方便一些。

[使用Spring进行远程访问与Web服务](http://www.shouce.ren/api/spring2.5/ch17.html)
 
# Dubbo
作为阿里开源的分布式服务框架，实现高性能的 RPC 调用同时提供了丰富的管理功能，是一款应用广泛的优秀的 RPC 框架，但现在较少维护更新。是一款高成熟度的服务治理型的RPC框架；
# Motan
作为微博的 Motan RPC 倾向于服务治理型，与 Dubbo 系列相比在功能上或许不是那么全，扩展实现也没有那么多，是一款高性能轻量级易上手的RPC框架；
# gRPC
作为google2015年才开源的跨语言调用型的RPC框架，侧重于服务的跨语言调用，能够支持大部分的语言进行语言无关的调用，非常适合多语言调用场景；

# RMI

# 经验之谈
* 所有需要用到连接外网，调用外部资源（如数据库服务，第三方渠道服务，阿里云存储服务等）的都封装为RPC服务，部署在一台独立的接口机中；其他系统front/backend通过调用rpc服务形式进行通信


