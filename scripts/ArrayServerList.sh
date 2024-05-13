#!/bin/bash
#脚本的路径
ScriptDir=`dirname $(readlink -f $0)`
#机器列表
ServerList="机器列表-Sheet1.csv"
[ ! -f "$ScriptDir/$ServerList" ] && echo "$ScriptDir/$ServerList 不存在" && exit 1
#定义关联数组
declare -A ReplaceMinerIDArray
declare -A ReplaceIPArray
declare -A ReplacePortArray
declare -A ReplaceAreaArray
declare -A ReplaceUserArray
#遍历准备要更新的列表，赋值关键字段到数组
while read MinerID IP Port Area User GPUNum SytemDiskUse NVMEUse GPUCk LotusProcess WinningProcess WindowProcess SealingProcess
do
	#字段中如果有特殊符号，需要去掉，不然会影响awk匹配异常
	Area=${Area%(*}
        User=${User%(*}
	#如果字段中有相同的，需要做如下操作，不然会影响sed匹配有问题
        [ "$MinerID" == "$Area" ] && MinerID=""
        [ "$MinerID" == "$User" ] && MinerID=""
        [ "$Area" == "$User" ] && User=""
	#定义元素的索引值
	MatchingString="${MinerID}'.*'${Area}'.*'${User}"
	#赋值到数组
        ReplaceMinerIDArray["$MatchingString"]="$MinerID"
        ReplaceIPArray["$MatchingString"]="$IP"
        ReplacePortArray["$MatchingString"]="$Port"
        ReplaceAreaArray["$MatchingString"]="$Area"
        ReplaceUserArray["$MatchingString"]="$User"
done < $ScriptDir/HKReplacelist
#遍历数组的索引,更新列表
for i in ${!ReplaceIPArray[*]}
do
	#定义数组的元素值到变量
	MinerID=${ReplaceMinerIDArray[$i]}
	Area=${ReplaceAreaArray[$i]}
	User=${ReplaceUserArray[$i]}
	#awk获取匹配的字段到变量
	ReplaceIP=`awk -F',' '/'$MinerID'/&&/'$Area'/&&/'$User'/{print $1}' $ScriptDir/$ServerList`
	ReplacePort=`awk -F',' '/'$MinerID'/&&/'$Area'/&&/'$User'/{print $2}' $ScriptDir/$ServerList`
	#检查如果更新过的就跳过
        [ "$ReplaceIP" == "${ReplaceIPArray[$i]}" -a "$ReplacePort" == "${ReplacePortArray[$i]}" ] && echo "$i $ReplaceIP/$ReplacePort 已更新" && continue
	#sed更新匹配的行
        sed -i -e '/'$i'/s#'$ReplaceIP'#'${ReplaceIPArray[$i]}'#1' -e  '/'$i'/s#'$ReplacePort'#'${ReplacePortArray[$i]}'#2' $ScriptDir/$ServerList
	#输出更新前后对应的字段
	echo "$i     $ReplaceIP/$ReplacePort  ---> ${ReplaceIPArray[$i]}/${ReplacePortArray[$i]}"
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
#更新自定义的hosts
awk 'BEGIN{print "[alllist]"}''{print}' alllist |column -t > allhosts
awk 'BEGIN{print "[gpulist]"}''{print}' gpulist |column -t > gpuhosts
awk 'BEGIN{print "[lotuslist]"}''{print}' lotuslist |column -t > lotushosts
awk 'BEGIN{print "[winninglist]"}''{print}' winninglist |column -t > winninghosts
awk 'BEGIN{print "[windowlist]"}''{print}' windowlist |column -t > windowhosts
