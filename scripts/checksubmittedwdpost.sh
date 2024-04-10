#!/bin/bash
SubmittedWdpostFail=`grep -A1 'Submitted window post' /opt/raid0/lotusminer-window/lotusminer/logs |tail -n1|grep 'failed' |tail -n1|awk '{print $8}'`
SubmittedWdpostDeadline=`awk -F'[)| ]' '/Submitted window post: $SubmittedWdpostFail/{print $(NF-1)}' /opt/raid0/lotusminer-window/lotusminer/logs`
CurrentDeadline=`lotus-miner proving info|awk '/Deadline Index:/{print $NF}'`
if [ "$SubmittedWdpostDeadline" -eq "$CurrentDeadline" ];then
	`lotus-miner proving info|awk '/Deadline Close:/{print $3}'`
