---
title: JDL领域实体建模
date: 2020-05-25 13:47:07
tags: [UML]
---

传统领域实体建模一般采用PowerDesign等UML软件实现，设计更新没有版本控制，不易维护和团队分享；
可采用JDL（Jhipster Domain Language）实现document as code，编写jdl文件并用git进行版本控制；
JDL建模IDE可采用online,visual studio code,atom等通用文本编辑器，可导出图片预览UML效果；
JDL编写好后，可用jhipster import-jdl工具生成entity层的java代码。
<!-- more -->  

# JDL介绍
jhipster家的领域建模语言，可以用于实现document as code，实现对ER图的版本管理；

* sql生成JDL模型描述文件（sql-to-jdl）
* 用JDL生成UML图
* 用JDL生成java后端的domain实体
* 普通CRUD用JPA实现，复杂连接查询用Mybatis

# 示例
[Xface.jdl](Xface.jdl)
[MLP.jdl](MLP-biz.jdl)
[MLP.jdl](MLP-mgmt.jdl)

# 参考
* [jdl语法](https://jhipster-china.github.io/jdl/)
* [JHipster域语言（JDL）](https://github.com/jhipster/cn/blob/master/pages/jdl.md)