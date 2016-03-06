#!/bin/bash 
echo "此脚本删除30天之前的数据,时间可可根据需求输入..."

User="root"
Passwd="root" 


read  -p "删除历史监控数据，请输入自定义天数（默认30天）：" dayRange 
if [ "$dayRange" = "" ]; then 
    dayRange=30
fi

 #取30天之前的时间戳
Date=`date -d $(date -d "-$dayRange day" +%Y%m%d) +%s` 

$(which mysql) -u${User} -p${Passwd} -e "
use zabbix;
DELETE FROM history WHERE 'clock' < $Date;
optimize table history;
DELETE FROM history_str WHERE 'clock' < $Date;
optimize table history_str;
DELETE FROM history_uint WHERE 'clock' < $Date;
optimize table history_uint;
DELETE FROM  trends WHERE 'clock' < $Date;
optimize table  trends;
DELETE FROM trends_uint WHERE 'clock' < $Date;
optimize table trends_uint;
DELETE FROM events WHERE 'clock' < $Date;
optimize table events;
"