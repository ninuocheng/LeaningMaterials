#!/bin/bash
#脚本路径
ScriptDir="/root/.gzc"
#主目录的关键字,比如window winning sealing,如果不指定参数，默认是window
DirKeyWord=$1
[ -z "${DirKeyWord}" ] && DirKeyWord="window"
[ ! -f "/opt/raid0/lotusminer-${DirKeyWord}/lotusminer/storage.json" ] && echo "/opt/raid0/lotusminer-${DirKeyWord}/lotusminer/storage.json 文件不存在，请检查。" && exit
[ ! -d $ScriptDir/${DirKeyWord}logbak ] && echo "$ScriptDir/${DirKeyWord}logbak 目录不存在，请检查" && exit
LatestBakLog=`ls -lhrt $ScriptDir/${DirKeyWord}logbak |awk 'NR>1{print}' |awk 'END{print $NF}'`
[ -z "$LatestBakLog" ] && echo "$ScriptDir/${DirKeyWord}logbak目录下没有日志文件，请检查" && exit
[ ! -f "$ScriptDir/${DirKeyWord}log" -o ! -f "$ScriptDir/${DirKeyWord}logbak/$LatestBakLog" ] && echo "$ScriptDir/${DirKeyWord}log 或者 $ScriptDir/${DirKeyWord}logbak/$LatestBakLog 不存在，请检查" && exit
diff $ScriptDir/${DirKeyWord}log $ScriptDir/${DirKeyWord}logbak/$LatestBakLog |tee $ScriptDir/diff${DirKeyWord}log
#日志备份
LogBakDir="$ScriptDir/diff${DirKeyWord}logbak"
BakTime=`date +%Y%m%d%H%M%S`
if [ -f $ScriptDir/diff${DirKeyWord}log ];then
        if [ -s $ScriptDir/diff${DirKeyWord}log ];then
                mkdir -p $LogBakDir
                mv $ScriptDir/diff${DirKeyWord}log ${LogBakDir}/${BakTime}.diff${DirKeyWord}log
                echo "diff $ScriptDir/${DirKeyWord}log $ScriptDir/${DirKeyWord}logbak/$LatestBakLog 比对有差异，请检查"
        else
                echo "diff $ScriptDir/${DirKeyWord}log $ScriptDir/${DirKeyWord}logbak/$LatestBakLog 比对没有差异，请检查"
        fi
else
        echo "$ScriptDir/diff${DirKeyWord}log 比对的文件不存在，请检查"
fi
