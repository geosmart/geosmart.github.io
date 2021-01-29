---
title: DSS工作流实现原理
date: 2021-01-28 11:45:40
tags:
---

# BML
* 工作流的节点可以关联一个执行脚本，比如shell/python/sql
* 脚本保存时（saveScriptToBML）,会为文件新增1个版本，实际实现是追加字节到hdfs的文件尾部，linkis会在`linkis_resources_version`表存储每个版本起始字节偏移量；
* 脚本打开时（openScriptFromBML），会根据版本读取文件的起始字节内容；

