---
title: Netty事件模型
date: 2020-03-22
tags: [Netty,Java]
categories: 后端技术
---

Netty是一款基于NIO（Nonblocking I/O，非阻塞IO）开发的网络通信框架，
我们微服务间通信的RPC框架的底层通信一般基于Netty来实现，
那么为什么选择Netty，Netty底层的服务端和客户端的通信机制的实现原理是什么？

<!-- more -->  

# 关于Netty
Netty是一个`异步事件驱动`的网络应用程序框架，用于快速开发可维护的`高性能协议服务器和客户端。

# Buffer缓冲区
* 缓冲区：在Java NIO中负责`数据的存取`；
* 缓冲区就是字节数组，存储不同类型的数据,根据数据类型不同（Boolean除外），提供相应类型的缓冲区
  * ByteBuffer
  * CharBuffer
  * ShortBuffer
  * InteBuffer
  * LongBuffer
  * FloatBuffer
  * DoubleBuffer

![Buffer_class](Buffer_class.jpg)

## Buffer核心操作方法
* allocate(capacity)：获取缓冲区，分配内存
* put(bytes)：存入数据
* get(dst,offset,len) ：获取数据

## Buffer核心属性
* capacity,容量，表示缓冲区中最大存储数据的容量；
* limit,界限：表示缓冲区可以操作数据的大小；
* position,位置：表示缓存区中正在操作数据的位置；
* mark,标记：记录当前position的位置，可以通过reset()恢复到mark的位置；

0<=mark<=position<=limit<=capacity

## 直接缓冲区和非直接缓冲区
### 非直接缓冲区
![NonDirectBuffer](NonDirectBuffer.jpg)
* NIO通过通道连接磁盘文件与应用程序，通过缓冲区存取数据进行双向的数据传输。
* 物理磁盘的存取是操作系统进行管理的，与物理磁盘的数据操作需要经过内核地址空间；而我们的Java应用程序是通过JVM分配的缓冲空间。
* 数据需要在`内核地址空间`和`用户地址空间`，在`操作系统`和`JVM`之间进行数据的来回`拷贝`，无形中增加的中间环节使得效率与后面要提的直接缓冲区相比偏低。
* 非直接缓冲区通过`allocate()`方法分配缓冲区，将缓冲区分配在JVM内存的`byte[]`中；

### 直接缓冲区
![DirectBuffer](DirectBuffer.jpg)
* 直接缓冲区则不再通过`内核地址空间`和`用户地址空间`的缓存数据的`复制传递`，而是在`物理内存`中申请了一块空间，这块空间`映射`到内核地址空间和用户地址空间；
* 应用程序与磁盘之间的数据存取之间通过这块直接申请的物理内存进行；
* 直接缓冲区通过`allocateDirect()`方法分配直接缓冲区，将缓冲区建立在操作系统内存中（`通过Unsafe.allocateMemory(size)`分配内存），即`直接内存`;

#### 直接缓冲区的优点
性能更高、效率更快。
直接缓冲区可以通过FileChannel的map()方法将文件区域直接映射到内存中来创建，避免了在操作系统IO缓冲区和JVM的IO缓冲区之间的双向copy的成本；

#### 直接缓冲区的缺点
1. 不安全；
2. 消耗更多，因为它不是在JVM中直接开辟空间。这部分内存的回收只能依赖于垃圾回收机制，垃圾什么时候回收不受我们控制；
3. 数据写入物理内存缓冲区中，程序就失去了对这些数据的管理，即什么时候这些数据被最终写入从磁盘只能由操作系统来决定，应用程序无法再干涉。

>建议将直接缓冲区分配给那些易受操作系统I/O影响的`大型、持久的缓冲区`，在直接缓冲区能在程序性能方面带来明显好处时分配他们；

# Channel通道
* Channel由java.nio.channels包定义；
* Channel表示`IO源`与`目标`打开的`连接`，在Java NIO中负责缓冲区中`数据的传输`，类似于传统的'流'；
* Channel不能直接访问数据，只能与Buffer进行交互；

## Channel的主要实现类
java.io.channels.Channels接口，常用的有
* FileChannel：file
* SocketChannel：tcp
* ServerSocketChannel：tcp
* DatagramChannel：udp

![Channel_class](Channel_class.jpg)

## 获取通道的方法
1. 针对支持通道的类提供了`getChannel()`方法
   * 本地IO操作
     * FileInputStream/FileOutputStream；
     * RandomAccessFile

   * 网络IO操作
     * Socket
     * ServerSocket
     * DatagramSocket
2. JDK1.7中的NIO.2针对各个通道提供了一个open()方法获取通道；
3. JDK1.7中的NIO.2的File工具类的newByteChannel()获取通道；

## 通道之间的数据传输
1. 非直接缓冲区：读取Channel进行复制（速度和缓冲区大小相关）；
2. 利用直接缓冲区复制文件：以MappedByteBuffer进行复制；
3. 通道之间的数据传输：Channel的transferTo或transferFrom进行复制；
4. File辅助类：调用操作系统接口进行复制（性能最优）；

具体实现代码见文件复制的单元测试代码[TestChannel.java]()

## 

# Netty的事件模型

# 参考

* [美图技术团队-Spark从入门到精通](https://mp.weixin.qq.com/s?__biz=MzU5ODU5MjM2Mw==&mid=2247484147&idx=2&sn=cca8dc960db221fb920bfb545d357ad9&chksm=fe409cf7c93715e1a2f76400f33e7b1e43b74d104bb73e2df5c2d66334708f2ab44affb32348&mpshare=1&scene=1&srcid=0312255FDjhwPrXrFblNbRjY&sharer_sharetime=1583976445311&sharer_shareid=c34b9250c3b65723d4a3c176ade2782f#rd)

