#!/bin/bash
#脚本的路径
ScriptDir=`dirname $(readlink -f $0)`
#位置参数
MinerID="$1"
[ -z "$MinerID" ] && echo "没有给定矿工的位置参数" && exit
#主目录
RootDir=$ScriptDir/$MinerID/Active
[ ! -d "$RootDir" ] && mkdir -p $RootDir
ActiveSectorID=$RootDir/ActiveSectorID
lotus state active-sectors $MinerID |awk -F: '{print $1}' > $ActiveSectorID #有效的扇区ID
ActiveSectorIDNub=`wc -l < $ActiveSectorID`
SeveralEqualParts=4
IntegerValue=$(echo "$ActiveSectorIDNub / $SeveralEqualParts" |bc)
RemainderValue=$(echo "$ActiveSectorIDNub % $SeveralEqualParts" |bc)
if [ "$RemainderValue" -eq 0 ];then
	AverageValue=$IntegerValue
else
	AverageValue=$[IntegerValue + 1]
fi
split -l $AverageValue $ActiveSectorID -d -a 2 $RootDir/a
wc -l $RootDir/a*
