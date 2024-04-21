#!/bin/bash
#源文件
SrcFile=/root/.guozhichao/profile
[ ! -f "$SrcFile" ] && echo "源文件不存在，请检查。" && exit
#目标文件
DestFile=
[ -z "$DestFile" ] && echo "没有指定目标文件，请检查。" && exit
#主机或主机组
HostList=
[ -z "$HostList" ] && echo "没有指定主机或主机组，请检查。" && exit
#更换算力机的profile文件
ansible $HostList -m copy -a "src=$SrcFile dest=$DestFile"
#检查挂载存储的car文件
CarFileDir=
[ -z "$CarFileDir" ] && echo "没有指定挂载存储的car，请检查。" && exit
ansible $HostList -m shell -a "df -hT $CarFileDir"
#检查GPU
ansible $HostList -m shell -a 'nvidia-smi -L'
#查看算力机的worker程序
ansible $HostList -m shell -a 'pgrep -a lotus'
#启动算力机的worker程序
ansible $HostList -m shell -a '/bin/bash '
