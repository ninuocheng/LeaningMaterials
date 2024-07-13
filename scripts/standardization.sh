#!/bin/bash
hostsfile="1iplist"
hostslist="iplist"
#echo "ansible-playbook -i $hostsfile addkey.yml"
#echo "ansible-playbook -i $hostsfile changepasswd.yaml"
#exit
ansible -i $hostsfile $hostslist -m copy -a "src=/root/.guozhichao/sshd_config  dest=/etc/ssh/sshd_config"
ansible -i $hostsfile $hostslist -m copy -a "src=/root/.guozhichao/hosts.allow  dest=/etc/hosts.allow"
ansible -i $hostsfile $hostslist -m copy -a "src=/root/.guozhichao/hosts.deny  dest=/etc/hosts.deny"
ansible -i $hostsfile $hostslist -m shell -a "systemctl restart sshd.service"
