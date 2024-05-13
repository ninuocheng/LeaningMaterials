#!/bin/bash
#脚本的路径
ScriptDir=`dirname $(readlink -f $0)`
#机器列表
ServerList="机器列表-Sheet1.csv"
[ ! -f "$ScriptDir/$ServerList" ] && echo "$ScriptDir/$ServerList 不存在" && exit 1
declare -A ReplaceMinerIDArray
declare -A ReplaceIPArray
declare -A ReplacePortArray
declare -A ReplaceAreaArray
declare -A ReplaceUserArray
while read MinerID IP Port Area User GPUNum SytemDiskUse NVMEUse GPUCk LotusProcess WinningProcess WindowProcess SealingProcess
do
	Area=${Area%(*}
        User=${User%(*}
        [ "$MinerID" == "$Area" ] && MinerID=""
        [ "$MinerID" == "$User" ] && MinerID=""
        [ "$Area" == "$User" ] && User=""
        ReplaceMinerIDArray["${MinerID}.*${Area}.*$User"]="$MinerID"
        ReplaceIPArray["${MinerID}.*${Area}.*$User"]="$IP"
        ReplacePortArray["${MinerID}.*${Area}.*$User"]="$Port"
        ReplaceAreaArray["${MinerID}.*${Area}.*$User"]="$Area"
        ReplaceUserArray["${MinerID}.*${Area}.*$User"]="$User"
done < $ScriptDir/HKReplacelist
for i in ${!ReplaceIPArray[*]}
do
	MinerID=${ReplaceMinerIDArray[$i]}
	Area=${ReplaceAreaArray[$i]}
	User=${ReplaceUserArray[$i]}
	ReplaceIP=`awk -F',' '/'$MinerID'/&&/'$Area'/&&/'$User'/{print $1}' $ScriptDir/$ServerList`
	ReplacePort=`awk -F',' '/'$MinerID'/&&/'$Area'/&&/'$User'/{print $2}' $ScriptDir/$ServerList`
        sed -i -e '/'$i'/s#'$ReplaceIP'#'${ReplaceIPArray[$i]}'#1' -e  '/'$i'/s#'$ReplacePort'#'${ReplacePortArray[$i]}'#2' $ScriptDir/$ServerList
done
#备份时间
BakTime=`date +%Y%m%d%H%M%S`
#备份目录
BakDir=$ScriptDir/bak
[ ! -d "$BakDir" ] && mkdir -p $BakDir
#备份之前的列表信息
ListInfo="$ScriptDir/ListInfo"
[ -s "$ListInfo" ] && mv $ListInfo $BakDir/ListInfo-$BakTime
#重新排序的列表信息
cat $ScriptDir/$ServerList |tr -s ',' ' ' |awk 'NR>1{print $1,$2,$3,$(NF-9),$(NF-8),$(NF-7),$(NF-6),$(NF-5),$(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF}'|column -t > $ListInfo
[ ! -s "$ListInfo" ] && echo "$ListInfo 输出内容为空" && exit 3
#定义关联数组
unset AllArray GPUCkArray LotusProcessArray WinningProcessArray WindowProcessArray
declare -A AllArray
declare -A GPUCKArray
declare -A LotusProcessArray
declare -A WinningProcessArray
declare -A WindowProcessArray
#遍历列表信息，赋值到数组
while read IP Port MinerID Area User GPUNum SytemDiskUse NVMEUse GPUCk LotusProcess WinningProcess WindowProcess SealingProcess
do
    AllArray["$MinerID-$IP-$Port"]="${MinerID}-$IP-$Port-$Area-$User ansible_ssh_host=$IP ansible_ssh_port=$Port #$Area $User $GPUNum $SytemDiskUse $NVMEUse $GPUCk $LotusProcess $WinningProcess $WindowProcess $SealingProcess"
    GPUCKArray["$MinerID-$IP-$Port"]="$GPUCk"
    LotusProcessArray["$MinerID-$IP-$Port"]="$LotusProcess"
    WinningProcessArray["$MinerID-$IP-$Port"]="$WinningProcess"
    WindowProcessArray["$MinerID-$IP-$Port"]="$WindowProcess"
done < $ListInfo
> alllist
> gpulist
> lotuslist
> winninglist
> windowlist
#遍历数组的索引,重定向到文件
for i in ${!AllArray[@]}
do
  echo ${AllArray[$i]} >> alllist
  if [ ${GPUCKArray[$i]} -gt 0 ];then
      echo ${AllArray[$i]} >> gpulist
  fi
  if [ ${LotusProcessArray[$i]} -gt 0 ];then
      echo ${AllArray[$i]} >> lotuslist
  fi
  if [ ${WinningProcessArray[$i]} -gt 0 ];then
      echo ${AllArray[$i]} >> winninglist
  fi
  if [ ${WindowProcessArray[$i]} -gt 0 ];then
      echo ${AllArray[$i]} >> windowlist
  fi
done
awk 'BEGIN{print "[alllist]"}''{print}' alllist |column -t > allhosts
awk 'BEGIN{print "[gpulist]"}''{print}' gpulist |column -t > gpuhosts
awk 'BEGIN{print "[lotuslist]"}''{print}' lotuslist |column -t > lotushosts
awk 'BEGIN{print "[winninglist]"}''{print}' winninglist |column -t > winninghosts
awk 'BEGIN{print "[windowlist]"}''{print}' windowlist |column -t > windowhosts
