title: Python并行编程笔记
date: 2016-01-23 18:51:43
tags: [Python,并行]
categories: [脚本工具]
---

大数据时代，并发/并行是不变的话题，以并行计算来提高程序运行效率，可充分利用硬件资源（CPU，内存，磁盘/网络IO）。Python作为脚本语言，解释器简洁轻量，软件研发后无需编译且更新部署方便，对于实现一些类似爬取的工具简直不要太友好。

- - -
<!-- more -->

# 关于多进程问题
http://blog.tankywoo.com/2015/09/06/cant-pickle-instancemethod.html
如果你的代码是CPU密集型，多个线程的代码很有可能是线性执行的。所以这种情况下多线程是鸡肋，效率可能还不如单线程因为有context switch,
如果你的代码是IO密集型，多线程可以明显提高效率。例如制作爬虫（我就不明白为什么Python总和爬虫联系在一起…不过也只想起来这个例子…），绝大多数时间爬虫是在等待socket返回数据。这个时候C代码里是有release GIL的，最终结果是某个线程等待IO的时候其他线程可以继续执行。

# python线程
## python协程
协程，又称微线程，纤程。英文名Coroutine。
最大的优势就是协程极高的执行效率。因为子程序切换不是线程切换，而是由程序自身控制，因此，没有线程切换的开销，和多线程比，线程数量越多，协程的性能优势就越明显。
第二大优势就是不需要多线程的锁机制，因为只有一个线程，也不存在同时写变量冲突，在协程中控制共享资源不加锁，只需要判断状态就好了，所以执行效率比多线程高很多。
因为协程是一个线程执行，那怎么利用多核CPU呢？最简单的方法是多进程+协程，既充分利用多核，又充分发挥协程的高效率，可获得极高的性能。
Python对协程的支持还非常有限，用在generator中的yield可以一定程度上实现协程。虽然支持不完全，但已经可以发挥相当大的威力了。

## threading

## 生产者-消费者模型

# python多线程
## monkey.patch
monkey patch指的是在运行时动态替换,一般是在startup的时候.
用过gevent就会知道,会在最开头的地方gevent.monkey.patch_all();把标准库中的thread/socket等给替换掉.这样我们在后面使用socket的时候可以跟平常一样使用,无需修改任何代码,但是它变成非阻塞的了.
之前做的一个游戏服务器,很多地方用的import json,后来发现ujson比自带json快了N倍,于是问题来了,难道几十个文件要一个个把import json改成import ujson as json吗?
其实只需要在进程startup的地方monkey patch就行了.是影响整个进程空间的.
同一进程空间中一个module只会被运行一次.

## gevent
gevent 并发实现：
from gevent import monkey; monkey.patch_socket()

# python多进程
## multiprocessing
One can create a pool of processes which will carry out tasks submitted to it with the Pool class.
参考：http://www.davidmoodie.com/python-multiprocessing-fbalbumdownloader/

注意：multiprocessing与gevent同时使用时，如果运行了gevent.monkey.patch_thread()或patch_all(),pool进程池将无效
