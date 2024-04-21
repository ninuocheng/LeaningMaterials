#!/bin/bash
#数据盘数量，如果数量少了，说明有数据盘掉了，尝试重启或是关机拔插
lsblk |grep -w 9.1T -c
#数据盘挂载数量.如果数量少了，说明有挂载的数据盘异常，需要关机拔插
df -h|grep -w 9.1T -c
#查看数据盘对应的序列号
lsblk -o name,size,serial,mountpoint |grep -w 9.1T
