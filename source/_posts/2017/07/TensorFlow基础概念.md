---
title: TensorFlow基础概念
date: 2017-07-03 20:41:50
tags: [TensorFlow]
categories: 人工智能
---

TensorFlow最重要的两个概念-Tensor和Flow；  
Tensor就是张量，可简单理解为多维数组；  
Flow直观表达Tensor之间通过计算相互转换的过程；  
TensorFlow是一个通过计算图的形式来表述计算的编程系统。TensorFlow中的每个计算都是计算图上的一个节点，而节点之间的边描述了计算之间的依赖关系。

- - -
<!-- more --> 

# TensorFlow的计算模型-计算图
## 常用函数
* tf.get_default_grapph()：获取当前默认计算图；
* tf.Graph()：生成新的计算图；
* tf.Graph.device('device')：指定运行计算的设备；

# TensorFlow的数据模型-张量
TensorFlow中所有运算的输入、输出都是张量（Tensor）。张量本身并不存储任何数据，它是对运算结果的引用。Tensor可简单理解为多维数组； 
* 零阶张量-标量（scalar）
* 第一阶张量-向量（vector）
* 第n阶张量（n维数组）

TensorFlow中的每一个计算是计算图上的一个节点，而节点之间的边描述了计算之间的依赖关系；
不同计算图中的张量和运算都不会共享；

## 张量的数据结构
示例：Tensor( "add:0" , shape=(2,) , dtype=float32 )
### 名字（name）
node:src_output
### 维度（shape）
### 类型（type）
* 实数（tf.float32、tf.float64）
* 整数（tf.int8、tf.int16、tf.int32、tf.int64、tf.uint8）
* 布尔型（tf.bool）
* 复数（tf.complex64、tf.complex128） 

## 张量的使用
通过Tensor可更好的组织TensorFlow程序
* 对中间结果的引用，提供代码可读性
* 当计算图构造完成后，通过张量获取计算结果

# TensorFlow的运算模型-会话（session）

## session的使用模式
### 明确调用会话生成函数和关闭会话函数
```python
session=tf.Session()
sess.run(...)
sess.close()
```
### Python上下文管理器管理会话
将所有计算放在with内部
```python
with tf.Session() as sess
    sess.run(...)
```
优点：  
* 解决异常退出时资源释放问题，
* 解决忘记调用Session.close函数而产生的资源泄露问题；


### 默认会话
* 手动指定session为默认会话
* 交互式环境以tf.InteractiveSession配置会话

## ConfigProto配置会话
### 常用参数
* allow_soft_placement（bool）：当运算无法被当前GPU支持时，可以自动切换到CPU上；
* log_device_placemnet（bool）：日志中将会记录每个节点被安排在那个设备上以方便调试。

### ConfigProto可配参数
* 并行线程数
* GPU分配策略
* 运算超时时间
