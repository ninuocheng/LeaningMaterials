#!/bin/bash
lsblk  |awk '/14.6T/{print $1}' > 1
for i in `seq 36`; do for j in `awk '{print $1}' 1`; do mkdir -p /mnt/disk$i;  mount /dev/$j /mnt/disk$i && sed -i '1d' 1; break; done; done
