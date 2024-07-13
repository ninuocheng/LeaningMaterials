#!/bin/bash      
#CPUModel=$(lscpu |egrep  -w 'Intel|AMD' |awk '{if($0~"Intel"){print $(NF-6)} else if($3 == "AMD"){print $3}else{print ""}}' |awk -F'(' '/Intel|AMD/{print $1}')
CPUModel=$(lscpu |egrep  -w 'Intel|AMD' |awk -F'：|:' '{$1="";print}' |awk '{if($0~"Intel"){print $1} else if($1 == "AMD"){print $1}else{print ""}}' |awk -F'(' '/Intel|AMD/{print $1}')
SystemInfo="/tmp/systeminfo"
lsb_release -a &> $SystemInfo
SystemName=$(awk '/Distributor/{print $NF}' $SystemInfo)
VersionID=$(awk '/Release/{print $NF}' $SystemInfo)
for i in `ls -1 $(which lotus) /opt/*/lotus/bin/lotus 2>/dev/null`
do
    LatestLotusBinFile=$i
    [ ! -f "$LatestLotusBinFile" ] && echo "${LatestLotusBinFile}不存在，请检查。" && continue
    if $LatestLotusBinFile -v 2> /dev/null |grep -wi "${CPUModel}.${SystemName}.${VersionID}" ;then
         continue
    else
         echo "`${LatestLotusBinFile} -v`和系统版本${SystemName}.${VersionID}或是CPU型号${CPUModel}不匹配，请检查确认"
    fi
done
