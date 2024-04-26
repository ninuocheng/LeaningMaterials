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
RootDir=$ScriptDir/$MinerID/Terminated/$LatestBlockHeight
[ ! -d "$RootDir" ] && mkdir -p $RootDir
#所有的扇区
AllSector="$RootDir/AllSector"
lotus state sectors $MinerID > $AllSector
#所有的扇区ID
AllSectorID="$RootDir/AllSectorID"
awk -F: '{print $1}' $AllSector > $AllSectorID
rm $AllSector
#有效的扇区,如果该节点当前既没有错误扇区，也没有要恢复中的扇区和未证明的扇区，那么存活的扇区数量就是当前有效的扇区数量。否则还需要导出错误的扇区，恢复中的扇区和未证明的扇区，才是当前存活的扇区数量
EffectiveSector="$RootDir/EffectiveSector"
lotus state active-sectors $MinerID > $EffectiveSector
#有效的扇区ID
EffectiveSectorID="$RootDir/EffectiveSectorID"
awk -F: '{print $1}' $EffectiveSector > $EffectiveSectorID
rm $EffectiveSector
#存活的扇区
ActiveSectorID="$RootDir/ActiveSectorID"
#存活中的有效之外扇区ID,如果不考虑当前链上未证明的扇区，即错误扇区ID
FaultSectorID="$RootDir/FaultSectorID"
#准备的错误扇区
PrepareFaultSectorID="$ScriptDir/$MinerID/PrepareFaultSectorID"
#所有扇区中的存活扇区之外的扇区才是终止掉的扇区
TerminatedSectorID="$RootDir/TerminatedSectorID"   #终止掉的扇区
if [ -f "$PrepareFaultSectorID" ];then
        mv $PrepareFaultSectorID $FaultSectorID
	sort $FaultSectorID $EffectiveSectorID |uniq > $ActiveSectorID
	sort $AllSectorID $ActiveSectorID $ActiveSectorID |uniq -u > $TerminatedSectorID
else
	mv $EffectiveSectorID $ActiveSectorID
	sort $AllSectorID $ActiveSectorID $ActiveSectorID |uniq -u > $TerminatedSectorID
fi
#终结的扇区关键信息
TerminatedSectorKeyInfo="$RootDir/TerminatedSectorKeyInfo"
#更新终结的扇区导出信息
TerminatedSectorUpdateInfo="$RootDir/TerminatedSectorUpdateInfo"
#终结的扇区信息
TerminatedSectorInfo="$RootDir/TerminatedSectorInfo"
[ ! -f "$TerminatedSectorID" ] && echo "${TerminatedSectorID} 不存在，请检查" && exit
#线程数量
thread_nub="60"
#创建命名管道
mkfifo ch3
#创建文件描述符100，并关联到管道文件
exec 100<>ch3
#删除ch3文件防止影响下次的执行（删除后不影响文件描述符的使用）
rm -f ch3
#通过文件描述符往命名管道中写入任意数据,用于控制进程数量
for ((i=0;i<$thread_nub;i++))
do
	echo >&100
done
#遍历循环扇区号，执行过程中保持同时有限制的进程个数并发执行
#首次并发执行限制的进程个数后，这时的命名管道ch3中数据量是0条，会造成阻塞
#read -u100表示每次从命名管道读取一行
#{...} &表示括号内的一组命令后台执行
#echo >&12表示当一个进程执行完成后会往命名管道里添加一行新的数据
#这时命名管道ch3中数据量是1条，会取消阻塞启动一个新的进程
#启动之后，ch3中数据量是0条，继续造成阻塞，当有命令执行完成后，就会有新的进程继续执行
#循环往复，直到执行循环结束
while read line
do
	read -u100
	{
		StateSector=`lotus state sector $MinerID $line 2>/dev/null`
		echo $StateSector >> $TerminatedSectorKeyInfo
	        echo >&100
	} &
done < $TerminatedSectorID
#等待所有后台进程执行完成,才会继续执行下面的操作
wait
if [ -f "$TerminatedSectorKeyInfo" ];then
	awk -F'[]|[]' '{print $1,$NF}' $TerminatedSectorKeyInfo > $TerminatedSectorUpdateInfo
	awk '{$1=$3=$4=$5=$6=$7=$NF=$(NF-1)=$(NF-2)=$(NF-3)=$(NF-13)=$(NF-14)=$(NF-15)=$(NF-16)="";print}' $TerminatedSectorUpdateInfo > $TerminatedSectorInfo
	t=`wc -l < $TerminatedSectorInfo`
	sort -nk1 $TerminatedSectorInfo > ${TerminatedSectorInfo}-$t && rm $TerminatedSectorInfo $TerminatedSectorKeyInfo $TerminatedSectorUpdateInfo
fi
#结束时间
end=$(date +%s)
#耗时秒数
echo "Total execution time: $((end - start))s"
#关闭文件描述符的读和写
exec 100<&-
exec 100>&-
exit 77
