---
title: DSS数据应用集成平台的系统架构
date: 2020-12-25 19:22:09
tags: [大数据]
---
`DataSphere Studio`（DSS）是一个数据应用集成平台的开源方案，已集成`scriptis`数据开发IDE，`davinci`可视化报表，和`qualitis`数据质量。
另外dss最强的是支持采用DAG工作流将上述组件进行可视化调度编排，目前调度系统支持接入`azkaban`和`airflow`，也可自行集成其他调度系统，调度任务底层的作业执行引擎可接入linkis计算中间件；

本文主要的关注点是dss的`组件构成`，以及`dss和linkis的组件交互`；
<!-- more -->
# dss组成
![dss组件图](dss-component.png)

系统组成
1. `dss-server`：通过第三方系统的`appjoint-sdk`实现和元数据同步（如project）；
2. `dss-flow-execution-entrance`：工作流实时执行时的dag解析，补充，优化后调用`linkis-ujes-client`执行；
3. `linkis-appjoint-entrance`：linkis的第三方系统的执行入口；
   * 调度系统内部dag解析后，通过调用`linkis-ujes-client`提交任务到ujes执行；
   * 其他第三方系统（如visualis）除了会调用`linkis-ujes-client`提交任务到ujes执行，在实时任务执行时，`appjoint-entrance`也调用第三方服务鉴权和执行任务；

# dss和linkis交互
![dss和linkis交互图](dss.png)

## 2种作业类型
1. appjoint类任务：通过自行实现的appjoint-sdk，调用第三方系统执行，第三方系统再接入linkis-ujes；
2. workflow类任务：用于实时执行的，从dss读取dag信息，然后解析dag依赖，调用linkis-client进行执行任务节点。