---
title: Java中的IO模型
date: 2020-03-22
tags: [Netty,Java]
categories: 后端技术
---

Netty是一款基于NIO（Nonblocking I/O，非阻塞IO）开发的网络通信框架，
我们微服务间通信的RPC框架的底层通信一般基于Netty来实现，
那么为什么选择Netty，Netty底层的服务端和客户端的通信机制的实现原理是什么？

<!-- more -->  

# 关于Netty
Netty是一个`异步事件驱动`的网络应用程序框架，用于快速开发可维护的`高性能协议服务器和客户端`。

# Reactor事件模型
## 单Reactor单线程
## 单Reactor多线程
## 主从Reactor多线程

# Netty的Reactor事件模型

# 参考
