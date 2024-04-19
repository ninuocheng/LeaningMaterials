#!/bin/bash
#设置时区和时间同步
timedatectl set-timezone Asia/Shanghai
(crontab -l;echo "*/1 *  *  *  *  /usr/sbin/ntpdate cn.pool.ntp.org &>/dev/null") |crontab
