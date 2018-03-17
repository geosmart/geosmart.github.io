title: mongodb一键安装脚本
date: 2015-07-01 20:26
tags: [CentOS,数据库,MongoDB] 
categories: [运维] 
---
 
![](logo-mongodb.png)   
 
## 准备内容
1. [mongodb安装包（官网版本：mongodb-linux-x86_64-2.6.3.tgz）](http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.6.3.tgz)
下载后并重命名为mongodb.tar.gz
2. [mongodb安装脚本](install-mongodb.sh)

## 安装步骤
将文件复制到CentOS后进行安装
1. CentOS路径：/tmp 
2. 执行
``` bash
cd /tmp
chmod +x install-mongodb.sh 
sudo ./install-mongodb.sh
```

3. 一路回车即可 