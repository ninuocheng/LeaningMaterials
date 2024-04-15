#!/bin/bash
#主目录的关键字,比如window winning sealing,如果不指定参数，默认是window
DirKeyWord=$1
[ -z "${DirKeyWord}" ] && DirKeyWord="window"
[ ! -f "/opt/raid0/lotusminer-${DirKeyWord}/lotusminer/storage.json" ] && echo "/opt/raid0/lotusminer-${DirKeyWord}/lotusminer/storage.json 文件不存在，请检查。" && exit
#日志备份
LogBakDir="${DirKeyWord}logbak"
BakTime=`date +%Y%m%d%H%M%S`
[ -f ${DirKeyWord}log ] && mkdir -p ${DirKeyWord}logbak && mv ${DirKeyWord}log $LogBakDir/${BakTime}.${DirKeyWord}log
for i in `awk -F'"' '$2 == "Path"{print $4}' /opt/raid0/lotusminer-${DirKeyWord}/lotusminer/storage.json`; do df -hT $i; [ $? -ne 0 ] && echo "df -hT $i 异常，请检查"; done|column -t |sort |uniq -c |sort -nk6 |tee ${DirKeyWord}log
