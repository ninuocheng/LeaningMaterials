#!/bin/bash
for i in {a..z}; do lsblk |egrep -wi "sda${i}|sd${i}" |awk '/14.6T/{print $1}'; done > /root/device
	for s in `seq 36`
	do
	   mkdir -p /mnt/disk$s
	   for j in `cat /root/device`
	   do
		mkfs.xfs -f /dev/${j}1
		mount /dev/${j}1 /mnt/disk$s
		sed -i '1d' /root/device
		break
	   done
        done
#for i in {a..z}; do lsblk |egrep -wi "sda${i}1|sd${i}1" |awk '/14.6T/{print $1}'; done
