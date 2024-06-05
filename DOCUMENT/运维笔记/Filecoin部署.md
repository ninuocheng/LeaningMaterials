

# Filecoin 部署





## 一、程序介绍

​	软件含有三个服务程序可执行文件，分别是lotus，lotus-miner和lotus-worker。可以使用--version启动参数来获得他们对应的版本号。例如 lotus --version获得lotus程序的版本号，lotus-miner --version获得miner程序的版本号等等。

- lotus的作用主要是同步和维护主网上的链数据。

- lotus-miner作用主要有三个，分别是

  - worker管理和任务管理，并指派任务给workers
  - 进行window POST，用于向链证明持续持有已经封装好的sectors
  - 进行winning POST，用于爆块，获得奖励

- lotus-worker的作用

  - lotus-worker的作用，主要是根据配置，提供不同的任务服务，例如，进行add piece，或者进行seal pre-commit-1，或者seal pre-commit-2等任务。根据role配置参数指定的不同的role，worker提供的任务服务也不同。
  - worker的role分为如下几种
    - APx，表示该worker可以提供add piece服务，C1服务，以及finalize服务（也即是清零缓存以及把sector同步到ceph store）
    - P1，表示该worker可以提供seal pre-commit-1也即是P1任务服务
    - P2，表示该worker可以提供seal pre-commit-2也即是P2任务服务
    - C2，表示该worker可以提供 seal-commit-2也即是C2任务服务

  worker启动时，需要通过命令参数--role指定worker为如上role的一种。

**版本说明**

目前程序版本需要根据CPU厂商、系统发行版本进行的编译构建，且不能兼容运行。

|       版本/平台        | Intel+Ubuntu | Intel+CentOS | AMD+Ubuntu | AMD+CentOS |
| :--------------------: | ------------ | ------------ | ---------- | ---------- |
| 1.11.1-3079a405a-intel | √            |              |            |            |
|    1.11.1-3079a405a    |              |              | √          |            |
| 1.11.1-c019667-centos  |              |              |            | √          |
|         ？？？         |              | √            |            |            |



### 1.1 现有业务 ( 集群 )

|  矿工号   | 封装类型 |  隶属于  |  Worker数量  |     存储方式     | 运行状态 |
| :-------: | :------: | :------: | :----------: | :--------------: | :------: |
| f0494733  |   64G    |   孙总   | C2/3 + P1/24 |    NFS + Ceph    |  封装中  |
| f0822818  |   64G    |   孙总   |      0       |    NFS + Ceph    |   暂停   |
| f0822441  |   64G    |   孙总   |      0       |       NFS        |   暂停   |
| f0730670  |   64G    |   郑总   | C2/4 + P1/32 |       Ceph       |  封装中  |
| f01021773 |   64G    |   罗总   | C2/1 + P1/8  |       Ceph       |  封装中  |
| f01038389 |   64G    | 西部牧牛 | C2/3 + P1/26 | Ceph +  阿里存储 |  封装中  |
| f0469055  |   64G    |   西部   | C2/3 + P1/26 | Ceph +  阿里存储 |  封装中  |
| f0806904  |   64G    |   汪总   |      0       |       Ceph       |   结束   |
| f01089422 |   32G    |   测试   | C2/1 + P1/1  |       Ceph       |   暂停   |



### 1.2 业务相关工具

```yaml
- Ansible 
  server: 10.10.11.23 
  
- Monitoring 
  server: 10.10.11.136 
  domain: ceph.ioiofast.com
  url:
    - Prometheus: http://ceph.ioiofast.com:9090
    - Alertmanager: http://ceph.ioiofast.com:9093
    - Grafana-Server: http://ceph.ioiofast.com
        user:
          - mon: 21ops.comM
    
- Backer-server
  server: 10.10.11.228
 
- Aliyun-CPFS-10P-Monitoring
  url: 
    - Dashboard: https://10.10.11.23
        user:
          - guiadmin: Alibaba@admin
```



### 1.3 工作目录说明

#### 1.3.1 lotus+lotus-miner

```bash
# 程序变量
/opt/raid0/profile

# lotus-启动脚本
/opt/raid0/start_lotus.sh
# lotus-日志文件
/opt/raid0/lotus/logs 

# lotus-miner-启动脚本
/opt/raid0/start_lotusminer.sh
# lotus-miner-日志文件
/opt/raid0/lotusminer/logs

# 证明参数目录
/opt/raid0/filecoin-proof-parameters/

# miner元数据备份目录
/opt/raid0/minerbackup/
```

#### 1.3.2 P1-worker

```bash
# 程序变量
/opt/lotusworker/profile

# Apx-启动脚本
/opt/lotusworker/start_apx.sh
# Apx-初始化脚本
/opt/lotusworker/worker-apx/init_apx.sh
# Apx-日志
/opt/lotusworker/worker-apx/log.txt

# p1-启动脚本
/opt/lotusworker/worker-*p1/start_*p1.sh
# p1-批量启动脚本
/opt/lotusworker/start_p1.sh
# p1-日志
/opt/lotusworker/worker-*p1/log.txt

# p2-启动脚本
/opt/lotusworker/start_p2.sh
# p2-日志
/opt/lotusworker/worker-p2/log.txt


# 其他工作目录说明

# 内存大页挂载点
/opt/hugepages/layer_labels/
# 缓存数据目录
/opt/raid0/workercache/
# 模板数据
/opt/raid0/filecoin-parents
/opt/raid0/merklecache
/opt/raid0/piecetemplate
```

#### 1.3.3 C2-worker

```bash
# 程序变量
/opt/profile

# 启动脚本
/opt/worker-*c2/start_*c2.sh

# 批量启动脚本
/opt/start_c2.sh

# 日志
/opt/worker-*c2/log.txt
```



## 二、集群部署

### 2.1 Miner 服务部署（Ubuntu）

#### 2.1.1 机器配置确认

- 系统版本：CentOS 7 / Ubuntu 18.04
- 内核版本：Ubuntu 4.15+ / CentOS 3.10
- CPU：无具体要求
- 内存容量：1T
- 数据盘：两块nvme(2T+)组RAID1，开机自动挂载，挂载到 /opt/raid0 
- 显卡：RTX 2080 Ti / 3090
- Numa：无具体要求
- 关闭超线程



#### 2.1.2 运行环境配置

##### 2.1.2.1 系统优化

```bash
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
```

##### 2.1.2.2 依赖安装

```bash
apt update 
apt install -y tcpdump bash-completion bc net-tools mtr traceroute psmisc tcptrack nload ntpdate lsof tree lrzsz wget glances rsync zip unzip tcptraceroute hwloc ipmitool nvidia-driver-460 tmux -y
```

##### 2.1.2.3时间同步及CST时区设置

```bash
timedatectl set-timezone Asia/Shanghai
(crontab -l;echo "*/1 *  *  *  *  /usr/sbin/ntpdate cn.pool.ntp.org &>/dev/null") |crontab
```



#### 2.1.3 挂载共享存储 ( 内核态挂载 )

##### 2.1.3.1 安装ceph软件包

```bash
curl -fsSL http://mirrors.aliyun.com/ceph/keys/release.asc | apt-key add -
echo deb https://mirrors.aliyun.com/ceph/debian-nautilus/ $(lsb_release -sc) main > /etc/apt/sources.list.d/ceph.list
apt update
apt install ceph-common=14.* ceph-fuse=14.* -y
```

##### 2.1.3.2 写入密钥 (由相关技术提供)

```bash
mkdir -p /etc/ceph
echo "xxxxxxxxxxxxx" > /etc/ceph/ceph.client.fsuser.key
```

##### 2.1.3.3 开机挂载配置 (由相关技术提供)

```bash
vim /etc/fstab
192.168.51.101,192.168.51.102,192.168.51.103:6789:/ /ceph ceph name=fsuser,secretfile=/etc/ceph/ceph.client.fsuser.key,noatime,_netdev 0 0

mkdir -p /ceph
mount -a

# 确认挂载正确
df -h /ceph
```



#### 2.1.4 nvme盘组RAID1

```bash
# mdadm -Cv /dev/md0 -a yes -n 磁盘数量 -l RAID级别 数据盘1 数据盘2 ....
mdadm -Cv /dev/md0 -a yes -n 2 -l 1 /dev/nvme1n1 /dev/nvme2n1 
mdadm -D --scan >/etc/mdadm.conf
mkfs.xfs /dev/md0
ls -l /dev/disk/by-uuid/|awk '/md0/{print "echo \"/dev/disk/by-uuid/"$9" /opt/raid0 xfs defaults 0 0\" >>/etc/fstab"}'|bash 
mkdir /opt/raid0 -p
mount -a

# 确认挂载正确
df -h /opt/raid0
```



#### 2.1.5 lotus 服务部署

##### 2.1.5.1 创建工作目录及下载程序

```bash
# 创建工作目录
workpath=/opt/raid0
mkdir -p /${workpath}/{lotus/bin,filecoin-proof-parameters}

# 下载程序
DOWNLOADURL=http://download.anlian.us/application/filecoin
AUTH='za:za@2021'
VERSION='1.11.1-3079a405a'

curl -u "$AUTH" ${DOWNLOADURL}/lotus-${VERSION}.tar.gz  -o /tmp/lotus-${VERSION}.tar.gz 
tar xf /tmp/lotus-${VERSION}.tar.gz -C /tmp/
\cp -f /tmp/lotus ${workpath}/lotus/bin/

ln -fs ${workpath}/lotus/bin/lotus /usr/local/bin/lotus
```

