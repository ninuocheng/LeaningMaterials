#/bin/bash
ansible -i windowhosts windowlist -m shell -a 'bash /root/.gzc/shell/check-deadline.sh' > deadlines
awk '!/CHANGED|^$/{print}' deadlines
