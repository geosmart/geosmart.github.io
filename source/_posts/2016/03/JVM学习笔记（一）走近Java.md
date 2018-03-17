title: JVM学习笔记（一）走近Java
date: 2016-02-22 20:23:37
tags: [Java,JVM]
categories: [读书笔记]
---

2016上半年花点时间深入了解JVM，读《《深入理解Java虚拟机 JVM高级特性与最佳实践》，整理遇到过的内存泄漏，性能优化问题
- - -
<!-- more -->

# 第一章 走近Java

## Java技术体系

![JDK](JDK技术组成.png)

- Java程序设计语言、Java虚拟机、Java API类库三部分统称为JDK(Java Development Kit) ,JDK是Java程序开发的最小环境
- Java API类库中的Java SE API子集和Java虚拟机两部分统称为JRE(Java Runtime Environment)，JRE是支持Java程序运行的标准环境
- 按照Java技术关注的重点业务领域来划分，Java技术体系可分为4个平台

  - Java Card：支持Applets(Java小程序)运行在小内存设备（如智能卡）上的平台；
  - Java ME(Micro Edition)：支持Java运行在移动终端上的平台；（今有Android SDK）
  - Java SE(Standard Edition)：支持面向桌面级应用的Java平台；
  - Java EE(Enterprise Edition)：支持使用多层架构的企业级应用(如ERP、CRM应用)的Java平台；

## Java发展史

## Java虚拟机发展史

- Sun Classic/Extract VM
- Sun HotSpot VM
- Sun Mobile-Embedded VM/Meta-Circular VM
- Bea Jrockit/IDM J9 VM
- Azul VM/BEA Liquid VM
- Apache Harmony/Google Android Dalvik VM
- Microsoft JVM...

## Java技术的未来展望

- 模块化（Jigsaw）
- 混合语言：多语言混合编程，通过特定领域发语言去解决特定领域的问题
- 多核并行（concurrent.forkjoin；Lambada；函数式编程）
- 丰富语法（Coin子项目）
- 64位虚拟机（计算机终究完全过渡到64位的时代）

## JDK编译实战

[OpenJDK7下载](https://jdk7.java.net/source.html) Building the source code for the OpenJDK requires a certain degree of technical expertise.
