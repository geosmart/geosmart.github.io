#!/bin/sh
BASEDIR=$(cd `dirname $0`; pwd)

#mongodb-7u80-linux-x64
read  -p "Please select mongodb tar package full path path[/tmp/mongodb/mongodb.tar.gz] " INSTALL_FILE
if [ ! -f "$INSTALL_FILE" ]; then
	INSTALL_FILE="/tmp/mongodb/mongodb.tar.gz"
fi

# Set up mongodb user
read  -p "Please set mongodb run user[mongodb]: " MONGODB_USER
if [ "$MONGODB_USER" = "" ]; then
	MONGODB_USER=mongodb
fi

# Set install path
read  -p "Please select mongodb install path path[/usr/local/mongodb]: " INSTALL_PATH
if [ "$INSTALL_PATH" = "" ]; then
	INSTALL_PATH="/usr/local/mongodb"
fi


######### Confirm?

#uncompress
echo "uncompress $INSTALL_FILE to $INSTALL_PATH"
if [ -w $INSTALL_PATH ]; then
  tar -zxvf $INSTALL_FILE -C $INSTALL_PATH --strip-components=1
else
  sudo tar -zxvf $INSTALL_FILE -C $INSTALL_PATH --strip-components=1
fi

# add user
if [ "$(groups | grep $MONGODB_USER)" = "" ]; then
    groupadd $MONGODB_USER
fi
if [ "$(users | grep $MONGODB_USER)" = "" ]; then
    useradd -g $MONGODB_USER $MONGODB_USER 
	chown -R $MONGODB_USER.$MONGODB_USER  $INSTALL_PATH
fi

#set path
if [ ! -d $INSTALL_PATH ]; then
    echo "mkdir $INSTALL_PATH"
    mkdir -p $INSTALL_PATH
fi

echo "Setting mongodb environment..."
echo 'export MONGODB_HOME=$INSTALL_PATH' | sudo tee -a /etc/profile
echo 'export PATH=$MONGODB_HOME/bin:$PATH ' | sudo tee -a /etc/profile

echo "refresh mongodb environment..."    
source /etc/profile 
mongodb -version

echo "设置MongoDB开机启动..."
MONGODB_CONF="/usr/local/mongodb/mongodb.conf"
touch  $MONGODB_CONF
chmod 777 $MONGODB_CONF

cat >>$MONGODB_CONF<<EOF
dbpath=/usr/local/mongodb/data
logpath=/usr/local/mongodb/log/mongodb.log
logappend=true
port=27017
fork=true
noauth=true
journal=true
smallfiles=true 
EOF 
 
echo "编写启动服务mongod脚本..."
MONGO_START_BASH=/etc/init.d/mongod
rm $MONGO_START_BASH
touch $MONGO_START_BASH 
cat >>$MONGO_START_BASH<<EOF
#!/bin/sh
#
# mongodb      init file for starting up the MongoDB server
#
# chkconfig:   - 20 80
# description: Starts and stops the MongDB daemon that handles all \
#              database requests.
# Source function library.

. /etc/rc.d/init.d/functions
exec="/usr/local/mongodb/bin/mongod"
prog="mongod"
logfile="/usr/local/mongodb/log/mongodb.log"
options=" -f  /usr/local/mongodb/mongodb.conf"
[ -e /etc/sysconfig/$prog ] && . /etc/sysconfig/$prog
lockfile="/var/lock/subsys/mongod"

start() {
    [ -x $exec ] || exit 5
    echo -n $"Starting $prog: "
    daemon --user mongodb "$exec --quiet $options run >> $logfile 2>&1 &"
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}
stop() {
    echo -n $"Stopping $prog: "
    killproc $prog
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}
restart() {
    stop
    start
}
reload() {
    restart
}
force_reload() {
    restart
}
rh_status() {
    # run checks to determine if the service is running or use generic status
    status $prog
}
rh_status_q() {
    rh_status >/dev/null 2>&1
}
case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart)
        $1
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
        restart
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload}"
        exit 2
esac
exit $?
EOF 

chkconfig --add mongod
chkconfig --level 345 mongod on
chmod 777    /etc/init.d/mongod
chmod  777   /usr/local/mongodb/log/mongodb.log

echo "启动服务/测试服务状态..."
#mongod -f /usr/local/mongodb/mongodb.conf 
service mongod start
service mongod status
shutdown -r now
service mongod status
mongo admin
show dbs；
db.test.find();
exit


if [ "$?" = "0" ]; then
    echo -e "\033[32m Installed, please sudo service mongod start. \033[0m"
else
    echo -e "\033[31m Service mongod install failed. \033[0m"
fi

echo "查询端口占用情况..." 
netstat   -anp   | grep  27017