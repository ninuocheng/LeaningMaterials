#!/bin/bash
#脚本的路径
ScriptDir=`dirname $(readlink -f $0)`
#机器列表
ServerList="机器列表-Sheet1.csv"
#更新列表
UpdateList="updatelist"
[ ! -f "$ScriptDir/$ServerList" ] && echo "$ScriptDir/$ServerList 不存在" && exit 1
[ ! -f "$ScriptDir/$UpdateList" ] && echo "$ScriptDir/$UpdateList 不存在" && exit 2
#遍历更新的列表
awk '{print $1,$2,$3,$4,$5}' $ScriptDir/$UpdateList |while read MinerID IP Port Area User
do
	#字段中如果有特殊符号，需要去掉，不然会影响awk匹配异常
	Area=${Area%(*}
	User=${User%(*}
	#如果字段中有相同的，需要做如下操作，不然会影响sed匹配有问题
	[ "$MinerID" == "$Area" ] && MinerID=""
	[ "$MinerID" == "$User" ] && MinerID=""
	[ "$Area" == "$User" ] && User=""
	#sed匹配的字段
	MatchingString="${MinerID}.*${Area}.*${User}"
	#awk获取匹配到的字段
	#ReplaceIP=$(awk -F',' '/'$MinerID'/&&/'$Area'/&&/'$User'/{print $1}' $ScriptDir/$ServerList)
	#ReplacePort=`awk -F',' '/'$MinerID'/&&/'$Area'/&&/'$User'/{print $2}' $ScriptDir/$ServerList`
	ReplaceIP=$(awk -F',' '/'$MatchingString'/{print $1}' $ScriptDir/$ServerList)
	ReplacePort=`awk -F',' '/'$MatchingString'/{print $2}' $ScriptDir/$ServerList`
	#检查匹配的字段输出是否为空
        #[ -z "$ReplaceIP" -o -z "$ReplacePort" ] && echo "awk -F',' '/'$MinerID'/&&/'$Area'/&&/'$User'/{print \$1,\$2}' $ScriptDir/$ServerList 输出为空" && continue
        [ -z "$ReplaceIP" -o -z "$ReplacePort" ] && echo "awk -F',' '/'$MinerID'.*'$Area'.*'$User'/{print \$1,\$2}' $ScriptDir/$ServerList 输出为空" && continue
	#检查如果更新过的就跳过
	[ "$ReplaceIP" == "$IP" -a "$ReplacePort" == "$Port" ] && echo "$MatchingString $ReplaceIP/$ReplacePort 已更新" && continue
	#sed更新匹配到的字段
        sed -i -e '/'$MatchingString'/s#'$ReplaceIP'#'$IP'#1' -e  '/'$MatchingString'/s#'$ReplacePort'#'$Port'#2' $ScriptDir/$ServerList
	#输出更新前后对应的字段
        echo "$MatchingString    $ReplaceIP/$ReplacePort    ----->   $IP/$Port"
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
#更新自定义的hosts
awk 'BEGIN{print "[alllist]"}''{print $3"-"$1"-"$2,"ansible_ssh_host="$1,"ansible_ssh_port="$2,"#"$(NF-9),$(NF-8),$(NF-7),$(NF-6),$(NF-5),$(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF}' $ListInfo |column -t > allhosts
awk 'BEGIN{print "[gpulist]"}''$(NF-7) != 0{print $3"-"$1"-"$2,"ansible_ssh_host="$1,"ansible_ssh_port="$2,"#"$(NF-9),$(NF-8),$(NF-7),$(NF-6),$(NF-5),$(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF}' $ListInfo |column -t > gpuhosts
awk 'BEGIN{print "[lotuslist]"}''$(NF-3) != 0{print $3"-"$1"-"$2,"ansible_ssh_host="$1,"ansible_ssh_port="$2,"#"$(NF-9),$(NF-8),$(NF-7),$(NF-6),$(NF-5),$(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF}' $ListInfo |column -t > lotushosts
awk 'BEGIN{print "[windowlist]"}''$(NF-1) != 0{print $3,"ansible_ssh_host="$1,"ansible_ssh_port="$2,"#"$(NF-9),$(NF-8),$(NF-7),$(NF-6),$(NF-5),$(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF}' $ListInfo |column -t > windowhosts
awk 'BEGIN{print "[winninglist]"}''$(NF-2) != 0{print $3,"ansible_ssh_host="$1,"ansible_ssh_port="$2,"#"$(NF-9),$(NF-8),$(NF-7),$(NF-6),$(NF-5),$(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF}' $ListInfo |column -t > winninghosts
awk 'BEGIN{print "[sealinglist]"}''$NF != 0{print $3"-"$1"-"$2,"ansible_ssh_host="$1,"ansible_ssh_port="$2,"#"$(NF-9),$(NF-8),$(NF-7),$(NF-6),$(NF-5),$(NF-4),$(NF-3),$(NF-2),$(NF-1),$NF}' $ListInfo |column -t > sealinghosts
