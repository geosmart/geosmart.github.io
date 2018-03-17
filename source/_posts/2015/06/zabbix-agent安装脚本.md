title: zabbix-agent安装脚本
date: 2015-06-29 15:33:38
tags: [CentOS,监控,Zabbix] 
categories: [运维] 
---


![zabbix](zabbix.png) 

# 准备内容
1. [zabbix安装包（官网版本：zabbix-2.2.9.tar.gz）](http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/2.2.9/zabbix-2.2.9.tar.gz/download)
2. yum groupinstall "Development tools"
2. [zabbix安装脚本](install-zabbix_agent.sh) 

 
 cd /tmp && tar -zxf  zabbix.gz

# 安装步骤   
1. 修改zabbix_server程序的磁盘路径  
修改zabbix_server主程序路径
``` bash
# vim /usr/local/zabbix/misc/init.d/tru64/zabbix_server
DAEMON=/usr/local/zabbix/sbin/zabbix_server
```
添加下面两句到`#!/bin/bash`之后，解决`service myservicedoes not support chkconfig`问题
``` bash
# chkconfig: 2345 10 90 
# description:zabbix.... 
```

2. 编辑zabbix_agentd配置文件 
`vim /usr/local/zabbix/etc/zabbix_agentd.conf` 
``` bash
LogFile=/tmp/zabbix_agentd.log 
#服务端IP  
Server=192.168.1.80
#服务端IP   
ServerActive= 192.168.1.80
#客户端IP与zabbix-web配置上的hostName一致   
Hostname=localhost
UnsafeUserParameters=1  
```

3. 执行安装脚本
``` bash
cd /usr/local/zabbix/script/install-zabbix_agentd.sh
chmod +x install-zabbix_agentd.sh 
sudo ./install-zabbix_agentd.sh
```

# 相关操作
1. 若zabbix的host无法访问，考虑防火墙是否需要关闭/加入信任端口
``` bash
#查看防火墙状态
service iptables status 
#关闭防火墙 
service iptables stop  
#永久关闭防火墙 
chkconfig   iptables off 
```  

2. 查看zabbix服务是否已启动
``` bash
netstat -utlnp | grep zabbix 
```    

3. 配置文件更新后，需重启客户端服务
``` bash
service zabbix_agentd restart
```    