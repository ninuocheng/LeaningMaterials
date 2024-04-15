#!/bin/bash
#HostList=f01777770-c2
#HostList=f02836080-c2
#HostList=f0753213-c2
#HostList=f01777777-c2
#HostList=f02836091-c2
HostList=C2
[ -z $HostList ] && echo "没有给定主机组，请检查。" && exit
ansible $HostList -m shell -a 'bash /opt/worker-1c2/start_1c2.sh removes=/opt/worker-1c2/start_1c2.sh'
sleep 2
ansible $HostList -m shell -a 'bash /opt/worker-2c2/start_2c2.sh removes=/opt/worker-2c2/start_2c2.sh'
sleep 2
ansible $HostList -m shell -a 'bash /opt/worker-3c2/start_3c2.sh removes=/opt/worker-3c2/start_3c2.sh'
sleep 2
ansible $HostList -m shell -a 'bash /opt/worker-4c2/start_4c2.sh removes=/opt/worker-4c2/start_4c2.sh'
