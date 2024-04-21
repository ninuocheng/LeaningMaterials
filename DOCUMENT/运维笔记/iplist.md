Miner元数据的备份相关说明
每台miner机计划周期性任务：
0 0 * * * /bin/bash  /usr/local/src/.aadircc/shell/backupminerbycommand.sh

脚本路径/usr/local/src/.aadircc/shell
cat /usr/local/src/.aadircc/shell/backupminerbycommand.sh
#!/bin/bash
source /opt/raid0/profile
source /opt/raid0/lotusminer-sealing/profile
MYDATEIS=$(date "+%Y%m%d%H")

/opt/raid0/lotusminer-sealing/lotusminer/bin/lotus-miner backup /opt/raid0/minerbackup/minerbackup_${MYDATEIS}.cbor &> /opt/raid0/minerbackup/minerbackup_${MYDATEIS}.log
sleep 1
cat /etc/fstab > /opt/raid0/minerbackup/mount.txt

跳板机ansible-172-25-5-68计划周期性任务
#同步每台miner元数据到/fcdata/minerbackupdata/
30 8,18 * * * /bin/bash /fcdata/shellscript/miner_backup.sh

[root@ansible-172-25-5-68 shellscript]# cat /fcdata/shellscript/miner_backup.sh
#!/bin/bash 

list="""
172.26.1.5=f0503420
172.26.1.7=f01699876
172.26.1.6=f01566485
172.25.5.44=f0428661
172.25.5.42=f0716775
172.21.10.165=f01264518
172.21.2.27=f01417791
172.21.10.1=f01521158
172.21.4.113=f090387
172.21.4.112=f01609999
172.21.10.2=f01666880
172.25.5.39=f01136428
172.25.5.45=f01179295
172.25.5.40=f0748179
172.25.1.26=f0112087
172.25.2.59=f047857
172.25.2.5=f0753988
172.21.1.9=f01990005
172.25.4.20=f0753213
172.25.3.16=f01520487
172.25.5.61=f01699999
172.25.3.8=f01416862
172.25.3.9=f01658888
172.25.3.25=f01038389
172.25.3.26=f0469055
172.25.5.43=f01089422
172.25.3.10=f01777777
"""

BACKUPDIRIS=/data/fcdata/minerbackupdata

for i in $list
do
    MYIPIS=$(echo $i|awk -F= '{print $1}')
    FNUMIS=$(echo $i|awk -F= '{print $2}')
    
    mkdir -p ${BACKUPDIRIS}/${FNUMIS}
    
    rsync -auz ${MYIPIS}:/opt/raid0/minerbackup/ ${BACKUPDIRIS}/${FNUMIS}/

    sleep 1
done

#同步百旺信的miner元数据到/fcdata/minerbackupdata/
30 8,18 * * * /bin/bash /fcdata/shellscript/miner_backup.bwx.sh
[root@ansible-172-25-5-68 shellscript]# cat /fcdata/shellscript/miner_backup.bwx.sh
#!/bin/bash

list="""
203.176.247.194=f0845296=223
116.8.132.152=f01415710=228
116.8.132.152=f01789225=227
103.90.153.194=f01250983=226
103.90.153.194=f0513878=228
103.90.153.215=f01044086=221
42.123.105.152=f02528=221
42.123.105.152=f0723827=223
183.178.32.69=f01098835=222
116.8.132.152=f01527777=230
36.99.195.21=f022748=222
121.12.124.195=f01825045=223
103.90.153.194=f01530777=236
220.195.127.247=f01538000=8222
"""

BACKUPDIRIS=/data/fcdata/minerbackupdata

for i in $list
do
    MYIPIS=$(echo $i|awk -F= '{print $1}')
    FNUMIS=$(echo $i|awk -F= '{print $2}')
    POST=$(echo $i|awk -F= '{print $3}')

    mkdir -p ${BACKUPDIRIS}/${FNUMIS}

    rsync -auz -e "ssh -p ${POST}"  ${MYIPIS}:/opt/raid0/minerbackup/ ${BACKUPDIRIS}/${FNUMIS}/

    sleep 1
done

以下是要备份的Miner机列表
不指定的就是默认的22端口
172.26.1.5=f0503420
172.26.1.7=f01699876
172.26.1.6=f01566485
172.25.5.44=f0428661
172.25.5.42=f0716775
172.21.10.165=f01264518
172.21.2.27=f01417791
172.21.10.1=f01521158
172.21.4.113=f090387
172.21.4.112=f01609999
172.21.10.2=f01666880
172.25.5.39=f01136428
172.25.5.45=f01179295
172.25.5.40=f0748179
172.25.1.26=f0112087
172.25.2.59=f047857
172.25.2.5=f0753988
172.21.1.9=f01990005
172.25.4.20=f0753213
172.25.3.16=f01520487
172.25.5.61=f01699999
172.25.3.8=f01416862
172.25.3.9=f01658888
172.25.3.25=f01038389
172.25.3.26=f0469055
172.25.5.43=f01089422
172.25.3.10=f01777777


203.176.247.194=f0845296=223
116.8.132.152=f01415710=228
116.8.132.152=f01789225=227
103.90.153.194=f01250983=226
103.90.153.194=f0513878=228
103.90.153.215=f01044086=221
42.123.105.152=f02528=221
42.123.105.152=f0723827=223
183.178.32.69=f01098835=222
116.8.132.152=f01527777=230
36.99.195.21=f022748=222
121.12.124.195=f01825045=223
103.90.153.194=f01530777=236
220.195.127.247=f01538000=8222

可以通过ansible指定host文件列表批量执行相关的操作
[iplist]
172.26.1.5
172.26.1.7
172.26.1.6
172.25.5.44
172.25.5.42
172.21.10.165
172.21.2.27
172.21.10.1
172.21.4.113
172.21.4.112
172.21.10.2
172.25.5.39
172.25.5.45
172.25.5.40
172.25.1.26
172.25.2.59
172.25.2.5
172.21.1.9
172.25.4.20
172.25.3.16
172.25.5.61
172.25.3.8
172.25.3.9
172.25.3.25
172.25.3.26
172.25.5.43
172.25.3.10
203.176.247.194 ansible_ssh_port=223
116.8.132.152 ansible_ssh_port=228
116.8.132.152 ansible_ssh_port=227
103.90.153.194 ansible_ssh_port=226
103.90.153.194 ansible_ssh_port=228
103.90.153.215 ansible_ssh_port=221
42.123.105.152 ansible_ssh_port=221
42.123.105.152 ansible_ssh_port=223
183.178.32.69 ansible_ssh_port=222
116.8.132.152 ansible_ssh_port=230
36.99.195.21 ansible_ssh_port=222
121.12.124.195 ansible_ssh_port=223
103.90.153.194 ansible_ssh_port=236
220.195.127.247=f01538000=8222
例子：
批量查看miner机元数据的备份目录下的文件
ansible -i 22_other_iplisthost iplist -m shell -a 'ls  -lht /opt/raid0/minerbackup'



