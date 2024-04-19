#!/bin/bash
#开始时间
start=$(date +%s)
#当前的最新高度
LatestBlockHeight=`lotus chain getblock $(lotus chain head 2>/dev/null| head -n 1) 2>/dev/null | jq .Height`
#导出的矿工号
MinerID="$1"
[ -z "${MinerID}" ] && echo "没有给定矿工的位置参数" && exit
#脚本的路径
ScriptDir=`dirname $(readlink -f $0)`
#导出扇区信息的主目录
RootDir=$ScriptDir/$MinerID/$LatestBlockHeight
[ ! -d "$RootDir" ] && mkdir -p $RootDir
#所有的扇区
AllSector="$RootDir/AllSector"
lotus state sectors $MinerID > $AllSector
#有效的扇区,如果该节点当前既没有错误扇区，也没有要恢复中的扇区和未证明的扇区，那么存活的扇区数量就是当前有效的扇区数量。否则还需要导出错误的扇区，恢复中的扇区和未证明的扇区，才是当前存活的扇区数量
ActiveSector="$RootDir/ActiveSector"
lotus state active-sectors $MinerID > $ActiveSector
#有效扇区的扇区状态
ActiveStateSector="$RootDir/ActiveStateSector"
#除去有效扇区之外的扇区
TerminatedSector="$RootDir/TerminatedSector"
sort $AllSector $ActiveSector $ActiveSector > $TerminatedSector
#除去有效扇区之外的扇区状态
TerminatedStateSector="$RootDir/TerminatedStateSector"
#所有的扇区信息
AllSectorInfo="$RootDir/AllSectorInfo"
#有效的扇区信息
ActiveSectorInfo="$RootDir/ActiveSectorInfo"
#终结的扇区信息
TerminatedSectorInfo="$RootDir/TerminatedSectorInfo"
[ ! -f "$AllSector" ] && echo "${AllSector} 不存在，请检查" && exit
[ ! -f "$ActiveSector" ] && echo "${ActiveSector} 不存在，请检查" && exit
#创建命名管道
mkfifo ch3
#创建文件描述符100，并关联到管道文件
exec 100<>ch3
#删除ch3文件防止影响下次的执行（删除后不影响文件描述符的使用）
rm -f ch3
#定义用于控制进程数量的变量
ProcessNub="50"
#通过文件描述符往命名管道中写入任意数据,用于控制进程数量
for i in `seq $ProcessNub`
do
	echo >&100
done
#遍历循环所有的扇区号，执行过程中保持同时有限制的进程个数并发执行
#首次并发执行限制的进程个数后，这时的命名管道ch3中数据量是0条，会造成阻塞
#read -u100表示每次从命名管道读取一行
#{...} &表示括号内的一组命令后台执行
#echo >&12表示当一个进程执行完成后会往命名管道里添加一行新的数据
#这时命名管道ch3中数据量是1条，会取消阻塞启动一个新的进程
#启动之后，ch3中数据量是0条，继续造成阻塞，当有命令执行完成后，就会有新的进程继续执行
#循环往复，直到执行循环结束
for i in `awk -F: '{print $1}' $ActiveSector`
do
	read -u100
	{
		lotus state sector $MinerID $i >> $ActiveStateSector
		echo >&100
	} &
done
#等待所有后台进程执行完成,才会继续执行下面的操作
wait
awk '/SectorNumber:/{$1="";SectorNumber=$0} /Activation:/{$1="";Activation=$0} /Expiration:/{$1="";Expiration=$0} /InitialPledge:/{$1="";InitialPledge=$0} /ExpectedDayReward:/{$1="";ExpectedDayReward=$0} /ExpectedStoragePledge:/{$1="";ExpectedStoragePledge=$0} /Partition:/ {print SectorNumber,Activation,Expiration,InitialPledge,ExpectedDayReward,ExpectedStoragePledge;SectorNumber="";Activation="";Expiration="";InitialPledge="";ExpectedDayReward="";ExpectedStoragePledge=""}' $ActiveStateSector |sed 's#^[ ]*##g' > $ActiveSectorInfo
for i in `awk -F: '{print $1}' $ActiveSectorOut`
do
	read -u100
	{
		lotus state sector $MinerID $i >> $TerminatedStateSector
		echo >&100
	} &
done
wait
awk '/SectorNumber:/{$1="";SectorNumber=$0} /Activation:/{$1="";Activation=$0} /Expiration:/{$1="";Expiration=$0} /InitialPledge:/{$1="";InitialPledge=$0} /ExpectedDayReward:/{$1="";ExpectedDayReward=$0} /ExpectedStoragePledge:/{$1="";ExpectedStoragePledge=$0} /Partition:/ {print SectorNumber,Activation,Expiration,InitialPledge,ExpectedDayReward,ExpectedStoragePledge;SectorNumber="";Activation="";Expiration="";InitialPledge="";ExpectedDayReward="";ExpectedStoragePledge=""}' $TerminatedStateSector |sed 's#^[ ]*##g' > $TerminatedSectorInfo
sort $TerminatedSectorInfo $ActiveSectorInfo |uniq > $AllSectorInfo
#排序统计
n=`wc -l < $AllSectorInfo`
m=`wc -l < $ActiveSectorInfo`
t=`wc -l < $TerminatedSectorInfo`
sort -nk1 $AllSectorInfo > ${AllSectorInfo}-$n && rm $AllSectorInfo
sort -nk1 $ActiveSectorInfo > ${ActiveSectorInfo}-$m && rm $ActiveSectorInfo
sort -nk1 $TerminatedSectorInfo > ${TerminatedSectorInfo}-$t && rm $TerminatedSectorInfo
#扇区的关键字段信息
sed -i "1iSector                       Activation                                        Expiration                          InitialPledge          ExpectedDayReward        ExpectedStoragePledge" ${AllSectorInfo}-$n 
sed -i "1iSector                       Activation                                        Expiration                          InitialPledge          ExpectedDayReward        ExpectedStoragePledge" ${ActiveSectorInfo}-$m
sed -i "1iSector                       Activation                                        Expiration                          InitialPledge          ExpectedDayReward        ExpectedStoragePledge" ${TerminatedSectorInfo}-$t
#结束时间
end=$(date +%s)
#耗时秒数
echo "Total execution time: $((end - start))s"
#关闭文件描述符的读和写
exec 100<&-
exec 100>&-