##### 2.1.5.2 下载快照及证明参数

- **下载快照**

```bash
# 文件比较大约30G，建议放后台下载或使用复用终端工具tmux，尽量保持下载不中断
# 也可以选择从其他集群导出最新快照，命令见常用命令
# 下载快照及校验和
tmux
curl -sI https://fil-chain-snapshots-fallback.s3.amazonaws.com/mainnet/minimal_finality_stateroots_latest.car | perl -ne '/x-amz-website-redirect-location:\s(.+)\.car/ && print "$1.sha256sum\n$1.car"' | xargs wget -c -P /opt/raid0/

# 下载结束后检查快照
echo "$(cut -c 1-64 minimal_finality_stateroots_517061_2021-02-20_11-00-00.sha256sum) minimal_finality_stateroots_517061_2021-02-20_11-00-00.car" | sha256sum --check
> minimal_finality_stateroots_517061_2021-02-20_11-00-00.car: OK
```

- **下载证明参数 ( v0.11.0 版本之后要求lotus导入快照需要证明参数) **

```bash
# 证明参数共105G，下载时间比较长，内网环境下建议从其他现有环境拷贝
# 这里也使用终端复用工具tmux

tmux
source /opt/raid0/profile
lotus fetch-params 64GiB
```



##### 2.1.5.3 创建环境变量文件( lotus及lotus-miner 共用 )

```bash
# lotus 相关环境变量
mkdir -p /opt/raid0/minerbackup
rayonnum=`lscpu |awk '/^CPU\(s\):/{print $2*2}'`
gpuid0=`lspci|awk '/VGA.*NVIDIA Corporation/{print strtonum("0x"$1)}'|sed -n 1p`
gpuid1=`lspci|awk '/VGA.*NVIDIA Corporation/{print strtonum("0x"$1)}'|sed -n 2p`
[ -z "$gpuid1" ] && gpuid1=$gpuid0

cat >/opt/raid0/profile<<EOF
# common 
export PATH=\${PATH}:/usr/local/bin/
export RUST_LOG=info
export FIL_PROOFS_PARENT_CACHE=/opt/raid0/filecoin-parents/
export FIL_PROOFS_PARAMETER_CACHE=/opt/raid0/filecoin-proof-parameters/
export IPFS_GATEWAY="https://proof-parameters.s3.cn-south-1.jdcloud-oss.com/ipfs/"
# lotus
export LOTUS_PATH=/opt/raid0/lotus
export TMPDIR=/opt/raid0/
# lotus-miner
export SCH_QUERY_WORKER=true
export FIL_PROOFS_FIN_TICKETS=0
export FIL_PROOFS_FIN_TICKET_INTERVAL=0
export FIL_PROOFS_P1_TICKETS=2
export FIL_PROOFS_P1_TICKET_INTERVAL=4
export GOLOG_LOG_LEVEL=info
export no_fetch_params=true
export FIL_PROOFS_PARAMETER_CACHE=/opt/raid0/filecoin-proof-parameters/
export LOTUS_MINER_PATH=/opt/raid0/lotusminer
export LOTUS_BACKUP_BASE_PATH=/opt/raid0/minerbackup
#export BELLMAN_CPU_SET=
export BELLMAN_GPU_BUS_ID=${gpuid0}
export RAYON_NUM_THREADS=${rayonnum}
export FIL_PROOFS_WINNING_POST_GPU=${gpuid0}
export FIL_PROOFS_WINDOW_POST_GPU=${gpuid1}
EOF


# 配置自动导入环境变量
echo "source /opt/raid0/profile" >>/etc/profile
```

##### 2.1.5.4 创建进程配置文件

```bash
# lotus 进程配置
ip=`hostname -I|awk '{print $1}'`

cat >/opt/raid0/lotus/config.toml<<EOF
[API]
  ListenAddress = "/ip4/${ip}/tcp/1234/http"
[Backup]
  DisableMetadataLog = true
[Libp2p]
[Pubsub]
[Client]
[Metrics]
[Wallet]
[Fees]
[Chainstore]
EOF
```

##### 2.1.5.5 创建启动脚本

```bash
cat >/opt/raid0/start_lotus.sh<<EOF
#!/bin/bash
source /opt/raid0/profile
nohup lotus daemon > /opt/raid0/lotus/logs 2>&1 &
EOF
```

##### 2.1.5.6 导入快照

```bash
# 导入环境变量
source /opt/raid0/profile

# 以前台运行方式导入快照, 建议用复用终端tmux进行
ll
/opt/raid0/minimal_finality_stateroots_517061_2021-02-20_11-00-00.car

# 检查同步高度, 输出Done表示同步完成
lotus sync wait

#导入结束后直接结束进程pkill lotus，通过脚本方式后台启动。
```

##### 2.1.5.7 启动服务

```bash
# 脚本方式启动
bash /opt/raid0/start_lotus.sh

# 检查运行日志
tail -f /opt/raid0/lotus/logs
```

##### 2.1.5.8 创建worker及owner钱包

```bash
# 创建两个钱包地址，lotus自身不区分钱包用途，这里的worker和owner概念来自miner。
lotus wallet new bls
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1

lotus wallet new bls
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx2

# 查看钱包地址
lotus wallet list
Address                                              Balance    Nonce  
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1  0 FIL  	0  
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx2  0 FIL    	0 
```

##### 2.1.5.9 为owner钱包充值1个fil

> 选择其中一个地址作为owner钱包，创建矿工号时需要手续费



#### 2.1.6 lotus-miner 服务部署

##### 2.1.6.1 创建工作目录及下载程序

```bash
workpath=/opt/raid0
mkdir -p /${workpath}/{lotusminer/bin,filecoin-proof-parameters,minerbackup}

# 下载程序
DOWNLOADURL=http://download.anlian.us/application/filecoin
AUTH='za:za@2021'
VERSION='1.11.1-3079a405a'

curl -u "$AUTH" ${DOWNLOADURL}/lotus-miner-${VERSION}.tar.gz  -o /tmp/lotus-miner-${VERSION}.tar.gz 
tar xf /tmp/lotus-miner-${VERSION}.tar.gz -C /tmp/
\cp -f /tmp/lotus-miner ${workpath}/lotusminer/bin/

ln -fs ${workpath}/lotusminer/bin/lotus-miner /usr/local/bin/lotus-miner
```

##### 2.1.6.2 下载证明参数 ( 如果部署lotus时下载过了，这里跳过 )

```bash
# 证明参数共105G，下载时间比较长，内网环境下建议从其他现有环境拷贝
# 这里也使用终端复用工具tmux

tmux
source /opt/raid0/profile
lotus-miner fetch-params 64GiB
```

##### 2.1.6.3 创建环境变量文件( lotus及lotus-miner 共用 )

> 同 lotus 2.1.5.3 一致，这里不在重复写入

##### 2.1.6.4 创建进程配置文件

```bash
ip=`hostname -I|awk '{print $1}'`

cp /opt/raid0/lotusminer/config.toml{,.bak}
cat >/opt/raid0/lotusminer/config.toml<<EOF
[API]
  ListenAddress = "/ip4/${ip}/tcp/2345/http"
[Backup]
  DisableMetadataLog = true
[Libp2p]
[Pubsub]
[Dealmaking]
[Sealing]
  MaxWaitDealsSectors = 2
  MaxSealingSectors = 0
  MaxSealingSectorsForDeals = 0
  AlwaysKeepUnsealedCopy = true
    FinalizeEarly = true
    BatchPreCommits = false
    AggregateCommits = false
[Storage]
[Fees]
  MaxPreCommitGasFee = "0.025 FIL"
  MaxCommitGasFee = "0.05 FIL"
  MaxTerminateGasFee = "0.5 FIL"
  MaxWindowPoStGasFee = "5 FIL"
  MaxPublishDealsFee = "0.05 FIL"
  MaxMarketBalanceAddFee = "0.007 FIL"
  [Fees.MaxPreCommitBatchGasFee]
      Base = "0 FIL"
      PerSector = "0.02 FIL"
  [Fees.MaxCommitBatchGasFee]
      Base = "0 FIL"
      PerSector = "0.03 FIL" 
[Addresses]
EOF
```

##### 2.1.6.5 创建启动脚本

```bash
cat >/opt/raid0/start_lotusminer.sh<<EOF
#!/bin/bash
source /opt/raid0/profile
logbak=\${LOTUS_MINER_PATH}/logbak
time=\`date +%Y%m%d%H%M%S\`
[ -f \${LOTUS_MINER_PATH}/logs ] && mkdir -p \$logbak && mv \${LOTUS_MINER_PATH}/logs \$logbak/miner_\${time}.log
nohup lotus-miner run > /opt/raid0/lotusminer/logs 2>&1 &
EOF
```

##### 2.1.6.6 创建矿工号(初始化)

> 创建旷工号时一定要注意确认owner钱包有可用的fil，否则初始化失败会自动删除工作目录/opt/raid0/lotusminer

