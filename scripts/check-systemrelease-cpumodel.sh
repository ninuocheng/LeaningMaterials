#!/bin/bash      
CPUModel=$(lscpu |egrep  -w 'Intel|AMD' |awk '{if($0~"Intel"){print $(NF-6)} else if($3 == "AMD"){print $3}else{print ""}}' |awk -F'(' '/Intel|AMD/{print $1}')
SystemInfo="/tmp/systeminfo"
lsb_release -a &> $SystemInfo
SystemName=$(awk '/Distributor/{print $NF}' $SystemInfo)
VersionID=$(awk '/Release/{print $NF}' $SystemInfo)
echo "${CPUModel}.${SystemName}.${VersionID}"
