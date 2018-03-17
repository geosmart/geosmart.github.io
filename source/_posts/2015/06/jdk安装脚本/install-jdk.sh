#!/bin/sh
BASEDIR=$(cd `dirname $0`; pwd)

#jdk-7u80-linux-x64
read  -p "Please select java tar package full path path[/tmp/jdk/jdk.tar.gz] " INSTALL_FILE
if [ ! -f "$INSTALL_FILE" ]; then
	INSTALL_FILE="/tmp/jdk/jdk.tar.gz"
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
