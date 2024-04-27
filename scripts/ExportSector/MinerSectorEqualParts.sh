#!/bin/bash
MinerID="$1"
[ -z "$MinerID" ] && echo "没有给定矿工的位置参数" && exit
#脚本的路径
ScriptDir=`dirname $(readlink -f $0)`
#主目录
RootDir=$ScriptDir/$MinerID
[ ! -d "$RootDir" ] && mkdir -p $RootDir
SectorID=$RootDir/SectorID
lotus state sectors $MinerID |awk -F: '{print $1}' > $SectorID
MinerIDSectorIDNub=`wc -l < $SectorID`
SeveralEqualParts=4
IntegerValue=$(echo "$MinerIDSectorIDNub / $SeveralEqualParts" |bc)
RemainderValue=$(echo "$MinerIDSectorIDNub % $SeveralEqualParts" |bc)
if [ "$RemainderValue" -eq 0 ];then
	AverageValue=$IntegerValue
else
	AverageValue=$[IntegerValue + 1]
fi
split -l $AverageValue $SectorID -d -a 2 $RootDir/a
wc -l $RootDir/a*
