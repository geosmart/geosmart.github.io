#!/bin/sh 
#注意：脚本需在linux上新建，windows上新建的无法运行
#注意：需配合zabbix安装包进行安装
#zabbix安装包已修改zabbix客户端/服务端的配置文件

BASEDIR=$(cd `dirname $0`; pwd)

# must sudo
if [ "$(id -u)" -ne 0 ] ; then
    echo -e "\033[31m You must run this script as sudo. Sorry! \033[0m"
    exit 1
fi
  
echo "Start to install..."
read  -p "Please select zabbix install path path[/usr/local/zabbix]: " INSTALL_PATH
if [ "$INSTALL_PATH" = "" ]; then
	INSTALL_PATH="/usr/local/zabbix"
fi

# Set up zabbix user
read  -p "Please set zabbix run user[zabbix]: " ZABBIX_USER
if [ "$ZABBIX_USER" = "" ]; then
	ZABBIX_USER=zabbix
fi

# Set up zabbix logs dir
read  -p "Please set zabbix logs user[/var/log/zabbix]: " ZABBIX_LOGS
if [ "$ZABBIX_LOGS" = "" ]; then
	ZABBIX_LOGS=/var/log/zabbix
fi

# Set up zabbix service name
read  -p "Please set zabbix service name[zabbix_server]: " ZABBIX_SERVICE
if [ "$ZABBIX_SERVICE" = "" ]; then
	ZABBIX_SERVICE=zabbix_server
fi
while true
do
    if [ ! "$(chkconfig --list | grep -o $ZABBIX_SERVICE)" = "" ];then
        read  -p "service $ZABBIX_SERVICE exsited, please select again: " ZABBIX_SERVICE
    else
        break
    fi
done
 
# Set up zabbix pid
read  -p "Please set zabbix pid path[/var/run/$ZABBIX_SERVICE.pid]: " ZABBIX_PID
if [ "$ZABBIX_PID" = "" ]; then
	ZABBIX_PID=/var/run/$ZABBIX_SERVICE.pid
fi

######### Confirm?
echo "Selected config:"
 
echo "User           : $ZABBIX_USER"
echo "Log            : $ZABBIX_LOGS"
echo "Pid            : $ZABBIX_PID"
echo "Service        : $ZABBIX_SERVICE"

read -p "Is this ok? Then press ENTER to go on or Ctrl-C to abort." _UNUSED_

#新建用户
if [ "$(groups | grep $ZABBIX_USER)" = "" ]; then
    groupadd $ZABBIX_USER
fi
if [ "$(users | grep $ZABBIX_USER)" = "" ]; then
    useradd -g $ZABBIX_USER $ZABBIX_USER
fi

#新建安装路径
if [ ! -d $INSTALL_PATH ]; then
    echo "mkdir $INSTALL_PATH"
    mkdir -p $INSTALL_PATH
fi

#新建日志路径
if [ ! -d "$ZABBIX_LOGS" ]; then
    mkdir -p $ZABBIX_LOGS
    chown -R $ZABBIX_USER:$ZABBIX_USER $ZABBIX_LOGS
fi 

echo "配置mysql..." 
mysql -D zabbix -uzabbix -pzabbix < $INSTALL_PATH/database/mysql/schema.sql;
mysql -D zabbix -uzabbix -pzabbix < $INSTALL_PATH/database/mysql/data.sql;
mysql -D zabbix -uzabbix -pzabbix < $INSTALL_PATH/database/mysql/images.sql;


echo "编译Zabbix $INSTALL_PATH..."
cd  $INSTALL_PATH
./configure --prefix=$INSTALL_PATH --enable-server --enable-agent --enable-proxy --with-mysql=/usr/local/mysql/bin/mysql_config --enable-net-snmp --with-libcurl --with-libxml2
make install
make installcheck
    

echo "新建开机启动配置文件..."
cd /etc
mkdir zabbix
#服务端
cp /usr/local/zabbix/misc/init.d/tru64/$ZABBIX_SERVICE /etc/init.d/    
chmod 777 /etc/init.d/$ZABBIX_SERVICE  
 
#客户端
cp /usr/local/zabbix/misc/init.d/tru64/zabbix_agentd /etc/init.d/   
chmod 777 /etc/init.d/zabbix_agentd   

  
# zabbix service
echo "添加zabbix到启动项 ..." 
chkconfig --add $ZABBIX_SERVICE
chkconfig --level 345 $ZABBIX_SERVICE on

chkconfig --add zabbix_agentd 
chkconfig --level 345 zabbix_agentd on

if [ "$?" = "0" ]; then
    echo -e "\033[32m Installed, please sudo service $ZABBIX_SERVICE start. \033[0m"
else
    echo -e "\033[31m Service $ZABBIX_SERVICE install failed. \033[0m"
fi

echo "启动zabbix ..." 
service zabbix_server start 
service zabbix_agentd start

echo "查看zabbix服务启动状态 ..." 
netstat -antlp  | grep 'zabbix'

unset BASEDIR
unset INSTALL_PATH
unset ZABBIX_USER 
unset ZABBIX_LOGS
unset ZABBIX_SERVICE
unset zabbix_temp 

exit 0 