#推荐以序列号为挂载点，目的是更方便查找故障盘uuid对应的序列号
#以自定义的挂载点为例
#临时挂载，grep的作用是满足要挂载的数据盘，目的就是不影响awk的行号NR，推荐方法一
#方法一
lsblk -o name,uuid,serial,fstype,size |grep -w 9.1T |awk -v mountpoint="/mnt/data" '{print "mkdir -p",mountpoint NR,"&& mount -U",$2,mountpoint NR}' |bash
#方法二
lsblk -o name,uuid,serial,fstype,size |grep -w 9.1T |awk -v mountpoint="/mnt/data" '{print "mkdir -p",mountpoint NR,"&& mount /dev/disk/by-uuid/"$2,mountpoint NR}' |bash
#方法三
lsblk -o name,uuid,serial,fstype,size |grep -w 9.1T |awk -v mountpoint="/mnt/data" '{print "mkdir -p",mountpoint NR,"&& mount /dev/"$1,mountpoint NR}' |bash

#写入配置永久挂载
#方法一
lsblk -o name,uuid,serial,fstype,size |grep -w 9.1T |awk -v mountpoint="/mnt/data" '{print "UUID="$2,mountpoint NR,$4,"defaults 0 0"}' >> /etc/fstab
#方法二
lsblk -o name,uuid,serial,fstype,size |grep -w 9.1T |awk -v mountpoint="/mnt/data" '{print "/dev/disk/by-uuid/"$2,mountpoint NR,$4,"defaults 0 0"}' >> /etc/fstab
#方法三
lsblk -o name,uuid,serial,fstype,size |grep -w 9.1T |awk -v mountpoint="/mnt/data" '{print "/dev/"$1,mountpoint NR,$4,"defaults 0 0"}' >> /etc/fstab


#以序列号做为挂载点为例
#临时挂载，没有用到awk的行号，所以就以awk的条件作为要挂载的数据盘，推荐方法一
#方法一
lsblk -o name,uuid,serial,fstype,size |awk -v mountpoint="/mnt/" '$5=="9.1T"{print "mkdir -p",mountpoint$3,"&& mount -U",$2,mountpoint$3}' |bash
#方法二
lsblk -o name,uuid,serial,fstype,size |awk -v mountpoint="/mnt/" '$5=="9.1T"{print "mkdir -p",mountpoint$3,"&& mount /dev/disk/by-uuid/"$2,mountpoint$3}' |bash
#方法三
lsblk -o name,uuid,serial,fstype,size |awk -v mountpoint="/mnt/" '$5=="9.1T"{print "mkdir -p",mountpoint$3,"&& mount /dev/"$1,mountpoint$3}' |bash
#写入配置永久挂载
#方法一
lsblk -o name,uuid,serial,fstype,size |awk -v mountpoint="/mnt/" '$5=="9.1T"{print "UUID="$2,mountpoint$3,$4,"defaults 0 0"}' >> /etc/fstab
#方法二
lsblk -o name,uuid,serial,fstype,size |awk -v mountpoint="/mnt/" '$5=="9.1T"{print "/dev/disk/by-uuid/"$2,mountpoint$3,$4,"defaults 0 0"}' >> /etc/fstab
#方法三
lsblk -o name,uuid,serial,fstype,size |awk -v mountpoint="/mnt/" '$5=="9.1T"{print "/dev/"$1,mountpoint$3,$4,"defaults 0 0"}' >> /etc/fstab