```bash
# 初始化大概需要20分钟,建议使用终端复用工具tmux进行, 矿工号出来后, miner会退出进程，需要重新启动.

tmux 
owner=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1
worker=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx2

lotus-miner init --no-local-storage --sector-size 64GiB --owner=$owner --worker=$worker 

参数说明：
	--sector-size 64GiB : 表示初始化为封装64G扇区类型，根据客户要求可以选择32G
```

##### 2.1.6.7 启动服务

```bash
# 脚本方式启动
bash /opt/raid0/start_lotusminer.sh

# 检查运行日志
tail -f /opt/raid0/lotusminer/logs

# 查看 miner 状态
lotus-miner info 
```

##### 2.1.6.8 初始化存储目录

> 这里的存储目录一定是共享存储，worker上完成封装的扇区最后会写入共享存储，所以worker(P1机器)也需要进行挂载，且必须同样的挂载路径，worker并不知道本地有这个路径，由miner告诉worker往哪里存。

```bash
source /opt/raid0/profile
lotus-miner storage attach --store --init /ceph
```

##### 2.2.6.9 自动Pledge脚本

**脚本**

```bash
cat >/opt/raid0/lotusminer/cron_pledge.sh<<EOF
#!/bin/bash
source /opt/raid0/profile 
n_packing=14
c_packing=\`lotus-miner info |awk '/Packing/{print \$2}'\`
[[ -z "\$c_packing" ]] && c_packing=0
for i in \`seq \$((\$n_packing-\$c_packing))\`
do
    lotus-miner sectors pledge
done
EOF

# 保持存在 14 Packing 任务
```

**定时任务**

```bash
crontab -e
*/4 * * * * /bin/bash /opt/raid0/lotusminer/cron_pledge.sh &>/dev/null
```



### 2.2 Worker-P1 服务部署（Ubuntu - AMD 7532)

#### 2.2.1 机器配置确认

- 系统版本：CentOS 7 / Ubuntu 18.04
- 内核版本：Ubuntu 4.15+ / CentOS 3.10
- CPU：双路 7532 / 7371 / 7t83  
- 内存容量：2T(64G)
- 数据盘：多块nvme组Raid0，容量要求30T
- 显卡：RTX 3070
- Numa：调整最大，双路机为8个

- 关闭超线程



#### 2.2.2 运行环境配置

##### 2.2.2.1 系统优化

```bash
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
```

##### 2.2.2.2 依赖安装

```bash
apt update 
apt install -y tcpdump bash-completion bc net-tools mtr traceroute psmisc tcptrack nload ntpdate lsof tree lrzsz wget glances rsync zip unzip tcptraceroute hwloc ipmitool nvidia-driver-460 tmux -y
```

##### 2.2.2.3时间同步及CST时区设置

```bash
timedatectl set-timezone Asia/Shanghai
(crontab -l;echo "*/1 *  *  *  *  /usr/sbin/ntpdate cn.pool.ntp.org &>/dev/null") |crontab
```



#### 2.2.3 挂载共享存储 ( 用户态挂载 )

##### 2.2.3.1 安装ceph软件包

```bash
curl -fsSL http://mirrors.aliyun.com/ceph/keys/release.asc | apt-key add -
echo deb https://mirrors.aliyun.com/ceph/debian-nautilus/ $(lsb_release -sc) main > /etc/apt/sources.list.d/ceph.list
apt update
apt install ceph-common=14.* ceph-fuse=14.* -y
```

##### 2.2.3.2 写入集群配置 (由相关技术提供)

```bash
mkdir -p /etc/ceph
cat >/etc/ceph/ceph.conf<<EOF
[global]
fsid = xxxxxxxx-xxxxxxxx-xxxxxxxx-xxxxxxxx
mon_initial_members = szbwx-lz01-2p-01, szbwx-lz01-2p-02, szbwx-lz01-2p-03
mon_host = 192.168.51.101,192.168.51.102,192.168.51.103
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
client_force_lazyio = true
EOF
```

##### 2.2.3.3 写入密钥 (由相关技术提供)

```bash
cat >/etc/ceph/ceph.client.fsuser.keyring<<EOF
[client.fsuser]
	key = AQB4VrdgQeekDBAAcc2lI+Dvo0s+GYlf5rg0ww==
EOF
```

##### 2.2.3.4 开机挂载配置 (由相关技术提供)

```bash
vim /etc/fstab
none /ceph fuse.ceph ceph.id=fsuser,ceph.conf=/etc/ceph/ceph.conf,_netdev,defaults  0 0

mkdir -p /ceph
mount -a

# 确认挂载正确
df -h /ceph
```



#### 2.2.4 nvme盘组RAID0

```bash
# mdadm -Cv /dev/md0 -a yes -n 磁盘数量 -l RAID级别 数据盘1 数据盘2 ....
mdadm -Cv /dev/md0 -a yes -n 4 -l 0 /dev/nvme1n1 /dev/nvme2n1 /dev/nvme3n1 /dev/nvme4n1 
mdadm -D --scan >/etc/mdadm.conf
mkfs.xfs /dev/md0
ls -l /dev/disk/by-uuid/|awk '/md0/{print "echo \"/dev/disk/by-uuid/"$9" /opt/raid0 xfs defaults 0 0\" >>/etc/fstab"}'|bash 
mkdir /opt/raid0 -p
mount -a

# 确认挂载正确
df -h /opt/raid0
```



#### 2.2.5 内存大页配置（需重启） 

##### 2.2.5.1 分配规则

- 根据封装扇区类型及并行任务数确认内存量
  - 例1：封装64G扇区，同时运行14个任务，每任务需要128G内存，那么需要内容容量为14*128=1792G
  - 例2：封装32G扇区，同时运行24个任务，每任务需要64G内存，那么需要内容容量为24*64=1536G
- 分配内存页给numa时，显卡所在numa应该最后分配剩余内存页 ( lstopo 查看硬件拓扑 ) ，计算公式为：剩余内存页=总内存页-非显卡所在numa以分配内存页和
  - 例1：参考后续步骤脚本/etc/hugepages.sh

##### 2.2.5.2 内存大页系统配置

```bash
# 更新启动引导文件

echo 'GRUB_CMDLINE_LINUX_DEFAULT="default_hugepagesz=1G hugepagesz=1G"' >>/etc/default/grub
#n=`grep -c 'hugepagesz' /etc/default/grub`
#[ "$n" -eq 0 ] && echo 'GRUB_CMDLINE_LINUX_DEFAULT="default_hugepagesz=1G hugepagesz=1G"' >>/etc/default/grub || sed -i.bak #'/hugepagesz/c GRUB_CMDLINE_LINUX_DEFAULT="default_hugepagesz=1G hugepagesz=1G"' /etc/default/grub
update-grub

# 设置开机自动挂载
echo 'none /opt/hugepages/layer_labels hugetlbfs pagesize=1G,size=1792G 0 0' >>/etc/fstab
#n=`grep -c 'hugepages' /etc/fstab`
#[ "$n" -eq 0 ] && echo 'none /opt/hugepages/layer_labels hugetlbfs pagesize=1G,size=1792G 0 0' >>/etc/fstab || sed -i.bak '/hugepages/cnone /opt/hugepages/layer_labels hugetlbfs pagesize=1G,size=1792G 0 0' /etc/fstab
mkdir -p /opt/hugepages/layer_labels
```

##### 2.2.5.3 内存大页分配服务

```bash
cat >/etc/hugepages.sh<<EOF
#!/bin/bash
echo 252| tee /sys/devices/system/node/node{{0..2},{4..7}}/hugepages/hugepages-1048576kB/nr_hugepages
n=\$(cat /sys/devices/system/node/node{{0..2},{4..7}}/hugepages/hugepages-1048576kB/nr_hugepages|awk '{i+=\$1}END{print 1792-i}')
sleep 10
echo \$n > /sys/devices/system/node/node3/hugepages/hugepages-1048576kB/nr_hugepages
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
```

##### 2.2.5.4 重启系统



#### 2.2.6 lotus-worker 服务部署

##### 2.2.6.1 创建工作目录及下载程序

```bash
DOWNLOADURL=http://download.anlian.us/application/filecoin
AUTH='za:za@2021'
VERSION='1.11.1-3079a405a'

curl -u "$AUTH" ${DOWNLOADURL}/lotus-worker-${VERSION}.tar.gz  -o /tmp/lotus-worker-${VERSION}.tar.gz 
mkdir /opt/lotusworker/
tar xf /tmp/lotus-worker-${VERSION}.tar.gz -C /opt/lotusworker/
```

##### 2.2.6.2 配置环境变量

###### 2.2.6.2.1 获取 miner api地址及token

```bash
# 登陆miner服务器
cat /opt/raid0/lotusminer/api 
/ip4/xxx.xxx.xxx.xxx/tcp/2345/http
cat /opt/raid0/lotusminer/token
xxxxxxxxxx.xxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxx
```

###### 2.2.6.2.2 写入环境变量文件

```bash
# worker服务器
cat >/opt/lotusworker/profile<<EOF
export MINER_API_INFO="xxxxxxxxxx.xxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxx:/ip4/xxx.xxx.xxx.xxx/tcp/2345/http"
export SECTOR_TYPE=64GB
EOF

参数说明：
	SECTOR_TYPE：声明封装扇区类型
```

##### 2.2.6.3 生成apx启动及初始化脚本

###### 2.2.6.3.1 启动脚本

