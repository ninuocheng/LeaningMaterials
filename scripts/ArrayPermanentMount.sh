#!/bin/bash
#脚本的路径
ScriptDir="/root/.gzc"
#备份时间
BakTime=$(date +%Y%m%d-%H%M%S)
#数据盘大小
DiskSize=$1
[ -z "$DiskSize" ] && echo "没有给定数据盘大小的位置参数" && exit 1
[ $# -gt 1 ] && echo "位置参数数量有误" && exit 2
#备份之前的导出文件
BakDir="$ScriptDir/bak"
[ ! -d "$BakDir" ] && mkdir -p $BakDir
DiskInfo="$ScriptDir/DiskInfo"
[ -f "$DiskInfo" ] && mv $DiskInfo $BakDir/DiskInfo-$BakTime
#导出数据盘盘符及uuid到文件
lsblk -o name,uuid,serial,fstype,size|awk -v DiskSize=$DiskSize '$NF == DiskSize'|column -t > $DiskInfo
#定义关联数组
declare -A Array1
declare -A Array2
#遍历数据盘的uuid,赋值到数组
while read Name UUID Serial Fstype Size
do
   Array1["$UUID"]="$Serial"              #赋值序列号到数组
   Array2["$UUID"]="$Fstype"              #赋值文件类型到数组
done < $DiskInfo
#遍历数组的索引值，执行创建、挂载等相关的命令
for j in ${!Array1[*]}
do
   #创建挂载点
   [ ! -d "/mnt/${Array1[$j]}" ] && mkdir -p /mnt/${Array1[$j]}
   #以数据盘唯一的标识符UUID挂载到相对应的序列号命名的目录，主要目的是更方便查找故障盘uuid对应的序列号
   echo "UUID=$j /mnt/${Array1[$j]} ${Array2[$j]} defaults 0 0" >> /etc/fstab
done
