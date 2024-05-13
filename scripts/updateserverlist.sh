#!/bin/bash
#脚本的路径
ScriptDir=`dirname $(readlink -f $0)`
#机器列表
ServerList="机器列表-Sheet1.csv"
[ ! -f "$ScriptDir/$ServerList" ] && echo "$ScriptDir/$ServerList 不存在" && exit 1
awk '{print $1,$2,$3,$4,$5}' $ScriptDir/HKReplacelist |while read MinerID IP Port Area User
do
	Area=${Area%(*}
	User=${User%(*}
	[ "$MinerID" == "$Area" ] && MinerID=""
	[ "$MinerID" == "$User" ] && MinerID=""
	[ "$Area" == "$User" ] && User=""
	ReplaceIP=$(awk -F',' '/'$MinerID'/&&/'$Area'/&&/'$User'/ {print $1}' $ScriptDir/$ServerList)
	ReplacePort=`awk -F',' '/'$MinerID'/&&/'$Area'/&&/'$User'/ {print $2}' $ScriptDir/$ServerList`
        sed -i -e '/'${MinerID}'.*'${Area}'.*'${User}'/s#'$ReplaceIP'#'$IP'#1' -e  '/'${MinerID}'.*'${Area}'.*'${User}'/s#'$ReplacePort'#'$Port'#2' $ScriptDir/$ServerList
done
#备份时间
BakTime=`date +%Y%m%d%H%M%S`
#备份目录
BakDir=$ScriptDir/bak
[ ! -d "$BakDir" ] && mkdir -p $BakDir
#备份之前的列表信息
ListInfo="$ScriptDir/ListInfo"
[ -s "$ListInfo" ] && mv $ListInfo $BakDir/ListInfo-$BakTime
#重新排序的列表信息
cat $ScriptDir/$ServerList |tr -s ',' ' ' |awk 'NR>1{print $1,$2,$3,$(NF-9),$(NF-8),$(NF-7),$(NF-6),$(NF-5),$(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF}'|column -t > $ListInfo
[ ! -s "$ListInfo" ] && echo "$ListInfo 输出内容为空" && exit 3
awk 'BEGIN{print "[alllist]"}''{print $3"-"$1"-"$2,"ansible_ssh_host="$1,"ansible_ssh_port="$2,"#"$(NF-9),$(NF-8),$(NF-7),$(NF-6),$(NF-5),$(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF}' $ListInfo |column -t > allhosts
awk 'BEGIN{print "[gpulist]"}''$(NF-7) != 0{print $3"-"$1"-"$2,"ansible_ssh_host="$1,"ansible_ssh_port="$2,"#"$(NF-9),$(NF-8),$(NF-7),$(NF-6),$(NF-5),$(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF}' $ListInfo |column -t > gpuhosts
awk 'BEGIN{print "[lotuslist]"}''$(NF-3) != 0{print $3"-"$1"-"$2,"ansible_ssh_host="$1,"ansible_ssh_port="$2,"#"$(NF-9),$(NF-8),$(NF-7),$(NF-6),$(NF-5),$(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF}' $ListInfo |column -t > lotushosts
awk 'BEGIN{print "[windowlist]"}''$(NF-1) != 0{print $3,"ansible_ssh_host="$1,"ansible_ssh_port="$2,"#"$(NF-9),$(NF-8),$(NF-7),$(NF-6),$(NF-5),$(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF}' $ListInfo |column -t > windowhosts
awk 'BEGIN{print "[winninglist]"}''$(NF-2) != 0{print $3,"ansible_ssh_host="$1,"ansible_ssh_port="$2,"#"$(NF-9),$(NF-8),$(NF-7),$(NF-6),$(NF-5),$(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF}' $ListInfo |column -t > winninghosts
awk 'BEGIN{print "[sealinglist]"}''$NF != 0{print $3"-"$1"-"$2,"ansible_ssh_host="$1,"ansible_ssh_port="$2,"#"$(NF-9),$(NF-8),$(NF-7),$(NF-6),$(NF-5),$(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF}' $ListInfo |column -t > sealinghosts
