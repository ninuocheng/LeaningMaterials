for i in `seq 1 36`; do echo "/mnt/disk$i *(rw,async,no_root_squash,no_subtree_check,fsid=-1)" >> /etc/exports ; done
