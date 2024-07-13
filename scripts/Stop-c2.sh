#!/bin/bash
#HostList=f01777770-c2
#HostList=f02836080-c2
#HostList=f0753213-c2
#HostList=f01777777-c2
#HostList=f02836091-c2
HostList=C2
[ -z $HostList ] && echo "没有给定主机组，请检查。" && exit
ansible $HostList -m shell -a 'pkill -9 lotus'
