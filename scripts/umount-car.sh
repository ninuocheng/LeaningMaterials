#!/bin/bash
iplist="""
172.25.10.2
172.25.9.64
172.25.9.66
172.25.9.67
172.25.9.68
172.25.9.69
172.25.9.70
172.25.9.90
172.25.9.93
172.25.9.96
172.25.9.97
172.25.10.15
172.25.10.17
172.25.10.19
172.25.10.25
172.25.11.35
172.25.11.36
172.25.11.37
172.25.11.38
172.25.11.41
172.25.11.42
"""
for ip in $iplist
do
   ansible P1 -m shell -a "umount -fl /mnt/$ip/car"
   ansible P1 -m mount -a "src=$ip:/opt/raid0/car path=/mnt/$ip/car fstype=nfs opts=noatime,_netdev state=absent"
done
