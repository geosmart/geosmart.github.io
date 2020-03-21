title: NLP学习笔记
date: 2015-09-11 21:51:49 
tags: [NLP]
categories: [机器学习]
---

记录一些NLP学习过程中的专业名词

- - -
<!-- more -->

# 专业名词
* NLP(Natural Language Processing)：自然语言处理，主要涉及计算机处理人类语言的数据结构和算法的计算科学。
* Ontology本体：本体是一种描述术语（包含哪些词汇）及术语间关系（描述苹果、香蕉、水果之间的关系）的概念模型。*符号到本体的某种映射*
本体是表达概念之间关系的有效手段，它是共享概念模型的明确的形式化规范说明，它在共享范围内描述了领域中的概念及概念之间的关系，使其具有明确的、形式化的定义,从而实现人机之间以及机器之间的信息交互、知识共享与重用。

* FSM(Finite-state machine)有限状态机：称状态机，是表示有限个状态以及在这些状态之间的转移和动作等行为的数学模型。

* GATE(General Architecture for Text Engineering)文本工程通用框架

* IR(Information Resolve)信息检索

* IE(Information Extract)信息抽取

* HMM(Hidden Markov Models)隐马尔科夫模型：一个隐马尔科夫模型它用来描述一个含有隐含未知参数的马尔可夫过程。其难点是从可观察的参数中确定该过程的隐含参数。然后利用这些参数来作进一步的分析，例如模式识别。  

>由一个向量和两个矩阵(pi,A,B)描述的隐马尔科夫模型对于实际系统有着巨大的价值，虽然经常只是一种近似，但它们却是经得起分析的。隐马尔科夫模型通常解决的问题包括：
1. 对于一个观察序列匹配最可能的系统——评估，使用前向算法（forward algorithm）解决；
2. 对于已生成的一个观察序列，确定最可能的隐藏状态序列——解码，使用Viterbi 算法（Viterbi algorithm）解决；
3. 对于已生成的观察序列，决定最可能的模型参数——学习，使用前向-后向算法（forward-backward algorithm）解决。
[HMM扩展阅读](http://www.cnblogs.com/skyme/p/4651331.html)

##  GATE专业名词
* LR(Language Resource)：语言资源，与数据相关的资源，比如词典、文档和本体(Ontology)等。其中一些语言组件需要和软件搭配使用（比如，WordNet 使用了 C 和 Prolog语言的 API 的用户查询接口），虽然其中涉及了软件，但是由于 API 也是为语言资源服务的，所以我们仍然把这些资源定义为语言组件。

* PR(Processing Resource)：处理资源，表示主要算法实体，如，解析算法，生成算法或n-元模型（ngram）建模算法。
 
* VR（Pisual Resource）: 可视化资源，指构成 GATE 的可视化界面 GUI 的相关资源。

* CREOLE(a Collection of Reusable Objects for Language Engineering)可重用语言引擎对象集合，提供了文本解析、文本抽取、结果测算等众多插件

* ANNIE

* Corpus 语料库，文档的集合


## 行业名词
* GTO：geography text ontology

* iCERS ：Integrated Crime Emergency Response System

>Integrated Crime Emergency Response System (iCERS) is a large-scale spatio-temporal system which integrates all sorts of crime emergency service resources and majors its features as common codes used for public emergency events reporting.

* CE2M ：Crime Emergency Event Model

>The ontology for Crime Emergency Event Model (CE2M) is recommended as an effective means to implement semantic level integration. CE2M is stratified into three levels: Event, Process and Action. CE2M constructs the vocabulary and the common model for exchange of iCERS information, thus it becomes the common comprehension of each business subsystems.


# 相关阅读
* 《数学之美》科普阅读  
* 《统计自然语处理基础》阅读中...
* 《概率论》