#!/bin/bash
#脚本的路径
ScriptDir=`dirname $(readlink -f $0)`
[ ! -d "${ScriptDir}" ] && echo "主目录${ScriptDir}不存在，请检查。" && exit
#rz -r上传最新的dist.zip到指定的路径
[ ! -f ${ScriptDir}/test.zip ] && echo "${ScriptDir}/test.zip不存在，请检查。" && exit
[ ! -f ${ScriptDir}/DeployDistHost ] &&  echo "${ScriptDir}/DeployDistHost不存在，请检查。" && exit
#检验test.zip
md5sum test.zip > Md5-test.txt
ansible -i ${ScriptDir}/DeployDistHost DeployList -m copy -a "src=${ScriptDir}/Md5-test.txt dest=/tmp/"
ansible -i ${ScriptDir}/DeployDistHost DeployList -m shell -a 'md5sum -c /tmp/Md5-test.txt removes=/tmp/Md5-test.txt'
[ $? -eq 0 ] && echo "test.zip已是最新的，请检查。" && exit
#上传test.zip到目标服务器
ansible -i ${ScriptDir}/DeployDistHost DeployList -m copy -a "src=${ScriptDir}/test.zip dest=/root/"
[ $? -ne 0 ] && echo "上传test.zip到目标服务器报错，请检查。" && exit
#部署testing-official.titannet.io
ansible -i ${ScriptDir}/DeployDistHost DeployList -m shell -a '/bin/bash /root/.guozhichao/Deploytesting-official.titannet.io.sh removes=/root/.guozhichao/Deploytesting-official.titannet.io.sh'
[ $? -ne 0 ] && echo "部署testing-official.titannet.io报错，请检查。" && exit
