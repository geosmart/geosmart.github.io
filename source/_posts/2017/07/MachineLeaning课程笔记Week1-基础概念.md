---
title: Machine Learning课程笔记Week1-基础概念
date: 2017-07-03 20:44:47
tags: [Machine Leaning]
categories: 人工智能
---

[Coursera斯坦福大学机器学习（Machine Leaning）课程第一周](https://www.coursera.org/learn/machine-learning/home/week/1)课程笔记

>A computer program is said to learn from experience E with respect to some class of tasks T and performance measure P, if its performance at tasks in T, as measured by P, improves with experience E.

“对于某类任务T和性能度量P，如果一个计算机程序在T上以P衡量的性能随着经验E而自我完善，那么我们称这个计算机程序在从经验E学习。”

- - -
<!-- more --> 
# 机器学习定义
机器学习有下面几种定义：
* 机器学习是一门人工智能的科学，该领域的主要研究对象是人工智能，特别是如何在经验学习中改善具体算法的性能。
* 机器学习是对能通过经验自动改进的计算机算法的研究。
* 机器学习是用数据或以往的经验，以此优化计算机程序的性能标准。
>What is Machine Learning?
Two definitions of Machine Learning are offered. Arthur Samuel described it as: "the field of study that gives computers the ability to learn without being explicitly programmed." This is an older, informal definition.    
Tom Mitchell provides a more modern definition: "A computer program is said to learn from experience E with respect to some class of tasks T and performance measure P, if its performance at tasks in T, as measured by P, improves with experience E."  
Example: playing checkers.  
E = the experience of playing many games of checkers  
T = the task of playing checkers.  
P = the probability that the program will win the next game.  
In general, any machine learning problem can be assigned to one of two broad classifications: Supervised learning and Unsupervised learning.

# 监督学习
监督学习从给定的训练数据集中学习出一个函数，当新的数据到来时，可以根据这个函数预测结果。  
监督学习的训练集要求是包括输入和输出，也可以说是特征和目标。训练集中的目标是由人标注的。  

常见的监督学习算法包括回归分析和统计分类。
## 回归分析（连续）
房价预测
## 统计分类（离散）
癌症良恶性判断

>分类（Classification）和回归（Regression）的区别在于输出变量的类型。
定量输出称为回归，或者说是连续变量（continous）预测；
定性输出称为分类，或者说是离散变量（discrete）预测。

# 非监督学习 
We can derive this structure by clustering the data based on relationships among
the variables in the data.

应用场景：
* 市场细分
* 组织计算集群
* 社交网络分析
* 天文数据分析

无监督学习与监督学习相比，训练集没有人为标注的结果。常见的无监督学习算法有聚类。
## 聚类问题
基因数据分组

## 非聚类问题
鸡尾酒会问题（音频分离）

# 原型工具
## matlab
## [octave](https://www.gnu.org/software/octave/doc/interpreter/)