```bash
workpath=/opt/lotusworker

mkdir -p ${workpath}/worker-apx/
cat >${workpath}/worker-apx/start_apx.sh <<EOF
#!/bin/bash
source ${workpath}/profile
ip=\`hostname -I|awk '{print \$1}'\`
#groupid=\${ip##*.}
dir=\`dirname \$(readlink -f "\$0")\`
currdir=\${dir##*/}
bindir=\${dir%/*}
taskp1n=\`echo \${dir##*/}|sed -nr 's#.*-([0-9]+)p1#\1#p'\`
port=\$((\$taskp1n+11000))

export RUST_LOG=info
export TMPDIR=/opt/raid0/
export PIECE_TEMPLATE_DIR=/opt/raid0/piecetemplate/

nohup \${bindir}/lotus-worker --worker-repo \${bindir}/\${currdir} run --no-local-storage --role APx --group \${ip} --listen \${ip}:\${port} > \${bindir}/\$currdir/log.txt 2>&1 &
EOF


# 父路径统一启动脚本
cat >${workpath}/start_apx.sh<<EOF
bash ${workpath}/worker-apx/start_apx.sh
EOF
```

###### 2.2.6.3.2 初始化脚本

```bash
cat >${workpath}/worker-apx/init_apx.sh<<EOF
ip=\`hostname -I|awk '{print \$1}'\`
groupid=\${ip##*.}
source ${workpath}/profile
export LOTUS_WORKER_PATH=${workpath}/worker-apx
mkdir -p ${cachepath}/workercache
${workpath}/lotus-worker storage attach --init --seal --maxsealing 30 --group \${groupid} ${cachepath}/workercache
EOF

参数说明：
	--maxsealing: 限制当前worker最大允许接收等待封装任务量,具体定义需要根据封装扇区类型、并行任务数、封装完成时长以及缓存盘容量计算。这里以CPU 7532, 内存 2T,缓存盘 30T 进行举例, 当64G扇区时,并行14个任务,maxsealing值建议为30; 当32G扇区时,并行24个任务,maxsealing值建议为52.
```

##### 2.2.6.4 生成p1启动脚本

