#!/bin/bash
#自定义的位置参数未初始化，会异常退出
set -o nounset
#返回非真的值，会异常退出
set -o errexit
#false|true被认为执行失败，会异常退出
set -o pipefail
BakTime=`date +%Y%m%d%H%M%S`
KeyRootDir=/root/.key
NewKeyDir=${BakTime}_new
BakKeyDir=${BakTime}_old
StoreList=/root/.gzc/${BakTime}_StoreList
mkdir -p $KeyRootDir/$NewKeyDir
ssh-keygen -N "" -b 4096 -t rsa -f $KeyRootDir/${NewKeyDir}/id_rsa
df -h|grep export|awk -F'/' 'BEGIN{print "[StoreList]"}{print $(NF-1)}' > $StoreList
OldAddKeyDir=`tail -n1 /root/.gzc/addkey.yaml |awk -F'/' '{print $4}'`
sed -i 's#'${OldAddKeyDir}'#'${NewKeyDir}'#g' /root/.gzc/addkey.yaml
ansible-playbook -i $StoreList /root/.gzc/addkey.yaml
ansible-playbook -i $StoreList /root/.gzc/changepasswd.yaml
ansible -i $StoreList StoreList -m copy -a 'src=/etc/ssh/sshd_config dest=/etc/ssh/sshd_config'
ansible -i $StoreList StoreList -m shell -a 'systemctl restart sshd.service'
mkdir -p $KeyRootDir/$BakKeyDir
mv /root/.ssh/id* $KeyRootDir/${BakKeyDir}/
cp -a $KeyRootDir/$NewKeyDir/id* /root/.ssh/
OldDelKeyDir=`tail -n1 /root/.gzc/delkey.yaml |awk -F'/' '{print $4}'`
sed -i 's#'${OldDelKeyDir}'#'${BakKeyDir}'#g' /root/.gzc/delkey.yaml
ansible-playbook -i $StoreList /root/.gzc/delkey.yaml
