#!/bin/bash
#HostList=f01777770-p1
#HostList=f02836080-p1
#HostList=f0753213-p1
#HostList=f01777777-p1
#HostList=f02836091-p1
HostList=P1
[ -z $HostList ] && echo "没有给定主机组，请检查。" && exit
ansible $HostList -m shell -a 'pkill -9 lotus'
