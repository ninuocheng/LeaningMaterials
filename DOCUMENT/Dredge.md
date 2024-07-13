#切换到主目录
cd /root/.guozhichao/MachineList/0511
#批量更新疏通的脚本
ansible -i lotushosts lotuslist  -m copy -a "src=lotus-mpool-v2.sh dest=/root/lotus-mpool-v2.sh"
#批量查看疏通的日志信息
ansible -i lotushosts lotuslist  -m shell -a "cat /tmp/LogFile"
#批量查看消息堵塞情况
ansible -i lotushosts lotuslist  -m shell -a "bash /root/.gzc/check-mpool-message.sh"
