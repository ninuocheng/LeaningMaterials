#!/bin/bash
#grep 2023-09-17T  /opt/raid0/lotusminer-winning/lotusminer/log* -r   | grep    '"isEligible": true, "isWinner": '   |grep -i error -c
#grep 2023-09-17T  /opt/raid0/lotusminer-winning/lotusminer/log* -r   | grep    '"isEligible": true, "isWinner": '  -c
grep 2023-10-13T  /opt/raid0/lotusminer-winning/lotusminer/log* -r   | grep    '"isEligible": true, "isWinner": ' |awk '{print $9,$10}' |sort |uniq -c |sort |awk 'BEGIN{print "抽奖的次数    当前的高度"}''$1 > 1{print}' |column -t
