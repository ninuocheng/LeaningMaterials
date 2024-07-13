#!/bin/bash
unset LOTUS_PATH LOTUS_MINER_PATH
unset FULLNODE_API_INFO MINER_API_INFO
[ -f /opt/raid0/profile ] && source /opt/raid0/profile
for i in $@
do
     lotus wallet list -id |egrep "$i"
done
