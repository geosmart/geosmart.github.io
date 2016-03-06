title: Docker学习笔记
date: 2015-10-03 17:58:26
tags: [Docker]
categories: [运维]
---

dockerfile就像人体的DNA，提供自动构建一切的元数据。

- - -
<!-- more -->

# Docker基本概念
## 镜像（Image）
Docker 镜像就是一个只读的模板。镜像可以用来创建 Docker 容器。
## 容器（Container）
Docker 利用容器来运行应用。
容器是从镜像创建的运行实例。它可以被启动、开始、停止、删除。每个容器都是相互隔离的、保证安全的平台。
可以把容器看做是一个简易版的 Linux 环境（包括root用户权限、进程空间、用户空间和网络空间等）和运行在其中的应用程序。
*注：镜像是只读的，容器在启动的时候创建一层可写层作为最上层。
## 仓库（Repository）
仓库是集中存放镜像文件的场所。有时候会把仓库和仓库注册服务器（Registry）混为一谈，并不严格区分。实际上，仓库注册服务器上往往存放着多个仓库，每个仓库中又包含了多个镜像，每个镜像有不同的标签（tag）。
仓库分为公开仓库（Public）和私有仓库（Private）两种形式。
*注：Docker 仓库的概念跟 Git 类似，注册服务器可以理解为 GitHub 这样的托管服务。

理解了这三个概念，就理解了 Docker 的整个生命周期。

# Docker相关术语
## LXC
LXC（Linux Container）Linux Container容器是一种内核虚拟化技术，可以提供轻量级的虚拟化，以便隔离进程和资源，而且不需要提供指令解释机制以及全虚拟化的其他复杂性。相当于C++中的NameSpace。容器有效地将由单个操作系统管理的资源划分到孤立的组中，以更好地在孤立的组之间平衡有冲突的资源使用需求。与传统虚拟化技术相比，它的优势在于：
（1）与宿主机使用同一个内核，性能损耗小；
（2）不需要指令级模拟；
（3）不需要即时(Just-in-time)编译；
（4）容器可以在CPU核心的本地运行指令，不需要任何专门的解释机制；
（5）避免了准虚拟化和系统调用替换中的复杂性；
（6）轻量级隔离，在隔离的同时还提供共享机制，以实现容器与宿主机的资源共享。
总结：Linux Container是一种轻量级的虚拟化的手段。
Linux Container提供了在单一可控主机节点上支持多个相互隔离的server container同时执行的机制。Linux Container有点像chroot，提供了一个拥有自己进程和网络空间的虚拟环境，但又有别于虚拟机，因为lxc是一种操作系统层次上的资源的虚拟化。

## Hypervisor
Hypervisor是一种运行在物理服务器和操作系统之间的中间软件层,可允许多个操作系统和应用共享一套基础物理硬件，因此也可以看作是虚拟环境中的“元”操作系统，它可以协调访问服务器上的所有物理设备和虚拟机，也叫虚拟机监视器（Virtual Machine Monitor）。Hypervisor是所有虚拟化技术的核心。非中断地支持多工作负载迁移的能力是Hypervisor的基本功能。当服务器启动并执行Hypervisor时，它会给每一台虚拟机分配适量的内存、CPU、网络和磁盘，并加载所有虚拟机的客户操作系统。

# 容器VS 虚拟机
容器会比虚拟机更高效，因为它们能够分享一个内核和分享应用程序库。相比虚拟机系统，这也将使得 Docker使用的内存更小，即便虚拟机利用了内存超量使用的技术。部署容器时共享底层的镜像层也可以减少存储占用。IBM 的 Boden Russel 已经做了一些基准测试来说明两者之间的不同。

相比虚拟机系统，容器具有较低系统开销的优势，所以在容器中，应用程序的运行效率将会等效于在同样的应用程序在虚拟机中运行，甚至效果更佳。

# 常用命令 
*	查看所有镜像：docker images：
*	删除所有镜像：docker rmi $(docker images | grep none | awk '{print $3}' | sort -r)
*	删除所有容器：docker rm $(docker ps -a -q)
*	停止/启动/杀死一个容器：stop/start/kill <容器名orID> 

#	问题记录
1. docker: relocation error: docker: symbol dm_task_get_info_with_deferred_remove, version Base not defined in file libdevmapper.so.1.02 with link time reference
解决方案：
You may have to enable the public_ol6_latest repo in order to get this package.
`sudo yum-config-manager --enable public_ol6_latest`
And then install the package:
`sudo yum install device-mapper-event-libs`

2.	Error response from daemon: EOF

# Docker方案
## Kitematic
>[Kitematic](https://github.com/kitematic/kitematic) 是一个具有现代化的界面设计的自由开源软件，它可以让我们在 Docker 中交互式执行任务。Kitematic 设计的非常漂亮、界面美观。使用它，我们可以简单快速地开箱搭建我们的容器而不需要输入命令，可以在图形用户界面中通过简单的点击从而在容器上部署我们的应用。
Kitematic 集成了 Docker Hub，允许我们搜索、拉取任何需要的镜像，并在上面部署应用。它同时也能很好地切换到命令行用户接口模式。目前，它包括了自动映射端口、可视化更改环境变量、配置卷、流式日志以及其它功能。

[参考教程](http://www.linuxidc.com/Linux/2015-09/122601.htm)
安装问题

``` shell
Error creating machine: exit status 1
You will want to check the provider to make sure the machine and associated resources were properly removed.
```
待解决：[github issue](https://github.com/docker/toolbox/issues/245)


# 待解决问题 
## 如何自动部署Github程序到Docker镜像

## 构建搭载Tomcat环境的镜像


## 部署前端web应用
## 部署后端Java服务



