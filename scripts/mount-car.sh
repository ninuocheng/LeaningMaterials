#!/bin/bash
iplist="""
172.25.9.64
172.25.9.66
172.25.9.67
172.25.9.68
172.25.9.69
172.25.9.70
172.25.9.90
172.25.9.96
172.25.9.97
172.25.10.17
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
   ansible P1 -m shell -a "mkdir -p /mnt/$ip/car && mount $ip:/opt/raid0/car /mnt/$ip/car"
   #ansible 172.25.9.93 -m shell -a "mkdir -p /mnt/$ip/car && mount $ip:/opt/raid0/car /mnt/$ip/car"
done
