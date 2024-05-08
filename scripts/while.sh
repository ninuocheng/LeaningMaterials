#!/bin/bash
while read User Pass
do
	useradd -m -s /bin/bash $User
	#echo $Pass |passwd --stdin $User #ubuntu不支持该命令
	echo $User:$Pass |chpasswd
done < user.conf
