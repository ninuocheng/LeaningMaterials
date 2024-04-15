#!/bin/bash
for ip in `cat iplist`
do
( ping -c1 $ip
      if [ $? -eq 0 ];then
         echo "$ip is alive" >> alive
      else
         echo "$ip is unreached" >> unreached
      fi
) &
done
