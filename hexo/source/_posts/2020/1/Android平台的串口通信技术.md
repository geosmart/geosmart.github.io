---
title: Android平台的串口通信技术
date: 2020-01-02
tags: [Android]
categories: [移动端]
---

安卓开发中的串口通信技术
<!-- more --> 
![串口](安卓串口通信.png)

# 概念
## 串口通信
* 概念；串口通信（Serial Communications）按位（bit）发送和接收字节。串口可以在使用一根线（Tx）发送数据的同时用另一根线（Rx）接收数据。
* 实现：通过打开JNI的调用，打开串口。获取串口通信中的输入输出流，通过操作IO流，达到能够利用串口接收数据和发送数据的目的

## 名词解释
```java
//打开串口
private native FileDescriptor open(String absolutePath, int baudrate, int dataBits, int parity, int stopBits, int flags);
```
* absolutePath：串口的物理地址，一般硬件工程师都会告诉你的例如ttyS0、ttyS1等，或者通过SerialPortFinder类获取可用的串口地址。
* baudrate：串口传输速率，一个设备在一秒钟内发送（或接收）了多少码元的数据，用来衡量数据传输的快慢，
  * 即单位时间内载波参数变化的次数，如每秒钟传送240个字符，而每个字符格式包含10位（1个起始位，1个停止位，8个数据位），这时的波特率为240Bd，比特率为10位*240个/秒=2400bps。
  * 波特率与距离成反比，波特率越大传输距离相应的就越短。 
* dataBits：数据位长度，标准的值是6、7和8位。
* parity：奇偶校验位，在串口通信中一种简单的检错方式，0-不校验，1-奇校验，2-偶校验
  * 对于偶和奇校验的情况，串口会设置校验位（数据位后面的一位），用一个值确保传输的数据有偶个或者奇个逻辑高位。
* stopBits：停止位，用于表示单个包的最后一位。标准的值为1或2位。
  * 由于数据是在传输线上定时的，并且每一个设备有其自己的时钟，很可能在通信中两台设备间出现了小小的不同步。
* 因此停止位不仅仅是表示传输的结束，并且提供计算机校正时钟同步的机会。
* 适用于停止位的位数越多，不同时钟同步的容忍程度越大，但是数据传输率同时也越慢。
* flags：默认为0，表示可读可写，flags可通过与默认的O_RDWR（可读可写）进行位或计算来设置串口模式
  * fd = open(path_utf, O_RDWR | flags);

##  串口文件打开模式
* O_RDONLY：以只读方式打开文件
* O_WRONLY：以只写方式打开文件
* O_RDWR：以读写方式打开文件
* O_APPEND：写入数据时添加到文件末尾
* O_CREATE：如果文件不存在则产生该文件，使用该标志需要设置访问权限位mode_t
* O_EXCL：指定该标志，并且指定了O_CREATE标志，如果打开的文件存在则会产生一个错误
* O_TRUNC：如果文件存在并且成功以写或者只写方式打开，则清除文件所有内容，使得文件长度变为0
* O_NOCTTY：如果打开的是一个终端设备，这个程序不会成为对应这个端口的控制终端，如果没有该标志，任何一个输入，例如键盘中止信号等，都将影响进程。
* O_NONBLOCK：该标志与早期使用的O_NDELAY标志作用差不多。程序不关心DCD信号线的状态，如果指定该标志，进程将一直在休眠状态，直到DCD信号线为0。

>实际应用中，都会选择阻塞模式，这样更节省资源。但是如果希望在一个线程中同时进行读写操作，没数据反馈时，线程就会阻塞等待，就无法进行写数据了。

## 串口地址
如下表不同操作系统的串口地址，Android是基于Linux的所以一般情况下使用Android系统的设备串口地址为/dev/ttyS0...

System | Port 1 | Port 2
-- | -- | --
IRIX® | /dev/ttyf1 | /dev/ttyf2
HP-UX | /dev/tty1p0 | /dev/tty2p0
Solaris®/SunOS® | /dev/ttya | /dev/ttyb
Linux® | /dev/ttyS0 | /dev/ttyS1
Digital UNIX® | /dev/tty01 | /dev/tty02

# 工具
* Android移植谷歌官方串口库支持校验位、数据位、停止位、流控配置：https://juejin.im/post/5c010a19e51d456ac27b40fc
* windows友善串口调试工具: http://www.darkwood.me/serialport/
* Google开源的Android串口通信Demo：https://github.com/licheedev/Android-SerialPort-API