```bash
workpath=/opt/lotusworker

p1config="""
worker-1p1=0,1=0
worker-2p1=2,3=0,1
worker-3p1=8,9=1 
worker-4p1=10,11=1,2 
worker-5p1=16,17=2 
worker-6p1=18,19=2,3 
worker-7p1=32,33,31=3,4
worker-8p1=34,35=4
worker-9p1=40,41,39=4,5
worker-10p1=42,43=5
worker-11p1=48,49,47=5,6
worker-12p1=50,51=6
worker-13p1=56,57,55=6,7
worker-14p1=58,59=7
"""

ARGS="""
# P1 multi-thread
export FIL_PROOFS_SDR_PARENTS_CACHE_SIZE=1048576
export FIL_PROOFS_USE_MULTICORE_SDR=true
export FIL_PROOFS_MULTICORE_SDR_PRODUCERS=1
export FIL_PROOFS_MULTICORE_SDR_LOOKAHEAD=4096
export FIL_PROOFS_MULTICORE_SDR_PRODUCER_STRIDE=128
"""

for i in ${p1config}
do 
    dir=`echo $i|awk -F'=' '{print $1}'`
    cpulist=`echo $i|awk -F'=' '{print $2}'`
    scrname=`echo ${dir##*-}`
    numaid=`echo $i|awk -F'=' '{print $3}'`
    mkdir -p ${workpath}/$dir    
    
cat >${workpath}/$dir/start_${scrname}.sh<<EOF
#!/bin/bash
source ${workpath}/profile
ip=\`hostname -I|awk '{print \$1}'\`
#groupid=\${ip##*.}
dir=\`dirname \$(readlink -f "\$0")\`
currdir=\${dir##*/}
bindir=\${dir%/*}
taskp1n=\`echo \${dir##*/}|sed -nr 's#.*-([0-9]+)p1#\1#p'\`
port=\$((\$taskp1n+10000))
# cpu limits
export CPU_LIST=${cpulist}
export FIL_PROOFS_CC_CPU_SET_STR=\${CPU_LIST}
$ARGS
export FIL_PROOFS_MAX_NUMA_NODE=8
export FIL_PROOFS_NUMA_NODE=$numaid
export FIL_PROOFS_HUGEPAGES_MOUNT_PATH=/opt/hugepages/layer_labels/\${taskp1n}p1
export FIL_PROOFS_PARENT_CACHE=/opt/raid0/filecoin-parents
export TMPDIR=/opt/raid0/
export MERKLE_TREE_CACHE=/opt/raid0/merklecache/mcache.dat
# skip proof parameters fetch and check
export no_fetch_params=true
export RUST_LOG=info

mkdir -p \$FIL_PROOFS_HUGEPAGES_MOUNT_PATH
nohup \${bindir}/lotus-worker --worker-repo \${bindir}/\${currdir} run --no-local-storage --role P1 --group \${ip} --listen \${ip}:\${port} > \${bindir}/\${currdir}/log.txt 2>&1 &
EOF
done


# 父路径统一启动脚本
cat >${workpath}/start_p1.sh<<EOF
pgrep lotus -a|awk '/P1/{print "kill "\$1}'|bash 
rm -rf /opt/hugepages/layer_labels/*
sleep 1
for i in {1..14}
do
   bash ${workpath}/worker-\${i}p1/start_\${i}p1.sh
  sleep 30
done
EOF
```

##### 2.2.6.5 生成p2启动脚本

```bash
P2CPU="24,26,28,30"
workpath=/opt/lotusworker

mkdir -p ${workpath}/worker-p2/

cat >${workpath}/worker-p2/start_p2.sh <<EOF
#!/bin/bash
source ${workpath}/profile
ip=\`hostname -I|awk '{print \$1}'\`
#groupid=\${ip##*.}
dir=\`dirname \$(readlink -f "\$0")\`
currdir=\${dir##*/}
bindir=\${dir%/*}
taskp1n=\`echo \${dir##*/}|sed -nr 's#.*-([0-9]+)p1#\1#p'\`
port=\$((\$taskp1n+12000))

export CPU_LIST=${P2CPU}
export FIL_PROOFS_CC_CPU_SET_STR=\${CPU_LIST}
export FIL_PROOFS_PARENT_CACHE=/opt/raid0/filecoin-parents
export TMPDIR=/opt/raid0/
# P2 specify
export FIL_PROOFS_POOL_LIMIT=26
export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=true
export FIL_PROOFS_MAX_GPU_COLUMN_BATCH_SIZE=500000
export FIL_PROOFS_COLUMN_WRITE_BATCH_SIZE=8388608
export FIL_PROOFS_USE_GPU_TREE_BUILDER=true
export FIL_PROOFS_MAX_GPU_TREE_BATCH_SIZE=7000000
export FIL_PROOFS_COLUMN_PARALLEL=2
export mimalloc_verbose=1
export mimalloc_show_stats=1
export mimalloc_show_errors=1
export mimalloc_use_numa_nodes=8
#export mimalloc_reset_delay=600000
export mimalloc_reserve_os_memory=32212254720
# skip proof parameters fetch and check
export no_fetch_params=true
export RUST_LOG=info
nohup \${bindir}/lotus-worker --worker-repo \${bindir}/\${currdir} run --no-local-storage --role P2 --group \${ip} --listen \${ip}:\${port} > \${bindir}/\${currdir}/log.txt 2>&1 &
EOF

# 父路径统一启动脚本
cat >${workpath}/start_p2.sh<<EOF
bash ${workpath}/worker-p2/start_p2.sh
EOF
```

#### 2.2.7 首次运行生成数据模板（已存在数据模板则跳过此步骤）

> 官方版本没有数据模版这一说法，数据模版是二开优化之后新增的产出，原理是封装过程中都会生成相同的数据，造成了不必要的计算及IO资源浪费。
> 优化后的程序通过软链接的方式引用模版文件。
>
> 数据模版目前分32G及64G两种类型
>
> 32G类型数据模版数据大小：153G
> 64G类型数据模版数据大小：246G

##### 2.2.7.1 32G数据模版目录结构

```bash
$ tree -h /opt/raid0/{filecoin-parents,merklecache,piecetemplate}
/opt/raid0/filecoin-parents
└── [ 56G]  v28-sdr-parent-21981246c370f9d76c7a77ab273d94bde0ceb4e938292334960bce05585dc117.cache
/opt/raid0/merklecache
└── [ 64G]  mcache.dat
/opt/raid0/piecetemplate
├── [ 105]  piece-info.json
└── [ 32G]  staged-file

# 目录、文件名及文件内容固定不变
$ cat /opt/raid0/piecetemplate/piece-info.json
{"Size":34359738368,"PieceCID":{"/":"baga6ea4seaqao7s73y24kcutaosvacpdjgfe5pw76ooefnyqw4ynr3d2y6x2mpq"}}
```

##### 2.2.7.2 64G数据模版目录结构

```bash
$ tree -h /opt/raid0/{filecoin-parents,merklecache,piecetemplate}
/opt/raid0/filecoin-parents
└── [112G]  v28-sdr-parent-4905486b7af19558ac3649bc6261411858b6add534438878c4ee3b29d8b9de0b.cache
/opt/raid0/merklecache
└── [128G]  mcache.dat
/opt/raid0/piecetemplate
├── [ 105]  piece-info.json
└── [ 64G]  staged-file

# 目录及文件名固定不变
$ cat /opt/raid0/piecetemplate/piece-info.json
{"Size":68719476736,"PieceCID":{"/":"baga6ea4seaqomqafu276g53zko4k23xzh4h4uecjwicbmvhsuqi7o4bhthhm4aq"}}
```

##### 2.2.7.3 生成方法

###### 2.2.7.3.1 启动apx

```bash
bash /opt/lotusworker/start_apx.sh

# 观察日志确认启动成功
```

###### 2.2.7.3.2  初始化apx

```bash
bash /opt/lotusworker/worker-apx/init_apx.sh

# 观察日志确认init成功
# init做了哪些动作
1. 写入cache路径
$ cat /opt/lotusworker/worker-apx/storage.json 
{
  "StoragePaths": [
    {
      "Path": "/opt/raid0/workercache"
    }
  ]
}

2. 在cache目录下生成以下目录结构
$ tree -L 1 /opt/raid0/workercache/
/opt/raid0/workercache/
├── cache
├── sealed
├── sectorstore.json
└── unsealed
```

###### 2.2.7.3.3 启动一个p1进程

```bash
bash /opt/lotusworker/worker-1p1/start_1p1.sh
```

###### 2.2.7.3.4 Miner生成一个封装任务

```bash
lotus-miner sectors pledge
```

###### 2.2.7.3.5 拷贝apx及p1生成的cache数据作为模版

> 64G：大概40分钟生成数据
> 32G：大概25分钟生成数据
>
> 过滤日志关键字 "generating layer: 2"，出现相关日志表示cache数据以生成。
> grep 'generating layer: 2'  /opt/lotusworker/worker-1p1/log.txt

 cache数据文件目录结构 ( 64G )

```bash
$ tree -h /opt/raid0/
├── [  99]  filecoin-parents
│   └── [112G]  v28-sdr-parent-4905486b7af19558ac3649bc6261411858b6add534438878c4ee3b29d8b9de0b.cache # p1 生成, 模板之一, 不需要拷贝 
└── [  93]  workercache
    ├── [4.0K]  cache
    │   └── [  43]  s-xxxxxx-0
    │       └── [  128G]  sc-02-data-tree-d.dat # p1 生成, 模板之一, 拷贝到 /opt/raid0/merklecache/mcache.dat 
    ├── [4.0K]  sealed 
    │   └── [ 64G]  s-xxxxxx-0 # p1 生成, 用不到
    ├── [ 172]  sectorstore.json
    └── [4.0K]  unsealed 
        └── [  64G]  s-xxxxxx-0 # apx 生成, 模板之一, 拷贝到 /opt/raid0/piecetemplate/staged-file
```

模板目录文件结构 ( 64G )

```bash
# 创建模板目录
mkdir -p /opt/raid0/{merklecache,piecetemplate}

# 创建 64G 配置 piece-info.json
echo '{"Size":68719476736,"PieceCID":{"/":"baga6ea4seaqomqafu276g53zko4k23xzh4h4uecjwicbmvhsuqi7o4bhthhm4aq"}}' >/opt/raid0/piecetemplate/piece-info.json

# 目录文件结构
$ tree -h /opt/raid0/{filecoin-parents,merklecache,piecetemplate}
/opt/raid0/filecoin-parents
└── [112G]  v28-sdr-parent-4905486b7af19558ac3649bc6261411858b6add534438878c4ee3b29d8b9de0b.cache
/opt/raid0/merklecache
└── [128G]  mcache.dat
/opt/raid0/piecetemplate
├── [ 105]  piece-info.json
└── [ 64G]  staged-file
```

###### 2.2.7.3.6 结束p1进程，通过统一启动脚本启动所有p1进程及p2进程

```bash
# kill p1 进程
pgrep lotus -a|awk '/-1p1/{print "kill "$1}'|bash 

# 启动14个p1进程, p1 启动过程比较长, 需要7分钟完全启动, 建议放后台启动。
nohup bash /opt/lotusworker/start_p1.sh & >/dev/null

# 启动p2进程
bash /opt/lotusworker/start_p2.sh
```



#### 2.2.8 启动服务 (已存在数据模板)

##### 2.2.8.1 拷贝数据模版到对应目录

##### 2.2.8.2 启动apx

```bash
bash /opt/lotusworker/start_apx.sh
```

##### 2.2.8.3 初始化apx

```bash
bash /opt/lotusworker/worker-apx/init_apx.sh
```

##### 2.2.8.4 启动p2

```bash
bash /opt/lotusworker/start_p2.sh
```

##### 2.2.8.5 启动p1

```bash
nohup bash /opt/lotusworker/start_p1.sh & >/dev/null
```



### 2.3 Worker-C2 服务部署  （Ubuntu - INTEL 4216)

#### 2.3.1 机器配置确认

- 系统版本：CentOS 7 / Ubuntu 18.04
- 内核版本：Ubuntu 4.15+ / CentOS 3.10
- CPU：双路 4216 / 7601 / 7371
- 内存容量：2T(64G)
- 数据盘：多块nvme组Raid0，容量要求30T
- 显卡：RTX 3070
- Numa：调整最大，双路机为8个

- 关闭超线程



#### 2.3.2 运行环境配置

##### 2.3.2.1 系统优化

```bash
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
```

##### 2.3.2.2 依赖安装

```bash
apt update 
apt install -y tcpdump bash-completion bc net-tools mtr traceroute psmisc tcptrack nload ntpdate lsof tree lrzsz wget glances rsync zip unzip tcptraceroute hwloc ipmitool nvidia-driver-460 tmux -y
```

##### 2.3.2.3时间同步及CST时区设置

```bash
timedatectl set-timezone Asia/Shanghai
(crontab -l;echo "*/1 *  *  *  *  /usr/sbin/ntpdate cn.pool.ntp.org &>/dev/null") |crontab
```



#### 2.3.3 从miner拷贝证明参数

```bash
rsync -auv MINER:/opt/raid0/filecoin-proof-parameters /opt/
```

#### 2.3.4 lotus-worker 服务部署

##### 2.3.4.1 创建工作目录及下载程序

```bash
DOWNLOADURL=http://download.anlian.us/application/filecoin
AUTH='za:za@2021'
VERSION='1.11.1-39c692f52-intel'

curl -u "$AUTH" ${DOWNLOADURL}/lotus-worker-${VERSION}.tar.gz  -o /tmp/lotus-worker-${VERSION}.tar.gz 
mkdir /opt/lotusworker/
tar xf /tmp/lotus-worker-${VERSION}.tar.gz -C /opt/
```

##### 2.3.4.2 创建环境变量文件

```bash
# miner api 信息获取同步骤 2.2.6.2.1 

cat >/opt/lotusworker/profile<<EOF
export MINER_API_INFO="xxxxxxxxxx.xxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxx:/ip4/xxx.xxx.xxx.xxx/tcp/2345/http"
EOF
```

##### 2.3.4.3 创建启动脚本

```bash
c2config="""
worker-1c2=8,9,40,41,0,1,2,3,4,5,40,41,32,33,34,35,36,37=20010
worker-2c2=10,11,42,43,6,7,16,17,18,19,42,43,38,39,48,49,50,51=20020
worker-3c2=12,13,44,45,20,21,22,23,24,25,44,45,52,53,54,55,56,57=20030
worker-4c2=14,15,46,47,26,27,28,29,30,31,46,47,58,59,60,61,62,63=20040
"""

workpath=/opt
mkdir -p ${workpath}

gpu=`lspci|awk '/VGA.*Corporation/{print strtonum("0x"$1)}'`

count=1
for i in ${c2config}
do 
	
	dir=`echo $i|awk -F'=' '{print $1}'`
	cpulist=`echo $i|awk -F'=' '{print $2}'`
	port=`echo $i|awk -F'=' '{print $3}'`
	scrname=`echo ${dir##*-}`
	mkdir -p ${workpath}/$dir	
	gpuid=`echo "$gpu"|sed -n "${count}p"`	
cat >${workpath}/$dir/start_${scrname}.sh<<EOF
#!/bin/bash
source ${workpath}/profile
ip=\`hostname -I|awk '{print \$1}'\`
dir=\`dirname \$(readlink -f "\$0")\`
currdir=\${dir##*/}
bindir=\${dir%/*}
time=\`date +%Y%m%d%H%M%S\`
logbak=\${bindir}/\${currdir}/logbak

# cpu limits
CPU_LIST=${cpulist}
export BELLMAN_CPU_UTILIZATION=0
export BELLMAN_CPU_SET=\$CPU_LIST
export BELLMAN_GPU_BUS_ID=$gpuid
export FIL_PROOFS_PARAMETER_CACHE=/opt/filecoin-proof-parameters
# skip proof parameters fetch and check
export no_fetch_params=true
export RUST_LOG=info

[ -f \${bindir}/\${currdir}/log.txt ] && mkdir -p \${logbak} && mv \${bindir}/\${currdir}/log.txt \$logbak/log_\${time}.txt
nohup taskset --cpu-list \${CPU_LIST} \${bindir}/lotus-worker --worker-repo \${bindir}/\${currdir} run --no-local-storage --role C2  --listen \${ip}:${port} > \${bindir}/\${currdir}/log.txt 2>&1 &
EOF
	count=$(($count+1))
done


# 父路径统一启动脚本
cat >${workpath}/start_c2.sh<<EOF
for i in {1..4}
do
   bash ${workpath}/worker-\${i}c2/start_\${i}c2.sh
done
EOF
```

##### 2.3.4.4 启动服务

```bash
bash /opt/start_c2.sh

# 检查运行状态, 检查日志
```



## 三、Ansible 批量部署 (Worker)

### 3.1 支持范围

| CPU / 系统+封装类型 | Ubuntu + 64G | Ubuntu + 32G | CentOS + 64G | CentOS + 32G |
| ------------------- | ------------ | ------------ | ------------ | ------------ |
| AMD 7371            | √            | x            | x            | x            |
| AMD 7532            | √            | x            | x            | x            |
| AMD 7t83            | √            | x            | x            | x            |
| Intel  4216         | √            | x            | x            | x            |
| AMD 7601            | √            | x            | x            | x            |



### 3.2 支持功能

- 内核优化
- 依赖安装
- 根据CPU型号配置内存大页
- 根据CPU型号生成APX, P1, P2, C2启动脚本
- 下载对应版本软件包
- 设置主机名：矿工号-Role-IP地址
- 安装系统node_exporter
- 安装业务监控fcmonit
- 共享存储挂载 (ceph)
- 版本迭代更新
- 服务启动

### 3.3 工作目录说明

- 目录结构

```bash
etc/ansible/filecoin
├── alert
│   └── app
│       ├── config
│       ├── fcmonit
│       └── fcmonit.service
├── aliyun
│   └── mount_alypoint.yaml
├── ceph
│   └── deploy_worker_mount_ceph.yaml
├── deploy_worker_c2.yaml
├── deploy_worker_p1.yaml	
├── module
│   ├── config_hugepage.yaml
│   ├── init.yaml
│   ├── install_depend.yaml
│   ├── install_node_exporter.yaml
│   ├── set_hostname.yaml
│   └── timesync.yaml
├── packet
│   └── node_exporter
│       ├── node_exporter
│       └── node_exporter.service
├── scripts
│   ├── c2reconfig.sh
│   ├── p1reconfig.sh
│   └── sysctl.sh
├── start
│   ├── bak
│   │   ├── apx_init_start.yaml
│   │   ├── apx_start.yaml
│   │   ├── p1_start.yaml
│   │   └── p2_start.yaml
│   ├── c2_start.yaml
│   └── start_all_p1.yaml
├── tmp_install.yaml
└── vars
    ├── test.yaml
    └── variable.yaml
```

#### 3.3.1 子目录/文件说明

```
alert:	fcmonit相关配置
aliyun：	阿里云存储挂载playbook 
ceph:	ceph存储挂载playbook 
module：	复用task片段
packet:	 程序包下载目录
scripts:  playbook调用的脚本
start:	worker服务启动playbook
vars:	变量目录

deploy_worker_p1.yaml：	部署 P1 
deploy_worker_c2.yaml：	部署 C2
```



### 3.4 Ansible 相关配置

#### 3.4.1 服务器加入主机清单

```bash
cat /etc/ansible/host
[f0000001:children]
f0000001-miner
f0000001-p1
f0000001-c2
[f0000001:vars]
ansible_ssh_pass=password
[f0000001-miner]
192.168.10.1
[f0000001-c2]
192.168.10.10
[f0000001-p1]
192.168.10.50
192.168.10.51
192.168.10.52
192.168.10.53
```



#### 3.4.2 定义相关变量信息

##### 3.4.2.1 miner api 信息

```bash
# miner api 信息获取同步骤 2.2.6.2.1 

cat >/etc/ansible/filecoin/vars/f0000001.yaml<<EOF
api: "xxxxxxxxxx.xxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxx:/ip4/xxx.xxx.xxx.xxx/tcp/2345/http"
EOF
```

##### 3.4.2.2 部署的版本

```bash
cat /etc/ansible/filecoin/vars/variable.yaml 
packetdir: "/etc/ansible/filecoin/packet/"
download_url: "http://download.anlian.us/application/filecoin"
download_user: "za"
download_passwd: "za@2021"
ver: "1.11.1-3079a405a"
c2ver: "3079a405a"

# ver: 定义部署版本
# c2ver: 定义C2部署版本
```



### 3.5 Worker-P1 服务部署

#### 3.5.1 机器环境确认

> 确认缓存盘以挂载到 /opt/raid0， 并设置开启自动挂载
>
> ​	检测命令:  ansible f0000001-p1 -m shell -a "df -h /opt/raid0"
>
> 相关的数据模板以拷贝到对应目录：/opt/raid0/{filecoin-parents,merklecache,piecetemplate},  确认文件数量及大小完整
>
> ​	检测命令:  ansible f0000001-p1 -m raw -a 'tree -h /opt/raid0/{filecoin-parents,merklecache,piecetemplate}'



#### 3.5.2 执行部署Playbook

##### 3.5.2.1 程序部署

```bash
# 切换工作目录
cd /etc/ansible/filecoin

# 执行部署动作
ansible-playbook -e host=f0000001 deploy_worker_p1.yaml

# 首次部署结束后需要进行重启woerker, 使其hugepage配置生效
ansible f0000001 -m reboot

# 重启之后检查hugepage分配是否正确
ansible f0000001-p1 -m shell -a "cat /sys/devices/system/node/node*/hugepages/hugepages-1048576kB/nr_hugepages"

# 重启之后检查显卡驱动是否正常
ansible f0000001-p1 -m shell -oa "nvidia-smi -L"
```

##### 3.5.2.2 挂载ceph文件系统

```bash
# 创建矿工号目录
mkdir -p /etc/ansible/filecoin/ceph/f0000001

# 上传ceph配置文件及用户keyring（相关技术提供）
tree /etc/ansible/filecoin/ceph/f0000001/
/etc/ansible/filecoin/ceph/f0000001/
├── ceph.client.fsuser.keyring # 上传文件
└── ceph.conf	# 上传文件

# 切换工作目录
cd /etc/ansible/filecoin

# 执行挂载动作
ansible-playbook -e 'host=f0000001 mountpath=/ceph' deploy_worker_mount_ceph.yaml

# 检查挂载状态
ansible f0000001-p1 -m shell -a "df -h /ceph"
```



#### 3.5.3 执行启动服务Playbook

```bash
# 切换工作目录
cd /etc/ansible/filecoin/start

# 启动所有进程
ansible-playbook -e host=f0000001 start_all_p1.yaml

# 首次运行需要执行init
ansible-playbook -e host=f0000001 bak/apx_init_start.yaml
```



#### 3.5.4 服务进程检查

```bash
# 检查进程数量是否正确, APX+P1+P2 总共16个进程, 完全启动需要7分钟.
ansible f0000001-p1 -m shell -a "pgrep -c lotus"

# 确认进程启动成功后, 需要上miner确认P1—worker进程是否正常注册,
# 已注册P1进程数统计, 统计方法: P1-worker数量*14
lotus-miner sealing workers |egrep -c ':100(0[0-9]|1[0-4])'
# 已注册P2进程数统计, 统计方法: P1-worker数量
lotus-miner sealing workers |egrep -c ':12000'
# 已注册APX进程数统计, 统计方法: P1-worker数量
lotus-miner sealing workers |egrep -c ':11000'

# 统计P1—worker所有注册进程, 确认所有进程注册正常, 统计方法：P1-worker数量*16
lotus-miner sealing workers |egrep -c '1[0-2]0(0[0-9]|1[0-4]|00)'
```



### 3.6 Worker-C2 服务部署

#### 3.6.1 机器环境确认

> 确认证明参数以下载到：/opt/filecoin-proof-parameters 

#### 3.6.2 执行部署Playbook

```bash
# 切换工作目录
cd /etc/ansible/filecoin

ansible-playbook  -e host=f0000001 deploy_worker_c2.yaml
```



#### 3.6.3 执行启动服务Playbook

```bash
# 切换工作目录
cd /etc/ansible/filecoin/start

ansible-playbook -e host=f0000001 c2_start.yaml
```



#### 3.6.4 服务进程检查

```bash
# 检查进程数量是否正确, C2启动4个进程。
ansible f0000001-c2 -m shell -a "pgrep -c lotus"

# 统计C2—worker所有注册数量, 确认所有进程注册正常, 统计方法: C2-worker数量*4
lotus-miner sealing workers |egrep -c ':200[1-4]0'
```



### 3.7 开启封装任务

#### 3.7.1 确认进程注册正常

```bash
# P1-worker进程 + C2-worker进程
lotus-miner sealing workers|grep -c Worker

# 以主机名方式分组统计注册进程数量
lotus-miner sealing workers|awk -F'[, ]+' '/Worker/{print $4}'|sort |uniq -c
```



#### 3.7.2 生成封装任务

```bash
# 首次启动封装提前生成足够的任务 
# P1—worker数 * 28 = 任务数
# P1-worker 14个p1进程完全跑起来需要28分钟, miner每4分钟派发2个任务, 14个需要7轮，总共耗时28分钟.

for i in 任务数; do lotus-miner sectors pledge; done 
for i in `seq 620`; do lotus-miner sectors pledge; done
```



#### 3.7.3 查看封装的任务

```bash
# 查看所有任务
lotus-miner sealing jobs 

# 以主机名+role 分组统计
lotus-miner sealing jobs|awk 'NR>1{host[$4":"$5]+=1}END{for(i in host)print i,host[i]}'|sort -nk2|column -t
```



### 3.8 业务监控fcmonit服务部署

#### 3.8.1 配置文件说明

```bash
/etc/ansible/filecoin/alert/app/config/*config.yaml
c2-config.yaml  	# C2-worker 配置
miner-config.yaml   # lotus+miner 配置
p1-config.yaml		# P1-worker 配置

```

##### 3.8.1.1 日志匹配

```yaml
monit:
    #日志文件路径
  - logFile: "/opt/raid0/lotusminer/logs"
    #预览位置
    offset: 10
    #告警匹配关键词
    logFilter: ".*(([eE]rror|[fF]ailed|[pP]anic|ERROR|FAILED|PANIC).*(wdpost|winning|drand)|mined new block).*"
  - logFile: "xxx"
    offset: 10
    logFilter: "xxxx"
```

##### 3.8.1.2 lotus 同步状态检测

```yaml
lutos:
  #命令超时时间，单位毫秒
  timeout: 20000
  #监控命令
  cmd: "LOTUS_PATH=/opt/raid0/lotus lotus sync wait"
  #任务间隔配置
  taskSpec: "0 */5 * * * ?"
```

##### 3.8.1.3 进程检测

```yml
process:
  #命令超时时间，单位毫秒
  timeout: 3000
  taskSpec: "0 */5 * * * ?"
  cmds:
  - cmd: "ps uax|grep '[l]otus-miner run' -c"   
    checkVal: 1
    cond: "!="
  - cmd: "ps uax|grep '[l]otus daemon' -c"
    checkVal: 1
    cond: "!="
  - cmd: "pgrep node_exporter -c"
    checkVal: 1
    cond: "!="
```

##### 3.8.1.4 挂载点检测

```yaml
miner:
  #命令超时时间，单位毫秒
  timeout: 30000
  #任务间隔配置
  taskSpec: "0 */1 * * * ?"
  cmds: ["cat /opt/checklist","ls %s &>/dev/null;echo $?"]
  
  
############# 需要检测的挂载点
cat /opt/checklist 
/ceph
/opt/raid0/
```

##### 3.8.1.5 显卡异常检测

```yaml
nvidia:
  #命令超时时间，单位毫秒
  timeout: 5000
  #任务间隔配置
  taskSpec: "0 */5 * * * ?"
  cmd: "nvidia-smi &>/dev/null ;echo $?"
```



#### 3.8.2 批量部署

##### 3.8.2.1 Miner

```bash
cd /etc/ansible/filecoin

ansible-playbook -e 'host=f0000001-miner role=miner' deploy-fcmonit-alert.yaml
```

##### 3.8.2.2 P1-worker

```bash
cd /etc/ansible/filecoin

ansible-playbook -e 'host=f0000001-p1 role=p1' deploy-fcmonit-alert.yaml
```

##### 3.8.2.3 C2-worker

```bash
cd /etc/ansible/filecoin

ansible-playbook -e 'host=f0000001-c2 role=c2' deploy-fcmonit-alert.yaml
```



#### 3.8.3 告警类型

- Winning Post 爆块日志

```
============第1条信息============
告警时间：2021-07-23 02:42:08
IP: 192.168.77.2
主机名: miner-f01070040
类型：Filecoin日志监控
命令：filter log
描述：日志过滤详情信息
详情：2021-07-23T02:39:09.696+0800        INFO        miner        miner/miner.go:578        mined new block        {"sector-number": "2153", "cid": "bafy2bzacedaylgkr5u7ms46ijmewvz54vunjf7ee33sx44nsmoahzbefd33ac", "height": 955759, "miner": "f01070040", "parents": ["f0142720","f0700033","f084419"], "parentTipset": "{bafy2bzaced6rtcmhy6jvpp6vsntuyu7vl6brfnzzqt75zszeoufzek3sobeis,bafy2bzaceaieughstssdfgvx6wfm3w34r4sagxq35gprzswfiefdlgnipq5oq,bafy2bzacebhyk5tgzketeqa2mrtfuhyoochwp2rhca3447slu6uevghm7zsyk}", "took": 3.672559113}

================================
```

- 进程异常

```
============第1条信息============
告警时间：2021-07-22 23:50:41
IP: 192.168.8.7
主机名: miner-f01038389
类型：业务进程监控告警
命令：ps uax|grep '[l]otus-miner run' -c
描述：业务检测监控命令执行错误
详情：0

================================
```

- 显卡异常

```
============第1条信息============
告警时间：2021-07-22 07:30:00
IP: 172.20.3.4
主机名: f01089422-miner-172-20-3-4
类型：显卡检测命令
命令：nvidia-smi &>/dev/null ;echo $?
描述：显卡检测命令执行结果异常
详情：255

================================
```

- 挂载路径异常

```
============第1条信息============
告警时间：2021-07-18 19:37:07
IP: 192.168.8.33
主机名: miner-f0822818
类型：文件路径监控
命令：ls /mnt/192.168.37.73/disk13/lotusminer &>/dev/null;echo $?
描述：文件路径检测错误
详情：signal: killed
================================
```

- miner通信lotus失败

```
============第1条信息============
告警时间：2021-07-20 15:16:10
IP: 192.168.8.33
主机名: miner-f0822818
类型：Filecoin日志监控
命令：filter log
描述：日志过滤详情信息
详情：2021-07-20T15:15:46.203+0800        ERROR        storageminer        storage/wdpost_sched.go:111        ChainNotify error: handler: websocket connection closed

================================
```

- Windows Post 抽查失败

```
============第1条信息============
告警时间：2021-06-28 00:54:41
IP: 192.168.33.64
主机名: new-miner-f0469055
类型：Filecoin日志监控
命令：filter log
描述：日志过滤详情信息
详情：2021-06-28T00:50:33.198+0800        [33mWARN[0m        storageminer        storage/wdpost_run.go:655        generate window post skipped sectors        {"sectors": [{"Miner":469055,"Number":13055}], "error": "faulty sectors [SectorId(13055)]", "errorVerbose": "faulty sectors [SectorId(13055)]\ngithub.com/filecoin-project/filecoin-ffi.GenerateWindowPoSt\n\t/root/lotus/extern/filecoin-ffi/proofs.go:587\ngithub.com/filecoin-project/lotus/extern/sector-storage/ffiwrapper.(*Sealer).GenerateWindowPoSt\n\t/root/lotus/extern/sector-storage/ffiwrapper/verifier_cgo.go:45\ngithub.com/filecoin-project/lotus/storage.(*WindowPoStScheduler).runPost\n\t/root/lotus/storage/wdpost_run.go:597\ngithub.com/filecoin-project/lotus/storage.(*WindowPoStScheduler).runGeneratePoST\n\t/root/lotus/storage/wdpost_run.go:102\ngithub.com/filecoin-project/lotus/storage.(*WindowPoStScheduler).startGeneratePoST.func1\n\t/root/lotus/storage/wdpost_run.go:86\nruntime.goexit\n\t/usr/local/go/src/runtime/asm_amd64.s:1371", "try": 0}

================================
```



### 3.9 基础监控（Prometheus）

#### 3.9.1 配置监控组

```bash 
vim /data/prometheus/config/prometheus.yml

##################### xxx-f0000001  #########################
  - job_name: xxx-f0000001
    scrape_interval: 30s
    scrape_timeout: 15s
    metrics_path: /metrics
    scheme: http
    file_sd_configs:
    - refresh_interval: 30s # 30s重载配置文件
      files:
      - ./sdconfig/filecoin/xxx-f0000001.yaml
```

#### 3.9.2 配置监控信息

```bash
vim  /data/prometheus/config/sdconfig/filecoin/xxx-f0000001.yaml
- targets:
  - 192.168.10.1:9100
  labels:
    role: Miner
    type: node
    service: filecoin
- targets:
  - 192.168.10.10:9100
  labels:
    role: C2
    type: node
    service: filecoin
- targets:
  - 192.168.10.51:9100
  - 192.168.10.52:9100
  - 192.168.10.53:9100
  - 192.168.10.54:9100
  - 192.168.10.55:9100
  labels:
    role: P1
    type: node
    service: filecoin
```

#### 3.9.3 加载配置

```bash
bash /data/prometheus/reload.sh
```



## 四、日常运维

### 4.1 版本更新

#### 4.1.1 lotus 版本更新

```bash
cd /tmp
ver=1.11.1-3079a405a
wget --user=za --password=za@2021 http://download.anlian.us/application/filecoin/lotus-${ver}.tar.gz
tar xf lotus-${ver}.tar.gz
source /opt/raid0/profile 
lotus daemon stop
sleep 5
mv /opt/raid0/lotus/bin/lotus{,.bak}	
mv lotus /opt/raid0/lotus/bin/
lotus -v 
bash /opt/raid0/start_lotus.sh

# 状态查看
lotus sync wait
```



#### 4.1.2 lotus-miner 版本更新

> 注意避开抽查时间，版本更新需要提前计划好停止封装任务

```bash
cd /tmp
ver=1.11.1-3079a405a
wget --user=za --password=za@2021 http://download.anlian.us/application/filecoin/lotus-miner-${ver}.tar.gz
tar xf lotus-miner-${ver}.tar.gz
source /opt/raid0/profile 
lotus-miner stop
sleep 5
mv /opt/raid0/lotusminer/bin/lotus-miner{,.bak}
mv lotus-miner /opt/raid0/lotusminer/bin/
lotus-miner -v 
bash /opt/raid0/start_lotusminer.sh 
```



#### 4.1.3 worker-p1 版本更新

> 注意避开FinalizeSector阶段，使用 ansible 批量更新 

```bash
# 切换工作目录
cd /etc/ansible/filecoin

# 指定更新版本
cat /etc/ansible/filecoin/vars/variable.yaml 
ver: "1.11.1-7a967ae03"

# 停止worker上的进程
ansible f0000001-p1 -m shell -a "pkill -9 lotus"
ansible f0000001-p1 -m shell -a "pkill -9 lotus"

# 执行更新动作
ansible-playbook -e host=f0000001 deploy_worker_p1.yaml

# 启动所有进程
ansible-playbook -e host=f0000001 start_all_p1.yaml

# 检查进程状态
ansible f0000001-p1 -m shell -a "pgrep -c lotus"
```



#### 4.1.4 worker-c2 版本更新

```bash
# 切换工作目录
cd /etc/ansible/filecoin

# 指定更新版本
cat /etc/ansible/filecoin/vars/variable.yaml 
ver: "1.11.1-7a967ae03"

# 停止worker上的进程
ansible f0000001-c2 -m shell -a "pkill lotus"
ansible f0000001-c2 -m shell -a "pkill -9 lotus"

# 执行更新动作
ansible-playbook -e host=f0000001 deploy_worker_c2.yaml

# 启动所有进程
ansible-playbook -e host=f0000001 c2_start.yaml

# 检查进程状态
ansible f0000001-c2 -m shell -a "pgrep -c lotus"

# Miner检查进程注册数量
lotus-miner sealing jobs |egrep -c ':200[1-4]0'
```



### 4.2 常见硬件故障

#### 4.2.1 掉显卡

```bash
重启机器, 恢复则启动服务, 失败则通知相关技术处理

Miner恢复启动步骤
1. 启动lotus
2. lotus wait sync 等待区块高度同步结束
3. 启动lotus-miner
4. lotus-miner info 确认启动正常

P1-worker恢复启动步骤
1. 启动apx
2. 启动p2
3. 后台方式启动p1
4. 最后确认所有进程正常启动

C2-worker恢复启动步骤
1. 启动C2
2. 确保进程正常注册miner
```

#### 4.2.2 掉盘

```
重启机器, 恢复则启动服务, 失败则通知相关技术处理
```

#### 4.2.3 网卡频繁 up/down 

```
通知相关技术排查更换
```

#### 4.2.4 内存寻址错误

```
通知相关技术排查更换
```



### 4.3 常见软件故障

#### 4.3.1 P1 故障

```bash
1. 检查进程是否正常启动
2. 检查是否被P2堵住, P2应该不间断做任务, 任务时间是否在预期内(18-20)
3. 检查是否被C2堵住，C2跟不上P1生产? C2运行异常? 
4. 检查是否 APx finalize 阶段是否正常，是否正确落盘? 
5. 模板数据异常

......
```

#### 4.3.2 C2 故障

```
1. 证明参数
2. 显卡是否正确绑定
......
```

#### 4.3.3 ApX 故障

```
......
```

#### 4.3.4 P2 故障

```
......
```

#### 4.3.4 Lotus 故障

```
同步区块高度异常
1. 联系网络同事排障

服务启动异常, 数据损坏
1. 重新部署
```

#### 4.3.5 Miner 故障

```bash
无法启动
1. lotus是否正常运行
2. lotus区块高度同步未完成
3. 存储路径异常
......

数据库损坏
1. 迁移报错日志中文件至其他临时目录
2. 离线导出元数据 lotus-miner backup --offline /opt/raid0/minerbackup/xxx.cbor
   参考：https://blog.csdn.net/yishui_hengyu/article/details/116588697
3. 从备份服务器拷贝最新的备份尝试启动
4. 准备跑路
......
```



### 4.4 常用命令

#### lotus

```bash
# 停止进程
lotus daemon stop

# 查看同步状态
lotus sync wait 

# 列出钱包地址
lotus wallet list

# 查看本节点所监听的地址
lotus net listen

# 查看连接的节点列表
lotus net peers

# 手动连接其他节点
lotus net connect <PEER_ADDR>

# 创建一个 BLS 钱包
lotus wallet new bls

# 查看钱包列表
lotus wallet list 

# 查看钱包余额
lotus wallet balance

# 导出钱包私钥到文件
lotus wallet export wallet >file

# 导出快照
lotus chain export --skip-old-msgs --recent-stateroots=900 chain.car

# 导入快照
lotus daemon --import-snapshot chain.car

# 列出等待上链消息
lotus mpool pending --local

# 消息堵塞, 手动上链
for i in `lotus mpool pending --local --cids`; do lotus mpool replace --gas-feecap 18000000000 --gas-premium 2708563 --gas-limit 48490216 $i && sleep 1;done
```

#### lotus-miner

```bash
# 停止进程
lotus-miner stop

# 查看矿工当前信息，包括算算力，密封情况
lotus-miner info

# 质押一个由随机数据填充的扇区(垃圾数据)
lotus-miner sectors pledge

# 列举所有扇区信息
lotus-miner sectors list

# 快速列举所有扇区信息
lotus-miner sectors list --fast

# 快速列举某个状态类型扇区
lotus-miner sectors list --fast --states <sector_status>

# 查看某个扇区的当前状态
lotus-miner sectors status <sector_id>

# 查看 sector 详细日志
lotus-miner sectors status --log 1

# 批量封装失败扇区
lotus-miner sectors list --fast --states SealPreCommit1Failed |awk 'NR>1{print "lotus-miner sectors update-state --really-do-it "$1" Removed"}'|bash

# 删除链上扇区
lotus-miner sectors terminate --really-do-it <sector_id>

# 列出所有的worker:
lotus-miner sealing workers

# 列出所有的job
lotus-miner sealing jobs

# 放弃某个job
lotus-miner sealing abort <callid>

# 批量放弃失联job
lotus-miner sealing jobs |awk '/ret-wait/{print "lotus-miner sealing abort "$1}'

# 导出调度队列
lotus-miner sealing sched-diag

# 暂停给worker派发新任务
lotus-miner worker-pause -tt <ap|p1|p2|c1|c2|fin|all> --uuid <uuid>

# 恢复给worker派发新任务
lotus-miner worker-resume --uuid <uuid>

# 暂停给所有worker派发新任务
lotus-miner worker-pause --uuid all

# 恢复给所有worker派发新任务
lotus-miner worker-resume --uuid all

# 查询扇区存储路径
lotus-miner storage find <sector_id>

# 增加/更新存储路径
lotus-miner storage attach /path/to/persistent_storage

# 提币 ( 转存到owner钱包 )
lotus-miner actor withdraw [amount (FIL)]

3000 

# 列出miner使用的钱包
lotus-miner actor control list --verbose

# 备份元数据 
lotus-miner backup /opt/raid0/minerbackup/xxx.cbor

# 离线备份元数据
lotus-miner backup --offline /opt/raid0/minerbackup/xxx.cbor

# 通过元数据恢复
lotus-miner init restore /opt/raid0/minerbackup/xxx.cbor
```

#### lotus-worker

```bash
# 在worker端，列出所有worker
export LOTUS_MINER_API=xxxxxxx （启动脚本里面有）
lotus-worker workers list
```



## 五、概念相关

### 5.1 扇区生命周期及状态管理

扇区是Filecoin网络中的数据存储单元，目前主网的扇区大小有32GiB和64GiB。

#### 5.1.1 扇区生命周期详解

Filecoin网络的扇区，需要通过一系列的计算过程，最终得到扇区内数据的证明结果，并存储到区块链上。

扇区的主要计算过程包括：PreCommit1(PC1)、PreCommit2(PC2)、Commit2(C2)三个过程。

64G 计算PC1的过程大约需要5小时30分-6小时，PC2需要18-20分钟，C2需要10-12分钟。

32G 计算PC1的过程大约需要3小时，PC2需要8-10分钟，C2需要8-10分钟。

#### 5.1.2 随机数扇区生命周期

随机数扇区即通过lotus-miner sectors pledge生成的扇区，扇区中存储的都是没有实际价值的随机数，目前仅仅是为了承诺有效算力。可以通过操作，将随机数扇区声明为有效数据存储的扇区。

#### 5.1.3 扇区状态管理 (v1.9.0)

扇区主要状态包括：PreCommit1、PreCommit2、Committing、FinalizeSector，状态变化如下图所示：

![](https://github.com/x-bytes/lotus-ops/raw/master/images/sector-state.png)

##### 5.1.3.2 删除扇区

```bash
方式一： 
	lotus-miner sectors update-state --really-do-it <sectorId> Removed 
	
方式二：
	lotus-miner sectors remove --really-do-it <sectorId>
```



### 5.2 博文学习

[Filecoin 工作原理](https://www.r9it.com/20190226/how-filecoin-work.html)



## 六、日志分析

> Filecoin日志分析.docx



