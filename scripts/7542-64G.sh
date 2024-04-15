#!/bin/bash
######################################环境#####################################
# 硬盘调优
cat > /etc/udev/rules.d/71-block-max-sectors.rules <<EOF
ACTION=="add", SUBSYSTEM=="block", RUN+="/bin/sh -c '/bin/echo 128 > /sys%p/queue/max_sectors_kb'"
EOF

# CPU开启性能模式
sudo apt-get install cpufrequtils -y
sudo cpufreq-set -g performance
sudo apt-get install sysfsutils -y
cat > /etc/sysfs.conf <<EOF
devices/system/cpu/cpu0/cpufreq/scaling_governor = performance
EOF

swapoff -a && sed -i  '/swap/d'  /etc/fstab
sed -i '/hugepages/d' /etc/fstab
sed -i '/hugepagesz/d' /etc/fstab


# 内存大页配置
echo 'GRUB_CMDLINE_LINUX_DEFAULT="default_hugepagesz=1G hugepagesz=1G"' >>/etc/default/grub
update-grub

cat >/etc/hugepages.sh<<EOF
#!/bin/bash
echo 252| tee /sys/devices/system/node/node{0..6}/hugepages/hugepages-1048576kB/nr_hugepages
echo 252| tee /sys/devices/system/node/node0/hugepages/hugepages-1048576kB/nr_hugepages
n=$(cat /sys/devices/system/node/node{0..6}/hugepages/hugepages-1048576kB/nr_hugepages|awk '{i+=$1}END{print 1788-i}')
a=$(cat /sys/devices/system/node/node0/hugepages/hugepages-1048576kB/nr_hugepages)
b=$(expr $n - $a)
sleep 10
echo $b > /sys/devices/system/node/node7/hugepages/hugepages-1048576kB/nr_hugepages
EOF



chmod +x /etc/hugepages.sh
cat >/etc/systemd/system/hugepages.service<<EOF
[Unit]
Description=hugepages
After=network-online.target 
[Service]
Type=simple
User=root
ExecStart=/etc/hugepages.sh
[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now hugepages


# 内核参数优化
cat >/etc/security/limits.d/20-nproc.conf<<EOF
*          soft    nproc     102400
root       soft    nproc     unlimited
EOF
cat >/etc/security/limits.conf<<EOF
*               soft    nofile          10000000
*               hard    nofile          10000000
root            soft    nofile          10000000
root            hard    nofile          10000000
*               soft    noproc          65000
*               hard    noproc          65000
EOF

cat >/etc/sysctl.conf<<EOF
fs.file-max=10000000
fs.nr_open=10000000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 204800
net.ipv4.tcp_max_tw_buckets = 204800
net.ipv4.tcp_max_orphans = 204800
net.core.netdev_max_backlog = 204800
net.core.somaxconn = 131070
vm.swappiness = 0
net.unix.max_dgram_qlen = 128
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.neigh.default.gc_thresh1 = 512
net.ipv4.neigh.default.gc_thresh2 = 28672
net.ipv4.neigh.default.gc_thresh3 = 32768
vm.dirty_background_ratio = 15
vm.dirty_ratio = 20
vm.dirty_expire_centisecs = 6000
EOF
sysctl -p

sed -i "/DefaultLimitNOFILE/c DefaultLimitNOFILE=10000000" /etc/systemd/system.conf
sed -i "/DefaultLimitNPROC/c DefaultLimitNPROC=10000000" /etc/systemd/system.conf
systemctl daemon-reexec


# 安装依赖
apt update
apt install -y tcpdump bash-completion bc net-tools mtr traceroute psmisc tcptrack nload ntpdate lsof tree lrzsz wget glances rsync zip unzip tcptraceroute hwloc ipmitool nvidia-driver-470 tmux -y

# 时间同步
timedatectl set-timezone Asia/Shanghai
(crontab -l;echo "*/1 *  *  *  *  /usr/sbin/ntpdate cn.pool.ntp.org &>/dev/null") |crontab
