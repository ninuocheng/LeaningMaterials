#!/bin/bash
#脚本的路径
ScriptDir=`dirname $(readlink -f $0)`
#位置参数
MinerID="$1"
[ -z "$MinerID" ] && echo "没有给定矿工的位置参数" && exit
#主目录
RootDir=$ScriptDir/$MinerID/SelfDetermined
[ ! -d "$RootDir" ] && mkdir -p $RootDir
SelfDeterminedSectorID=$RootDir/SelfDeterminedSectorID
[ ! -f "$SelfDeterminedSectorID" ] && echo "${SelfDeterminedSectorID} 不存在，请检查" && exit
SelfDeterminedSectorIDNub=`wc -l < $SelfDeterminedSectorID`
SeveralEqualParts=4
IntegerValue=$(echo "$SelfDeterminedSectorIDNub / $SeveralEqualParts" |bc)
RemainderValue=$(echo "$SelfDeterminedSectorIDNub % $SeveralEqualParts" |bc)
if [ "$RemainderValue" -eq 0 ];then
	AverageValue=$IntegerValue
else
	AverageValue=$[IntegerValue + 1]
fi
split -l $AverageValue $SelfDeterminedSectorID -d -a 2 $RootDir/a
wc -l $RootDir/a*
