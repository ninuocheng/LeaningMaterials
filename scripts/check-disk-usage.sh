#!/bin/bash
#df -h |awk 'NR>1{print $5,$6}' > /tmp/usage.txt
df -h |grep -v car|awk '/\/opt\/raid0/{print $5,$6}' > /tmp/usage.txt
while read line
do
	usage=$(echo $line |awk '{print $1}' |tr -d '%')
	partition=$(echo $line |awk '{print $2}')
	if [ "$usage" -gt 80 ];then
		echo "ALERT: Disk usage of partition $partition is above $usage"
	fi
done < /tmp/usage.txt
