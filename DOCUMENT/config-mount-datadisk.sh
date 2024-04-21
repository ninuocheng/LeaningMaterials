#!/bin/bash
#设置时区
timedatectl set-timezone Asia/Shanghai
#数据盘符
lsblk |grep -w 14.6T |awk '{print $1}' > 1.txt
#数据盘符相对应的uuid路径
>2.txt
for i in `cat 1.txt`; do ls -l /dev/disk/by-uuid |grep -w $i |awk '{print "/dev/disk/by-uuid/"$9}' >> 2.txt; done
#查看数据盘的uuid相对应的盘符
awk '{print "ls -l",$1}' 2.txt |bash
#写入配置并挂载数据盘
n=0
for i in `cat 2.txt`
do
    if ls $i >/dev/null;then
       let n++
       mkdir -p /mnt/data$n
       echo "$i /mnt/data$n xfs noatime 0 0" >> /etc/fstab
    fi
done
mount -a
