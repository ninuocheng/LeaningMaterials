#!/bin/bash
HostFile="/root/.guozhichao/MachineList/0511/lotushosts"
[ ! -f $HostFile ] && echo "$HostFile 不存在，请检查。" && exit
Parameter="$1"
WalletID=${Parameter:?123}
ansible -i $HostFile lotuslist -m shell -a "export LOTUS_PATH=/opt/raid0/lotus ; if lotus sync wait &>/dev/null ;then lotus wallet list --id |grep $WalletID 2>/dev/null; else export LOTUS_PATH=/opt/lotus/lotus; lotus wallet list --id |grep $WalletID 2>/dev/null; fi"
