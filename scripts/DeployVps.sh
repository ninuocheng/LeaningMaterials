#!/bin/bash
#脚本的路径
ScriptDir=`dirname $(readlink -f $0)`
[ ! -d "${ScriptDir}" ] && echo "主目录${ScriptDir}不存在，请检查。" && exit
#rz -r上传最新的dist.zip到指定的路径
[ ! -f ${ScriptDir}/dist.zip ] && echo "${ScriptDir}/dist.zip不存在，请检查。" && exit
[ ! -f ${ScriptDir}/DeployDistHost ] &&  echo "${ScriptDir}/DeployDistHost不存在，请检查。" && exit
#检验dist.zip
md5sum dist.zip > Md5-dist.txt
ansible -i ${ScriptDir}/DeployDistHost DeployList -m copy -a "src=${ScriptDir}/Md5-dist.txt dest=/tmp/"
ansible -i ${ScriptDir}/DeployDistHost DeployList -m shell -a 'md5sum -c /tmp/Md5-dist.txt removes=/tmp/Md5-dist.txt'
[ $? -eq 0 ] && echo "dist.zip已是最新的，请检查。" && exit
#上传dist.zip到目标服务器
ansible -i ${ScriptDir}/DeployDistHost DeployList -m copy -a "src=${ScriptDir}/dist.zip dest=/root/"
[ $? -ne 0 ] && echo "上传dist.zip到目标服务器报错，请检查。" && exit
#部署vps
ansible -i ${ScriptDir}/DeployDistHost DeployList -m shell -a '/bin/bash /root/.guozhichao/DeployVps.sh removes=/root/.guozhichao/DeployVps.sh'
[ $? -ne 0 ] && echo "部署vps报错，请检查。" && exit
