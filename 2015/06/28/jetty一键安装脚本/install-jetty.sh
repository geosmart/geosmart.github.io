#!/bin/sh

BASEDIR=$(cd `dirname $0`; pwd)

# must sudo
if [ "$(id -u)" -ne 0 ] ; then
    echo -e "\033[31m You must run this script as sudo. Sorry! \033[0m"
    exit 1
fi

# check env
. /etc/profile
. ~/.bash_profile

if [ "$JAVA_HOME" = "" ]; then
    echo -e "\033[31m Your java environment isn't right. \033[0m"
    exit 1
fi

read  -p "Please select jetty tar package full path[/tmp/jetty.tar.gz]: " INSTALL_FILE 
if [ "$INSTALL_FILE" = "" ]; then 
	INSTALL_FILE="/tmp/jetty.tar.gz"
fi


echo "Start to install..."
read  -p "Please select jetty install path path[/usr/local/jetty]: " INSTALL_PATH
if [ "$INSTALL_PATH" = "" ]; then
	INSTALL_PATH="/usr/local/jetty"
fi

# Set up jetty user
read  -p "Please set jetty run user[jetty]: " JETTY_USER
if [ "$JETTY_USER" = "" ]; then
	JETTY_USER=jetty
fi

# Set up jetty logs dir
read  -p "Please set jetty logs user[/var/log/jetty]: " JETTY_LOGS
if [ "$JETTY_LOGS" = "" ]; then
	JETTY_LOGS=/var/log/jetty
fi

# Set up jetty service name
read  -p "Please set jetty service name[jetty]: " JETTY_SERVICE
if [ "$JETTY_SERVICE" = "" ]; then
	JETTY_SERVICE=jetty
fi
while true
do
    if [ ! "$(chkconfig --list | grep -o $JETTY_SERVICE)" = "" ];then
        read  -p "service $JETTY_SERVICE exsited, please select again: " JETTY_SERVICE
    else
        break
    fi
done

# logs dir
read  -p "Please set jetty port[8080]: " JETTY_PORT
if [ "$JETTY_PORT" = "" ]; then
	JETTY_PORT=8080
fi

# Set up jetty pid
read  -p "Please set jetty pid path[/var/run/$JETTY_SERVICE.pid]: " JETTY_PID
if [ "$JETTY_PID" = "" ]; then
	JETTY_PID=/var/run/$JETTY_SERVICE.pid
fi

######### Confirm?
echo "Selected config:"

echo "Port           : $JETTY_PORT"
echo "User           : $JETTY_USER"
echo "Log            : $JETTY_LOGS"
echo "Pid            : $JETTY_PID"
echo "Service        : $JETTY_SERVICE"

read -p "Is this ok? Then press ENTER to go on or Ctrl-C to abort." _UNUSED_

# add user
if [ "$(groups | grep $JETTY_USER)" = "" ]; then
    groupadd $JETTY_USER
fi
if [ "$(users | grep $JETTY_USER)" = "" ]; then
    useradd -g $JETTY_USER $JETTY_USER
fi

# mkdir install path
if [ ! -d $INSTALL_PATH ]; then
    echo "mkdir $INSTALL_PATH"
    mkdir -p $INSTALL_PATH
fi

# mkdir log path
if [ ! -d "$JETTY_LOGS" ]; then
    mkdir -p $JETTY_LOGS
    chown -R $JETTY_USER:$JETTY_USER $JETTY_LOGS
fi

# Uncompress
echo "Uncompress tar to $INSTALL_PATH..."
tar -zxf $INSTALL_FILE -C $INSTALL_PATH --strip-components=1
jetty_temp=~/.jetty_temp
if [ -f "$jetty_temp" ]; then
    touch $jetty_temp
fi

# env setting
jetty_sh=$INSTALL_PATH/bin/jetty.sh
echo "Setting jetty conf..."
echo "JAVA_HOME=$JAVA_HOME" > $jetty_temp && cat $jetty_sh >> $jetty_temp && mv -f $jetty_temp $jetty_sh
echo "JAVA=$JAVA_HOME/bin/java" > $jetty_temp && cat $jetty_sh >> $jetty_temp &&  mv -f $jetty_temp $jetty_sh
echo "JETTY_LOGS=$JETTY_LOGS" > $jetty_temp && cat $jetty_sh >> $jetty_temp &&  mv -f $jetty_temp $jetty_sh
echo "JETTY_USER=$JETTY_USER" > $jetty_temp && cat $jetty_sh >> $jetty_temp &&  mv -f $jetty_temp $jetty_sh
echo "JETTY_PORT=$JETTY_PORT" > $jetty_temp && cat $jetty_sh >> $jetty_temp &&  mv -f $jetty_temp $jetty_sh
echo "JETTY_PID=$JETTY_PID" > $jetty_temp && cat $jetty_sh >> $jetty_temp &&  mv -f $jetty_temp $jetty_sh
echo "JETTY_HOME=$INSTALL_PATH" > $jetty_temp && cat $jetty_sh >> $jetty_temp &&  mv -f $jetty_temp $jetty_sh
chmod +x $jetty_sh
#
chown -R $JETTY_USER:$JETTY_USER $INSTALL_PATH

# jetty service
echo "Install jetty service..."
ln -s $INSTALL_PATH/bin/jetty.sh /etc/init.d/$JETTY_SERVICE
if [ ! "$?" = "0" ]; then
    echo -e "\033[31m link jetty script failed. \033[0m"
    exit 1
fi
chkconfig --add $JETTY_SERVICE
chkconfig --level 345 $JETTY_SERVICE on
if [ "$?" = "0" ]; then
    echo -e "\033[32m Installed, please sudo service $JETTY_SERVICE start. \033[0m"
else
    echo -e "\033[31m Service $JETTY_SERVICE install failed. \033[0m"
fi

unset BASEDIR
unset INSTALL_PATH
unset JETTY_USER
unset JETTY_PORT
unset JETTY_LOGS
unset JETTY_SERVICE
unset jetty_temp
unset jetty_sh

exit 0
