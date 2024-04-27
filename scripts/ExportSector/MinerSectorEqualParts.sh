#!/bin/bash
#脚本的路径
ScriptDir=`dirname $(readlink -f $0)`
#位置参数
MinerID="$1"
[ -z "$MinerID" ] && echo "没有给定矿工的位置参数" && exit
#主目录
RootDir=$ScriptDir/$MinerID/All
[ ! -d "$RootDir" ] && mkdir -p $RootDir
AllSectorID=$RootDir/AllSectorID
lotus state sectors $MinerID |awk -F: '{print $1}' > $AllSectorID
AllSectorIDNub=`wc -l < $AllSectorID`
SeveralEqualParts=4
IntegerValue=$(echo "$AllSectorIDNub / $SeveralEqualParts" |bc)
RemainderValue=$(echo "$AllSectorIDNub % $SeveralEqualParts" |bc)
if [ "$RemainderValue" -eq 0 ];then
	AverageValue=$IntegerValue
else
	AverageValue=$[IntegerValue + 1]
fi
split -l $AverageValue $AllSectorID -d -a 2 $RootDir/a
wc -l $RootDir/a*
