#!/bin/bash
numanum=8

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
echo 192| tee /sys/devices/system/node/node{{0..5},7}/hugepages/hugepages-1048576kB/nr_hugepages
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

################################## APx 工作环境生成 ######################################
rootpath=/opt
workpath=$rootpath/lotusworker
cachepath=$rootpath/raid0

mkdir -p $workpath
cat >$workpath/profile<<EOF
export MINER_API_INFO="$apipath"
export SECTOR_TYPE=32GB
EOF

mkdir -p $workpath/worker-apx/
cat >$workpath/worker-apx/start_apx.sh <<EOF
#!/bin/bash
source $workpath/profile
ip=\`hostname -I|awk '{print \$1}'\`
dir=\`dirname \$(readlink -f "\$0")\`
currdir=\${dir##*/}
bindir=\${dir%/*}
taskp1n=\`echo \${dir##*/}|sed -nr 's#.*-([0-9]+)p1#\1#p'\`
port=\$((\$taskp1n+11000))

export RUST_LOG=info
export TMPDIR=/opt/raid0/
export PIECE_TEMPLATE_DIR=/opt/raid0/piecetemplate/
export YOUZHOU_FINALIZE_BANDWIDTH=1000m

#禁用封装cc扇区
export FIL_PROOFS_IS_CC=false
#精简日志
export mimalloc_verbose=0
export FIL_PROOFS_LOG_VERIFY_SEAL=truetrue

nohup \${bindir}/lotus-worker --worker-repo \${bindir}/\$currdir run --no-local-storage --role APx --group \${ip} --listen \${ip}:\${port} > \${bindir}/\$currdir/log.txt 2>&1 &
EOF

##### APx初始化脚本 #####
cat >$workpath/worker-apx/init_apx.sh<<EOF
ip=\`hostname -I|awk '{print \$1}'\`
source $workpath/profile
export  LOTUS_WORKER_PATH=${workpath}/worker-apx
mkdir -p ${cachepath}/workercache
${workpath}/lotus-worker storage attach --init --seal --maxsealing 50 --group \${ip} ${cachepath}/workercache
EOF

##### APx启动脚本 #####
cat >$workpath/start_apx.sh<<EOF
bash $workpath/worker-apx/start_apx.sh
EOF

################################## P1 工作环境生成 ######################################

mkdir $workpath/worker-p1 -p
cat > $workpath/worker-p1/start_p1.sh<<EOF
#!/bin/bash
source /opt/lotusworker/profile
ip=\`hostname -I|awk '{print \$1}'\`
dir=\`dirname \$(readlink -f "\$0")\`
currdir=\${dir##*/}
bindir=\${dir%/*}
port=10000

# 每次从parent cache 文件读取的长度
export FIL_PROOFS_SDR_PARENTS_CACHE_SIZE=1048576
# 由于5T版本的逻辑不使用这个标志来决定多线程与否，因此统一填写为false
export FIL_PROOFS_USE_MULTICORE_SDR=false
# 这个使用默认即可，5T版本程序里面固定为1
export FIL_PROOFS_MULTICORE_SDR_PRODUCERS=1
# loader线程的工作缓存长度
export FIL_PROOFS_MULTICORE_SDR_LOOKAHEAD=2048
# loader线程一次处理多少个数据
export FIL_PROOFS_MULTICORE_SDR_PRODUCER_STRIDE=128

# 使用5T版本的逻辑，false则使用旧版本逻辑，如果使用旧版本，则下面的所有配置都失效
# 因此需要使用旧版本的配置才能匹配旧版��的P1逻辑
export FIL_PROOFS_STEP_STYLE=false
# 指示P1任务使用的NUMA和CPU核心，第一个数字表示NUMA，后面的数字表示CPU核心。例如(0,0)表示使用NUMA 0的核心0，也就是只需要一个核心；
# 例如(0,0,1)表示使用NUMA 0的核心0和1，也就是需要两个核心；因此P1任务是单线程还是多线程，就取决于配置了多少个核心
# 以下配置跑24个任务，每一个任务使用2个核心
export FIL_PROOFS_NUMA_CPU_CORES="(0,0;0)(0,1;0)(0,2,3;0)(1,4;1)(1,5;1)(1,6,7;1)(2,8;2)(2,9;2)(2,10,11;2)(3,12;3)(3,13;3)(3,14,15;3)(4,16;4)(4,17;4)(4,18,19;4)(5,20;5)(5,21;5)(5,22,23;5)(7,28;7)(7,29;7)(7,30,31;7)"
# 指示进程强制运行于那个NUMA，0表示不配置，也就是随便哪个NUMA都可以，因为我们已经通过FIL_PROOFS_NUMA_CPU_CORES指定了线程的NUMA
export FIL_PROOFS_NUMA_NODE=0

#禁用封装cc扇区
export FIL_PROOFS_IS_CC=false
#精简日志
export mimalloc_verbose=0
export FIL_PROOFS_LOG_VERIFY_SEAL=true

# parent cache文件所在目录
export FIL_PROOFS_PARENT_CACHE=/opt/raid0/filecoin-parents
# merkle tree叶子数据文件
export MERKLE_TREE_CACHE=/opt/raid0/merklecache/mcache.dat
export TMPDIR=/opt/raid0/
# skip proof parameters fetch and check
export no_fetch_params=true
export RUST_LOG=debug

nohup \${bindir}/lotus-worker --worker-repo \${bindir}/\$currdir run --no-local-storage --role P1 --group \${ip} --listen \${ip}:\${port} > \${bindir}/\$currdir/log.txt 2>&1 &
EOF

##### P1启动脚本 #####
cat >$workpath/start_p1.sh<<EOF
bash /opt/lotusworker/worker-p1/start_p1.sh
EOF

################################## P2 工作环境生成 ######################################
mkdir -p $workpath/worker-p2/
cat >$workpath/worker-p2/start_p2.sh <<EOF
#!/bin/bash
source /opt/lotusworker/profile
ip=\`hostname -I|awk '{print \$1}'\`
dir=\`dirname \$(readlink -f "\$0")\`
currdir=\${dir##*/}
bindir=\${dir%/*}
taskp1n=\`echo \${dir##*/}|sed -nr 's#.*-([0-9]+)p1#\1#p'\`
port=\$((\$taskp1n+21000))

# cpu limits
export CPU_LIST=20,21,22,23,24,25,26,27,28,29,30,31
export FIL_PROOFS_CC_CPU_SET_STR=20,21,22,23,24,25,26,27,28,29,30,31

export FIL_PROOFS_MAX_NUMA_NODE=$numanum
export FIL_PROOFS_NUMA_NODE=6
export FIL_PROOFS_PARAMETER_CACHE=/opt/raid0/filecoin-proof-parameters
export TMPDIR=/opt/raid0/

#禁用封装cc扇区
export FIL_PROOFS_IS_CC=false
#精简日志
export mimalloc_verbose=0
export FIL_PROOFS_LOG_VERIFY_SEAL=true

# skip proof parameters fetch and check
export no_fetch_params=true
export RUST_LOG=info

# P2
export mimalloc_reserve_os_memory=26843545600
export mimalloc_use_numa_offset=2
export mimalloc_use_numa_nodes=$numanum

export FIL_PROOFS_POOL_LIMIT=30
export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=true
export FIL_PROOFS_MAX_GPU_COLUMN_BATCH_SIZE=500000
export FIL_PROOFS_COLUMN_WRITE_BATCH_SIZE=8388608
export FIL_PROOFS_USE_GPU_TREE_BUILDER=true
export FIL_PROOFS_MAX_GPU_TREE_BATCH_SIZE=7000000
export FIL_PROOFS_COLUMN_PARALLEL=4
export FIL_PROOFS_TREE_R_PARALLEL=4
export NEPTUNE_DEFAULT_GPU="`nvidia-smi -L|grep 'GPU 0'|awk -F: '{print $3}'|awk -F'GPU-' '{print $2}'| tr ')' ' '|sed 's/ //g'`"

nohup taskset --cpu \$CPU_LIST \${bindir}/lotus-worker --worker-repo \${bindir}/\$currdir run --no-local-storage --role P2 --group \${ip} --listen \${ip}:\${port} > \${bindir}/\$currdir/log.txt 2>&1 &
EOF

cat >$workpath/start_p2.sh<<EOF
bash $workpath/worker-p2/start_p2.sh
EOF
