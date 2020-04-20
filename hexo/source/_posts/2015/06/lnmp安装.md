title: LNMP安装
date: 2015-06-30 13:11:58
tags: [CentOS,Web服务器,LNMP]
categories: [OPS] 
---

具体参考[LNMP一键安装官网](http://lnmp.org/)

## NMP环境配置
LNMP:Linux+Nginx+Mysql+PHP

## LNMP相关软件安装目录
Nginx 目录: /usr/local/nginx/
MySQL 目录 : /usr/local/mysql/
MySQL数据库所在目录：/usr/local/mysql/var/
MariaDB 目录 : /usr/local/mariadb/
MariaDB数据库所在目录：/usr/local/mariadb/var/
PHP目录 : /usr/local/php/
PHPMyAdmin目录 : 0.9版为/home/wwwroot/phpmyadmin/ 1.0版为 /home/wwwroot/default/phpmyadmin/ 强烈建议将此目录重命名为其不容易猜到的名字。phpmyadmin可自己从官网下载新版替换。
默认网站目录 : 0.9版为 /home/wwwroot/ 1.0版为 /home/wwwroot/default/
Nginx日志目录：/home/wwwlogs/
/root/vhost.sh添加的虚拟主机配置文件所在目录：/usr/local/nginx/conf/vhost/
PureFtpd 目录：/usr/local/pureftpd/
PureFtpd web管理目录： 0.9版为/home/wwwroot/default/ftp/ 1.0版为 /home/wwwroot/default/ftp/
Proftpd 目录：/usr/local/proftpd/
Redis 目录：/usr/local/redis/

##一键安装
下载
`wget  --no-check-certificate https://api.sinas3.com/v1/SAE_lnmp/soft/lnmp1.2-full.tar.gz `  
一键下载安装
`wget -c http://soft.vpser.net/lnmp/lnmp1.2-full.tar.gz && tar zxf lnmp1.2-full.tar.gz && cd lnmp1.2-full && ./install.sh lnmp`

离线安装
`cd /tmp/lnmp && tar zxf lnmp1.2-full.tar.gz && cd lnmp1.2-full && ./install.sh lnmp`
网络情况10M带宽耗时：45分钟
