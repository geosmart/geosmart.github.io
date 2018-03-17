---
title: 机器学习基础概念
date: 2017-07-11 09:07:02
tags: [Machine Leaning]
categories: 人工智能
---

监督学习、非监督学习、神经网络......
<!-- more --> 

# 监督学习

## 分类问题和回归问题
分类问题希望解决的是将不同的样本分到事先定义好的类别中；

* 分类（Classification）和回归（Regression）的区别在于输出变量的类型。
* 定量输出称为回归，或者说是连续变量（continous）预测；
* 定性输出称为分类，或者说是离散变量（discrete）预测。

> 对Regression回归一词的理解  
出自高尔顿种豆子的实验，通过大量数据统计，他发现个体小的豆子往往倾向于产生比其更大的子代，而个体大的豆子则倾向于产生比其小的子代，然后高尔顿认为这是由于新个体在向这种豆子的平均尺寸“回归”，大概的意思就是事物总是倾向于朝着某种“平均”发展，也可以说是回归于事物本来的面目。  
C.R.Rao等在Linear Models and Generalizations: Least Squares and Alternatives中解释道：the literature meaning of REGRESSION is " to move in the backward direction"，
看以下两个陈述：  
S1: model generates data or  
S2: data generates model.  
Rao认为很明显陈述S1才是对的，因为模型实际上本来就是存在的，
只不过我们不知道(model exists in nature but is unknown to the experimenter)，先有模型所以我们知道X就能得到Y：  
先有模型 --> 有了X就有Y（S1），而“回归”的意思就是我们通过收集X与Y来确定实际上存在的关系模型：  
收集X与Y --> 确定模型（S2），与S1相比，S2就是一个“回到”模型的过程，所以就叫做“regression”。

# 非监督学习
We can derive this structure by clustering the data based on relationships among the variables in the data.
Clustering：基因分组
Non-clustering: The "Cocktail Party Algorithm",音频分离

# CNN

# RNN
## RNN梯度消散问题

# LSTM

# MLP（Multi Layer Perceptron ）
多层感知器，是一种前向结构的人工神经网络，映射一组输入向量到一组输出向量。MLP可以被看做是一个有向图，由多个节点层组成，每一层全连接到下一层。除了输入节点，每个节点都是一个带有非线性激活函数的神经元（或称处理单元）。一种被称为反向传播算法的监督学习方法常被用来训练MLP。MLP是感知器的推广，克服了感知器不能对线性不可分数据进行识别的弱点。

# CUDA(Compute Unified Device Architecture)
CUDA是显卡厂商NVIDIA推出的运算平台。 CUDA™是一种由NVIDIA推出的通用并行计算架构，该架构使GPU能够解决复杂的计算问题。 它包含了CUDA指令集架构（ISA）以及GPU内部的并行计算引擎。
 开发人员现在可以使用C语言来为CUDA™架构编写程序，C语言是应用最广泛的一种高级编程语言。所编写出的程序于是就可以在支持CUDA™的处理器上以超高性能运行。CUDA3.0已经开始支持C++和FORTRAN。

# State of the art 
对应国内文献里的“研究现状”,当前的最高研究水平。
