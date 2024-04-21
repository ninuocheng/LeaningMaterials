# /etc/fstab: static file system information.
#
# Use blkid to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/ubuntu-vg/lv-0 during curtin installation
/dev/disk/by-uuid/ff8ece62-fb7d-4bac-a810-dc7fef25c6b8 /opt/raid0 xfs defaults 0 0
/dev/disk/by-uuid/e9ac98a9-6877-47a1-9de6-5c9ca9e2e56a / xfs defaults 0 0 
#封装存储落盘
172.25.11.1,172.25.11.2,172.25.11.5:6789:/ /ceph/7pDC ceph name=fsbuser,secret=AQB1j5lkMC8KMRAAz1JsHb6Z0bwXP3KGELUvUw==,noatime,_netdev 0 0
#存储car
172.25.9.50,172.25.9.51,172.25.9.52:6789:/ /carfile ceph name=fsuser,secret=AQDOI7ljg4h0LBAAn87dGxr/K7ZHogd3JDouLA==,noatime,_netdev 0 0
#XC1的car
172.26.2.10:/opt/raid0/car     /mnt/172.26.2.10/car     nfs noatime,_netdev 0 0
172.26.2.12:/opt/raid0/car     /mnt/172.26.2.12/car     nfs noatime,_netdev 0 0
172.26.2.11:/opt/raid0/car     /mnt/172.26.2.11/car     nfs noatime,_netdev 0 0
172.26.2.1:/opt/raid0/car     /mnt/172.26.2.1/car     nfs noatime,_netdev 0 0
172.26.2.6:/opt/raid0/car     /mnt/172.26.2.6/car     nfs noatime,_netdev 0 0
#XC2的car
172.25.10.17:/opt/raid0/car     /mnt/172.25.10.17/car     nfs noatime,_netdev 0 0
172.26.1.49:/opt/raid0/car     /mnt/172.26.1.49/car     nfs noatime,_netdev 0 0
172.26.1.50:/opt/raid0/car     /mnt/172.26.1.50/car     nfs noatime,_netdev 0 0
172.26.2.27:/opt/raid0/car     /mnt/172.26.2.27/car     nfs noatime,_netdev 0 0
172.26.2.14:/opt/raid0/car     /mnt/172.26.2.14/car     nfs noatime,_netdev 0 0
#XC3的car
172.25.10.3:/opt/raid0/car     /mnt/172.25.10.3/car     nfs noatime,_netdev 0 0
172.26.2.16:/opt/raid0/car     /mnt/172.26.2.16/car     nfs noatime,_netdev 0 0
172.26.2.18:/opt/raid0/car     /mnt/172.26.2.18/car     nfs noatime,_netdev 0 0
172.26.2.15:/opt/raid0/car     /mnt/172.26.2.15/car     nfs noatime,_netdev 0 0
