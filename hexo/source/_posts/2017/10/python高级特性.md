---
title: python高级特性
date: 2017-10-05
tags: [python]
categories: 后端技术
---

python高级特性之GIL全局解释锁，concurrent多线程

- - -
<!-- more --> 

python高级特性
---

# concurrent任务并发
>The concurrent.futures module provides a high-level interface for asynchronously executing callables.
The asynchronous execution can be performed with threads, using `ThreadPoolExecutor`, or separate processes, using `ProcessPoolExecutor`. Both implement the same interface, which is defined by the abstract Executor class.


# GIL 全局解释器锁
## 什么是全局解释器锁GIL
Python代码的执行由Python 虚拟机(也叫解释器主循环，CPython版本)来控制，Python 在设计之初就考虑到要在解释器的主循环中，同时只有一个线程在执行，即在任意时刻，只有一个线程在解释器中运行。对Python 虚拟机的访问由全局解释器锁（GIL）来控制，正是这个锁能保证`同一时刻只有一个线程在运行`。
在多线程环境中，Python 虚拟机按以下方式执行：
1. 设置GIL
2. 切换到一个线程去运行
3. 运行：
	* 指定数量的字节码指令，或者
	* 线程主动让出控制（可以调用time.sleep(0)）
4. 把线程设置为睡眠状态
5. 解锁GIL
6. 再次重复以上所有步骤 

在调用外部代码（如C/C++扩展函数）的时候，GIL 将会被锁定，直到这个函数结束为止（由于在这期间没有Python 的字节码被运行，所以不会做线程切换）。
## 全局解释器锁GIL设计理念与限制
GIL的设计简化了CPython的实现，使得对象模型，包括关键的内建类型如字典，都是隐含可以并发访问的。锁住全局解释器使得比较容易的实现对多线程的支持，但也损失了多处理器主机的并行计算能力。
但是，不论标准的，还是第三方的扩展模块，都被设计成在进行密集计算任务是，释放GIL。
还有，就是在做I/O操作时，GIL总是会被释放。对所有面向I/O 的(会调用内建的操作系统C 代码的)程序来说，GIL 会在这个I/O 调用之前被释放，以允许其它的线程在这个线程等待I/O 的时候运行。如果是纯计算的程序，没有 I/O 操作，解释器会每隔 100 次操作就释放这把锁，让别的线程有机会执行（这个次数可以通过 sys.setcheckinterval 来调整）如果某线程并未使用很多I/O 操作，它会在自己的时间片内一直占用处理器（和GIL）。也就是说，I/O 密集型的Python 程序比计算密集型的程序更能充分利用多线程环境的好处。



# 参考
[python 线程，GIL 和 ctypes](http://zhuoqiang.me/python-thread-gil-and-ctypes.html)
[concurrent.futures — Launching parallel tasksï¿½](https://docs.python.org/3/library/concurrent.futures.html)
