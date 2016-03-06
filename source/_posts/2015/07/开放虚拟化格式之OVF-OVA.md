title: 开放虚拟化格式之OVF-OVA
date: 2015-07-12 22:05:44
tags: [EXSI] 
categories: [运维] 
---
遇到Sphere6.0 (esxi6 )导出的OVF虚拟机模板在Vmware WorkStation 9和VmWare WorkStation11中导入报错的问题，暂改成OVA格式进行数据交换。


- - -
<!-- more -->

#问题描述 
![导入失败，未通过 OVF 规范一致性或虚拟硬件合规性检查。请单击“重试”放松 OVF 规范与虚拟硬件合规性检查，并重新尝试导入](errorInfo.png)


##  解决方式
以OVA格式进行数据交换
VMware导出时将后缀改为OVA后到处；ESXI导出时选OVA

#基础知识
## OVF
OVF（Open Virtualization Format：开放虚拟化格式 ）
OVF是一种开源的文件规范，它描述了一个开源、安全、有效、可拓展的便携式虚拟打包以及软件分布格式，它一般有几个部分组成，分别是ovf文件、mf文件、cert文件、vmdk文件和iso文件。
## OVA
OVA（Open Virtualization Appliance：开放虚拟化设备）
OVA包是一个单一的文件，所有必要的信息都封装在里面。OVA文件则采用.tar文件扩展名,包含了一个OVF 包中所有文件类型。这样OVA单一的文件格式使得它非常便携。
 