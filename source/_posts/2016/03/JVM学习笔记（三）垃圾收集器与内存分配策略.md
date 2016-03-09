title: JVM学习笔记（三）垃圾收集器与内存分配策略
date: 2016-03-09 21:07:52
tags: [Java,JVM]
categories: [读书笔记]
---
Java与C++之间有一睹由内存动态分配和垃圾收集技术所围成的“高墙”，墙外面的人想进去，墙里面的人想出来。
- - -
<!-- more -->

# 概述
---
# 对象已死吗？
## 引用计数算法
## 可达性分析算法
## 再谈引用
## 生存还是死亡
## 回收方法区
---
# 垃圾收集算法
## 标记-清除算法（Mak-Sweep）
## 复制算法（Coping）
## 标记-整理算法（Mark-Compact）
## 分代收集算法
---
# HotSpot的算法实现
## 枚举根基点
## 安全点
## 安全区域
---
# 垃圾收集器
## Serial收集器
## ParNew收集器（Parallel New）
## Parallel Scavenge收集器
## Serial Old收集器
## Parallel Old收集器
## CMS收集器（Concurrent Mark Sweep）
## G1收集器（Garbage-First）
## 理解GC日志
## 垃圾收集器参数总结
---
# 内存分配与回收策略
## 对象优先在Eden分配
## 大对象直接进入老年代
## 长期存活的对象将进入老年代
## 动态对象年龄判定
## 空间分配担保
