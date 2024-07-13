#!/bin/bash
#脚本的路径
ScriptDir=`dirname $(readlink -f $0)`
[ ! -d "${ScriptDir}" ] && echo "主目录${ScriptDir}不存在，请检查。" && exit
#主目录的关键字,比如window winning sealing,不指定，默认window
DirKeyWord=$1
[ -z "${DirKeyWord}" ] && DirKeyWord="window"
#指定的主机或主机组,如果不指定，默认主目录的关键字+list
Host=$2
[ -z "$Host" ] && Host="${DirKeyWord}list"
#指定的hosts文件,如果不指定，默认主目录的关键字+hosts
Parameter=$3
[ -z "$Parameter" ] && Parameter="${DirKeyWord}hosts"
HostFile="${ScriptDir}/${Parameter}"
[ ! -f "${HostFile}" ] && echo "指定的hosts文件${HostFile}不存在，请检查。" && exit
#日志备份
LogBakDir="${ScriptDir}/${DirKeyWord}logbak"
BakTime=`date +%Y%m%d%H%M%S`
[ -f "${ScriptDir}/${DirKeyWord}log" ] && mkdir -p $LogBakDir && mv ${ScriptDir}/${DirKeyWord}log $LogBakDir/${BakTime}.${DirKeyWord}log
if grep -wq "${Host}" ${HostFile};then
    #设置主机并行次数，目的是ansible输出与主机清单顺序一致，方便比对文件差异
    ansible -i ${HostFile} ${Host} -m shell -a 'chdir=/root/.gzc removes=/opt/raid0/lotusminer-'${DirKeyWord}'/lotusminer/storage.json /bin/bash MinerStorage.sh '${DirKeyWord}'' --forks=1 |tee ${ScriptDir}/${DirKeyWord}log
else
    echo "指定的hosts文件${HostFile}中的主机或主机组${Host}不存在，请检查。"
    exit
fi
