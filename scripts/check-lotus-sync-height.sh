#!/bin/bash
HostFile="/root/.guozhichao/MachineList/0330/lotushosts"
[ ! -f $HostFile ] && echo "$HostFile 不存在，请检查。" && exit
ansible -i $HostFile lotuslist -m shell -a 'export LOTUS_PATH=/opt/raid0/lotus ; if lotus sync wait 2>/dev/null ;then sleep 1s; else export LOTUS_PATH=/opt/lotus/lotus; lotus sync wait 2>/dev/null; fi'
