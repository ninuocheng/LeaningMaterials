#!/bin/bash
#数据盘盘符
#lsblk |awk '/14.6T/{print $1}' > 1.txt
awk '/14.6T/{print $1}' 1.txt > 2.txt
#遍历数据盘,赋值到数组
for i in `cat 2.txt`
do
   Array1+=($i)
done
#遍历数组的元素下标，执行相关的命令
for j in ${!Array1[*]}
do
   echo "mkdir -p /mnt/disk$[j+1]"  #创建挂载点
   echo "mount /dev/${Array1[$j]} /mnt/disk$[j+1]" #挂载数据盘
done
