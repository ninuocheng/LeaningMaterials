#!/bin/bash
sed -i 's#*(rw,async,no_root_squash,no_subtree_check,fsid=-1)#*(rw,no_root_squash,no_subtree_check,async)#g' /etc/exports 
