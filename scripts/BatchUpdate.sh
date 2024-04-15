#!/bin/bash
HostFile="4.txt"
HostList="iplist"
#ansible -i $HostFile $HostList --list
ansible -i $HostFile $HostList -m copy -a 'src=hosts.allow dest=/etc/hosts.allow'
ansible -i $HostFile $HostList -m copy -a 'src=hosts.deny dest=/etc/hosts.deny'
ansible -i $HostFile $HostList -m copy -a 'src=/etc/ssh/sshd_config dest=/etc/ssh/sshd_config'
ansible -i $HostFile $HostList -m shell -a 'systemctl restart sshd.service'
ansible -i $HostFile $HostList -m copy -a "src=/root/.guozhichao/NVIDIA-Linux-x86_64-535.54.03.run dest=/root mode=0755"
ansible -i $HostFile $HostList -m shell -a "systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target && systemctl set-default multi-user.target"
#ansible -i $HostFile $HostList -m shell -a "umount /opt/raid0"
#ansible -i $HostFile $HostList -m shell -a "mkfs.xfs -f /dev/md0"
#ansible -i $HostFile $HostList -m shell -a "mdadm -A /dev/md127 /dev/nvme[0-7]n1"
#ansible -i $HostFile $HostList -m shell -a "mount /dev/md0 /opt/raid0"
#ansible -i $HostFile $HostList -m shell -a "nvidia-smi -L"
