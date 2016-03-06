title: jetty手动安装脚本
date: 2015-06-28 13:39
tags: [CentOS,Web服务器,Jetty]
categories: [运维] 
---

##安装步骤
将文件复制到CentOS后进行安装
###  下载解压Jetty
``` bash
cd /tmp
wget http://eclipse.org/downloads/download.php?file=/jetty/stable-9/dist/jetty-distribution-9.3.0.v20150612.tar.gz&r=1
tar -xzvf  jetty-distribution-9.3.0.v20150612.tar.gz
mv jetty-distribution-9.1.1.v20140108 /usr/local/jetty
```

### 新建用户>配置jetty所属权限
``` bash
useradd -m jetty
chown -R jetty:jetty /usr/local/jetty/
```

### 安装到系统服务
``` bash
ln -s /usr/local/jetty/bin/jetty.sh /etc/init.d/jetty
chkconfig --add jetty
chkconfig --level 345 jetty on
```

### 编辑启动脚本
``` bash
vim /etc/default/jetty
JETTY_HOME=/usr/local/jetty
JETTY_USER=jetty
JETTY_PORT=8080
JETTY_LOGS=/usr/local/jetty/logs/
```

### 启动服务>测试
``` bash
service jetty start
curl localhost:8080
```    

### 常用操作指令
``` bash
jetty [-d] {start|stop|run|restart|check|supervise} [ CONFIGS ... ]
```   
