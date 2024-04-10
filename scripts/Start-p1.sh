#!/bin/bash
#HostList=f01777770-p1
#HostList=f02836080-p1
#HostList=f0753213-p1
#HostList=f01777777-p1
#HostList=f02836091-p1
HostList=P1
[ -z $HostList ] && echo "没有给定主机组，请检查。" && exit
#ansible $HostList -m shell -a 'bash /opt/lotusworker/worker-p1/start_p1.sh removes=/opt/lotusworker/worker-p1/start_p1.sh'
ansible $HostList -m shell -a 'bash /opt/lotusworker/worker-p2/start_p2.sh removes=/opt/lotusworker/worker-p2/start_p2.sh'
sleep 1
ansible $HostList -m shell -a 'bash /opt/lotusworker/worker-apx/start_apx.sh removes=/opt/lotusworker/worker-apx/start_apx.sh'
