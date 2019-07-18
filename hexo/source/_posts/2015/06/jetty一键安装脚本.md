title: jetty一键安装脚本
date: 2015-06-28 13:39
tags: [CentOS,Web服务器,Jetty]
categories: [运维] 
---

## 准备内容
1. [jetty安装包（官网版本：jetty-distribution-9.2.11.v20150529.tar）](http://download.eclipse.org/jetty/9.2.11.v20150529/dist/jetty-distribution-9.2.11.v20150529.tar.gz)
下载后并重命名为jetty.tar.gz
2. [jetty安装脚本](install-jetty.sh)
3. 已安装JDK1.7

## 安装步骤
将文件复制到CentOS后进行安装
1. CentOS路径：/tmp/jetty
2. 执行
``` bash
cd /tmp/jetty
chmod +x install-jetty.sh
sudo ./install-jetty.sh
```

3. 一路回车即可
