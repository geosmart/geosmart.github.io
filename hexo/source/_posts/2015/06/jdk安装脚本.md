title: jdk安装脚本
date: 2015-06-28 16:03
tags: [CentOS,J2EE]
categories: [运维] 
---

## 准备内容
1. [jdk7 X64安装包（官网版本：jdk-7u80-linux-x64.tar.gz）](http://download.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-linux-x64.tar.gz)
下载后并重命名为jetty.tar.gz
2. [jdk安装脚本](install-jdk.sh)

## 安装步骤
将文件复制到CentOS后进行安装
1. CentOS路径：/tmp/jdk
2. 执行

``` bash

cd /tmp/jdk
chmod +x install-jdk.sh
sudo ./install-jdk.sh

```

3. 一路回车即可

#附件 install-jdk.sh
``` bash   

#!/bin/sh
BASEDIR=$(cd `dirname $0`; pwd)

#jdk-7u80-linux-x64
read  -p "Please select java tar package full path path[/tmp/jdk.tar.gz] " INSTALL_FILE
if [ ! -f "$INSTALL_FILE" ]; then
	INSTALL_FILE="/tmp/jdk.tar.gz"
fi

# Set install path
read  -p "Please select java install path path[/usr/local/java]: " INSTALL_PATH
if [ "$INSTALL_PATH" = "" ]; then
	INSTALL_PATH="/usr/local/java"
fi
if [ ! -d $INSTALL_PATH ]; then
    echo "mkdir $INSTALL_PATH"
    mkdir -p $INSTALL_PATH
fi

echo "uncompress $INSTALL_FILE to $INSTALL_PATH"
if [ -w $INSTALL_PATH ]; then
  tar -zxvf $INSTALL_FILE -C $INSTALL_PATH --strip-components=1
else
  sudo tar -zxvf $INSTALL_FILE -C $INSTALL_PATH --strip-components=1
fi


echo "Setting java environment..."
echo "export JAVA_HOME=$INSTALL_PATH" | sudo tee -a /etc/profile

JAVA_HOME=$INSTALL_PATH
#FIXME
echo "export CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar" | sudo tee -a /etc/profile
echo 'export PATH=$JAVA_HOME/bin:$PATH' | sudo tee -a /etc/profile

echo "refresh java environment..."
#TODO what does "."  do? the same as "source" command?
. /etc/profile
source /etc/profile

java -version
if [ "$?" = "0" ]; then
echo -e "\033[32m Installed, please source /etc/profile or relogin. \033[0m"
else
echo -e "\033[31m Install failed. \033[0m"
fi

unset BASEDIR
unset INSTALL_PATH
unset INSTALL_FILE

exit 0

```

4. 卸载JDK

``` shell
#查看系统已安装的jdk
rpm -qa|grep jdk
java-1.7.0-openjdk-1.7.0.45-2.4.3.3.el6.x86_64
#卸载指定版本的jdk
rpm -e --nodeps  java-1.7.0-openjdk-1.7.0.45-2.4.3.3.el6.x86_64
# 删除JAVA_HOME，CLASSPATH等相关环境变量
vim /etc/profile
```
