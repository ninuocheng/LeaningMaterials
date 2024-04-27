#!/bin/bash
#脚本的路径
ScriptDir=`dirname $(readlink -f $0)`
#位置参数
MinerID="$1"
[ -z "$MinerID" ] && echo "没有给定矿工的位置参数" && exit
#主目录
RootDir=$ScriptDir/$MinerID/Terminated
[ ! -d "$RootDir" ] && mkdir -p $RootDir
AllSectorID=$RootDir/AllSectorID
lotus state sectors $MinerID |awk -F: '{print $1}' > $AllSectorID
AllSectorIDNub=`wc -l < $AllSectorID`
ActiveSectorID=$RootDir/ActiveSectorID
lotus state active-sectors $MinerID |awk -F: '{print $1}' > $ActiveSectorID
ActiveSectorIDNub=`wc -l < $ActiveSectorID`
TerminatedSectorID=$RootDir/TerminatedSectorID
sort $AllSectorID $ActiveSectorID $ActiveSectorID |uniq -u > $TerminatedSectorID
TerminatedSectorIDNub=`wc -l < $TerminatedSectorID`
SeveralEqualParts=4
IntegerValue=$(echo "$TerminatedSectorIDNub / $SeveralEqualParts" |bc)
RemainderValue=$(echo "$TerminatedSectorIDNub % $SeveralEqualParts" |bc)
if [ "$RemainderValue" -eq 0 ];then
	AverageValue=$IntegerValue
else
	AverageValue=$[IntegerValue + 1]
fi
split -l $AverageValue $TerminatedSectorID -d -a 2 $RootDir/a
wc -l $RootDir/a*
