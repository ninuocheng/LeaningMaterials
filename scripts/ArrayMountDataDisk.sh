#!/bin/bash
#数据盘大小
DiskSize=$1
[ -z "$DiskSize" ] && echo "没有给定数据盘大小的位置参数" && exit 1
[ $# -gt 1 ] && echo "位置参数数量有误" && exit 2
#导出数据盘盘符及uuid到文件
lsblk -o name,uuid,size|awk -v DiskSize=$DiskSize '$NF == DiskSize{print}' > DiskInfo
#初始化数组
Array1=()
#遍历数据盘的uuid,赋值到数组
for i in `awk '{print $2}' DiskInfo`
do
   Array1+=($i)              #追加元素到数组
done
#遍历数组的元素下标，执行相关的命令
for j in ${!Array1[*]}
do
   #创建挂载点
   [ ! -d "/mnt/${Array1[$j]}" ] && mkdir -p /mnt/${Array1[$j]}
   #挂载数据盘到相应的uuid目录，主要目的是更方便排查故障盘的uuid
   mount -U ${Array1[$j]} /mnt/${Array1[$j]}
done
