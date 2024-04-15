

# filecoin运维文档

## 一、filecoin四个阶段概述

```bash
P1：precommit1  加密并分隔原始数据封装为11个layer文件(32G或者64G)，确保数据安全及隐私
P2：precommit2 读取生成的11个文件，并推算出一个结果文件，为检索数据做准备
C1：commit1 校验P2生成的结果文件，为C2提交复制证明准备运算数据
C2：commit2 提交复制证明，用于证实矿工确实对客户的订单数据进行了存储，并为提交时空证明做准备。
```

![img](https://user-images.githubusercontent.com/1715211/110258389-570e7f80-7fdd-11eb-9654-2c0e6dfa9ba2.png)

进程介绍：

​	miner：lotus和lotus-miner

​	P1：目前为64G异构方案，14个p1进程，一个apx进程，以及一个p2进程

​	C2：4个c2进程

​	配比：一台C2配9台P1

## 二、常用的filecoin操作

#### 2.1、lotus

* 查看lotus的进程是否正常

```bash
pgrep lotus -a
```

* 停止进程

```bash
lotus daemon stop
```

* 查看本节点所监听的地址

```bash
lotus net listen
```

* 查看连接的节点列表

```bash
lotus net peers
```

* 手动连接其他节点

```bash
lotus net connect <PEER_ADDR>
```

* 查看lotus的高度是否是done

```bash
lotus sync wait
```

* 查看lotus的运行日志

```bash
tail -f /opt/raid0/lotus/logs
```

* 列出等待上链消息

```bash
lotus mpool pending --local
```

* 上链脚本

```bash
#!/bin/bash
echo "开始执行上链"
time_date=`date +"%Y-%m-%d %H:%M.%S"`
echo "当前时间 $time_date"
source  /opt/raid0/profile
for i in `/usr/local/bin/lotus mpool pending --local --cids`; do /usr/local/bin/lotus  mpool replace --auto --gas-feecap 25000000000 --gas-premium 3708563 --gas-limit 59490216 $i && sleep1;done
echo "上链ok·"
```



* 导出快照

```bash
lotus chain export --skip-old-msgs --recent-stateroots=900 chain.car
```

* 导入快照

```bash
lotus daemon --import-snapshot chain.car
```







#### 2.2、lotus-miner

* 查看矿工当前信息，包括算算力，密封情况

```bash
lotus-miner info
```

* 查看miner的进程是否正常

```bash
pgrep lotus -a
```

* 查看miner的运行日志

```bash
tail -f /opt/raid0/lotusminer/logs
```

* 查看任务数jobs，并以主机名统计排列

```bash
lotus-miner sealing  jobs|awk 'NR>1{host[$4":"$5]+=1}END{for(i in host)print i,host[i]}'|sort -nk2 |column -t
```

* 放弃某个job

```bash
lotus-miner sealing abort <callid>
```

* 批量放弃失联job

```bash
 lotus-miner sealing jobs |awk '/ret-wait/{print "lotus-miner sealing abort",$1,"&& lotus-miner sectors update-state --really-do-it  "$2"  Removed"}'| bash
```

* 导出调度队列

```bash
lotus-miner sealing sched-diag
```

* 暂停给worker派发新任务

```bash
lotus-miner worker-pause -tt <ap|p1|p2|c1|c2|fin|all> --uuid <uuid>
```

* 恢复给worker派发新任务

```bash
lotus-miner worker-resume --uuid <uuid> --tt all
```

* 暂停给所有worker派发新任务

```bash
lotus-miner worker-pause --uuid all --tt all
```

* 暂停给某个worker停掉所有任务

```bash
lotus-miner sealing workers | grep f01215328-p1-192-168-51-133 | awk -F'[, ]+' '{print "lotus-miner worker-pause --tt all --uuid",$2}'| bash
```



* 查看worker数量，并以主机名统计排列

```bash
lotus-miner sealing workers|awk 'NR>1{host[$4":"$5]+=1}END{for(i in host)print i,host[i]}'|sort|column -t
```

* 清除所有的worker

```bash
lotus-miner sealing workers  | grep -w 矿工号  | awk -F '[, ]' '{print "lotus-miner worker-remove --uuid",$2}' | bash
```

* 删除disabled或者是pause的worker

```bash
lotus-miner sealing workers  | egrep  "disable|pause"  | awk -F '[, ]' '{print "lotus-miner worker-remove --uuid",$2}' | bash
```





#### 2.3、扇区

* 列出所有扇区

```bash
lotus-miner sectors list --fast
```

* 创建扇区封装任务

```bash
lotus-miner sectors pledge
```

* 查看某个扇区的日志

```bash
lotus-miner sectors status --log  <sector_id>
```

* 终止链上的扇区

```bash
lotus-miner sectors terminate --really-do-it <sector_id>
```

* 快速列举某个状态类型扇区

```bash
lotus-miner sectors list --fast --states <sector_status>
```

* 处理异常扇区

```bash
PreCommitFailed: lotus-miner sectors remove --really-do-it <sectorId>
SealPreCommit1Failed: lotus-miner sectors remove --really-do-it <sectorId>
CommitFailed: lotus-miner sectors update-state --really-do-it <sectorId> Committing
```

* 批量remove错误扇区

```bash
tail -100 /opt/raid0/lotusminer/logs| egrep "(SealPreCommit2Failed|SealPreCommit1Failed|CommitFailed|CommitFinalizeFailed)"  |awk '{print $5}' | grep ',' | egrep '[0-9]{3,6}'  -o  |awk '{print "lotus-miner sectors update-state --really-do-it " $1 " Removed"}'
```

* 放弃任务和移除扇区

```bash
lotus-miner sealing jobs | grep  -w   f0469055-c2-192-168-33-46 | awk '{print "lotus-miner sealing  abort " $1" && lotus-miner sectors update-state --really-do-it "$2" Removed" }'

lotus-miner sealing jobs | awk 'NR>1{print "lotus-miner sealing abort",$1,"&& lotus-miner sectors update-state --really-do-it "$2" Removed"}' | bash
```





#### 2.4、存储

* 增加/更新存储路径

```bash
lotus-miner storage attach /path/to/persistent_storage
```

* 查询扇区存储路径

```bash
lotus-miner storage find <sector_id>
```

* 初始化存储目录

  > 这里的存储目录一定是共享存储，worker上完成封装的扇区最后会写入共享存储，所以worker(P1机器)也需要进行挂载，且必须同样的挂载路径，worker并不知道本地有这个路径，由miner告诉worker往哪里存。

```bash
source /opt/raid0/profile
lotus-miner storage attach --store --init 挂载路径
```





#### 2.6、钱包管理

* 查看钱包列表

```bash
lotus wallet list 
```

* 创建一个BLS钱包

```bash
lotus wallet new bls
```

* 查看钱包余额

```bash
lotus wallet balance
```

* 导出钱包私钥到文件

```bash
lotus wallet export wallet  >file
```

* 提币(转到owner钱包)

```bash
lotus-miner actor withdraw [amount (FIL)]
```

* 列出miner使用的钱包

```bash
lotus-miner actor control list --verbose
```

* 转币

```bash
lotus send --from  owner钱包地址   对方钱包地址   币数量
```

* 导出私钥

```bash
lotus wallet export  钱包地址
```





#### 2.5、数据备份和恢复

* 备份元数据

```bash
lotus-miner backup /opt/raid0/minerbackup/xxx.cbor
```

* 离线备份元数据

```bash
lotus-miner backup --offline /opt/raid0/minerbackup/xxx.cbor
```

* 通过元数据恢复

```bash
lotus-miner init restore /opt/raid0/minerbackup/xxx.cbor
```

#### 2.6、显卡驱动

```bash
1、卸载系统里的Nvidia低版本显卡驱动
sudo apt-get purge *nvidia*
sudo apt-get --purge remove "*nvidia*"
sudo apt autoremove

2、把显卡驱动加入PPA
sudo add-apt-repository ppa:graphics-drivers
sudo apt-get update

3、查找显卡驱动最新的版本号
sudo apt-cache search nvidia

4、使用终端命令查看Ubuntu推荐的驱动版本
sudo ubuntu-drivers devices
 
5、安装Nvidia驱动，假设我们想装460的版本
sudo apt-get install nvidia-driver-460

6、重启
sudo reboot

7、验证驱动是否安装成功
nvidia-smi
```

#### 2.7、硬盘调优

```bash
1、查看现有硬盘参数，如果显示128为正常，否则需要修改
cat /sys/block/nvme*n1/queue/max_sectors_kb

2、优化如下
cat > /etc/udev/rules.d/71-block-max-sectors.rules <<EOF
ACTION=="add", SUBSYSTEM=="block", RUN+="/bin/sh -c '/bin/echo 128 > /sys%p/queue/max_sectors_kb'"
EOF

3、重启服务器生效
reboot
```

#### 2.8、cpu开启性能模式

```bash
# 安装cpufrequtils
sudo apt-get install cpufrequtils -y

#把cpu调整到性能模式
sudo cpufreq-selector -g performance

# 安装sysfsutils
sudo apt-get install sysfsutils

# 开机自动性能模式
cat > /etc/sysfs.conf <<EOF
devices/system/cpu/cpu0/cpufreq/scaling_governor = performance
EOF
```



#### 2.9、西数硬盘升级固件

```bash
1、下载固件包
wget --user=za --password=za@2021 http://download.zhianidc.com/application/westdata/SN640_FW_R1110021.zip -P /tmp/

2、解压并做软连接
unzip /tmp/SN640_FW_R1110021.zip /tmp/
unzip /tmp/SN640_FW_R1110021/dm-2.3-Linux-tar-gz.zip -d /tmp/
tar xf /tmp/dm-2.3.1-Linux.tar.gz -C /usr/local/
ln -s /usr/local/dm-2.3.1-Linux/bin/dm-cli /usr/local/bin/dm-cli

3、处理无法读写的ssd，需要格式化，更新固件不会破坏SSD原有数据，不需要断电。但是SSD读写必须停止
# 扫描现有硬盘配置 
dm-cli scan 

# 格式化擦除ssd
dm-cli format -p /dev/nvme0
dm-cli format -p /dev/nvme1
dm-cli format -p /dev/nvme2
dm-cli format -p /dev/nvme3

4、查看当前固件版本
dm-cli manage-firmware --list --path /dev/nvme0 --output-format mini

5、升级固件
# 都为succeeded则为成功
dm-cli manage-firmware --load --file /tmp/SN640_FW_R1110021/aspenplus_GN_R1110021.vpkg --slot 2 --path /dev/nvme0
dm-cli manage-firmware --load --file /tmp/SN640_FW_R1110021/aspenplus_GN_R1110021.vpkg --slot 2 --path /dev/nvme1
dm-cli manage-firmware --load --file /tmp/SN640_FW_R1110021/aspenplus_GN_R1110021.vpkg --slot 2 --path /dev/nvme2
dm-cli manage-firmware --load --file /tmp/SN640_FW_R1110021/aspenplus_GN_R1110021.vpkg --slot 2 --path /dev/nvme3

6、激活硬盘
dm-cli manage-firmware --activate --slot 2 --path /dev/nvme0
dm-cli manage-firmware --activate --slot 2 --path /dev/nvme1
dm-cli manage-firmware --activate --slot 2 --path /dev/nvme2
dm-cli manage-firmware --activate --slot 2 --path /dev/nvme3

7、如果没有报错，重启生效
reboot

8、查看是否都升级成功
nvme list 或者 dm-cli manage-firmware --list --path /dev/nvme0 --output-format mini
```







## 三、算力封装

#### 3.1、全新算力P1封装

* 迁移步骤迁移算力机标准流程分两个大步骤
  一：老的集群。
  1.1 停监控告警
  1.2 确认是否落盘或者在落盘或者C2
  1.3 清理miner上的jobs任务
  1.4 在worker上pkill要迁移机器的进程
  1.5 在miner上将要迁移的worker机器的uuid，移除
  二：要加去的集群
  2.1 删除机器的/opt/raid0/workercache目录
  2.2 在worker-apx目录下除了start_apx.sh和init_apx.sh两个脚本，全部删除
  2.2 修改需要迁移worker机器的主机名
  2.3 更新/opt/lotusworker/profile文件
  2.4 确认程序版本，模板参数，证明参数(同构需要)
  2.5 启动所有worker-p1的，确认ok，启动apx并init
  2.6 umount现有存储，重新挂载新存储，修改/etc/fstab
  2.7 启动P2或者C2，并确认ok
  2.8 miner上下发任务，并开启定时任务封装脚本
  2.9 启动监控告警fcmonit
  3.0 修改ansible清单，jumpserver等



```bash
filnum=f88888

1、检查是否有做软raid0
ansible $filnum-p1 -m shell -a "df -h /opt/raid0"

2、如果没有做，我们需要手动制作raid0
mdadm -Cv /dev/md0 -a yes -n 磁盘数量 -l RAID级别 数据盘1 数据盘2 ....
mdadm -Cv /dev/md0 -a yes -n 4 -l 0 /dev/nvme0n1 /dev/nvme1n1 /dev/nvme2n1 /dev/nvme3n1 
mdadm -D --scan >/etc/mdadm.conf
mkfs.xfs -f /dev/md0
ls -l /dev/disk/by-uuid/|awk '/md0/{print "echo \"/dev/disk/by-uuid/"$9" /opt/raid0 xfs defaults 0 0\" >>/etc/fstab"}'|bash 
mkdir /opt/raid0 -p
mount -a

# 确认挂载正确
df -h /opt/raid0

3、拷贝数据模板，并确认文件数量和大小完整/opt/raid0/{filecoin-parents,merklecache,piecetemplate}
ansible $filnum-p1 -m raw -a 'tree -h /opt/raid0/{filecoin-parents,merklecache,piecetemplate}'

4、执行部署安装playbook脚本
ansible-playbook -e host=$filnum /etc/ansible/filecoin/deploy_worker_p1.yaml

5、首次部署结束后需要进行重启woerker, 使其hugepage配置生效
ansible $filnum -m reboot

6、重启之后检查hugepage分配是否正确
ansible $filnum-p1 -m shell -a "cat /sys/devices/system/node/node*/hugepages/hugepages-1048576kB/nr_hugepages"

7、重启之后检查显卡驱动是否正常
ansible $filnum-p1 -m shell -oa "nvidia-smi -L"
```

* 挂载nfs
  * 如果是新的nfs集群加入，需要miner和p1时部署nfs客户端

```bash
sudo apt-get install nfs-common -y

```





* 挂载ceph

  * 如果是新的ceph集群加入，需要

  



#### 3.2、迁移算力机

```bash
filnum=f01227383

1、在旧miner上确认是否还在封装

2、停掉监控fcmonit
ansible $filnum-p1 -m shell -a "systemctl stop fcmonit"

3、查看旧的lotus-worker进程，并关闭进程
ansible $filnum-p1 -m  shell  -a  "pkill lotus"

4、检查是否关闭交换分区，如果关闭了就跳过
ansible-playbook  -e host=$filnum-p1  /etc/ansible/filecoin/disable_swap.yml

5、检查超线程
ansible $filnum-p1 -m  shell  -a  "lscpu|grep 'Thread(s) per core'"

6、修改主机名
ansible $filnum-p1 -m  shell  -a  " sed -i   's/f01021773/f0469055/g'  /etc/hostname"

7、清理旧数据
ansible $filnum-p1 -m  raw  -a  "rm -rf /opt/raid0/workercache/cache/* && rm -rf /opt/raid0/workercache/sealed/* && rm -rf /opt/raid0/workercache/unsealed/*"

8、删除旧集群的p1的profile文件
ansible $filnum-p1 -m  raw  -a  "rm -f /opt/lotusworker/profile"

9、在ansible临时目录下创建profile文件，并发到所有的p1机上
	1、miner上获取api信息
	paste -d ':' /opt/raid0/lotusminer/token /opt/raid0/lotusminer/api
	2、将获取到的信息填写到ansible的/tmp目录下
	echo 'export MINER_API_INFO="上面获取的token连接信息"' > /tmp/profile-$filnum
	3、批量传到所有的p1上
	ansible $filnum-p1 -m copy -a "src=/tmp/profile-$filnum dest=/opt/lotusworker/profile"
	
10、卸载老的nfs或者是ceph挂载点
ansible $filnum-p1 -m shell -a "df -h"
ansible $filnum-p1 -m shell -a "umount 挂载的ceph或者nfs路径"

11、更新fstab文件
ansible $filnum-p1 -m lineinfile  -a 'path=/etc/fstab regexp="ceph|nfs" state=absent'

12、确认下/etc/fstab是否删除
ansible $filnum-p1 -m shell -a "cat /etc/fstab"

13、将新的存储挂载信息追加到/etc/fstab
	1、如果是nfs，根据miner上实际的挂载批量导入到/etc/fstab,可以在ansible   
	
```



## 四、错误排查

#### 4.1、扇区任务排查

```bash
一、lotus-miner info发现CommitFinalizeFailed

处理步骤如下：
1、查出错误扇区id
lotus-miner sectors list --states CommitFinalizeFailed

2、查看详细报错
lotus-miner sectors status --log 扇区id

3、定位报错在哪一台worker
lotus-miner sectors status 扇区id

4、登录对应的worker机，查看apx的日志，发现是raid0故障，重新挂载raid0后恢复
tail -f /opt/lotusworker/worker-apx/log.txt
```



#### 4.2、token报错

```bash
一、JWT Verification failed，如果worker机上有类似错误，不断的返回连接旧的miner的报错IP

处理步骤如下：
1、登录miner机上，停掉所有该worker机的jobs，并且移除所有worker进程
lotus-miner sealing workers  | egrep  "disable|pause"  | awk -F '[, ]' '{print "lotus-miner worker-remove --uuid",$2}' | bash

2、再次在worker上检查是否还有JWT Verification类似的错误
```



#### 4.3、抽查常见错误处理

* 抽查常见的问题类别

>1. 从存储加载文件耗时太长、或者挂死
>2. 显卡证明过程中出错、奔溃
>3. 网络问题导致往主网提交证明失败



* 问题原因排查步骤

> 1. **检查抽查日志是否有错误**
>    `grep -i 'panic\|error\|failed'`，如果有错误，则先耐心读懂错误内容，实在无法理解的错误请咨询程序提供方。
>
> 2. **检查关注的窗口的抽查情况**
>    例如，当前关注的是索引为8的窗口，那么，我们 `grep -i '"index":8'`，根据grep到的结果不同，便有不同的结论。
>
>    如果没有看到对应该索引的`running window post`日志，则说明这个窗口还没有开始，没有开始的原因可能是抽查时间没到，又或者miner进程已经卡死导致无法正常开始这个窗口的抽查过程。
>
>    如果看到了`running window post`，说明抽查已经开始了，如果没有看到`computing window post`则说明这个窗口开始了但还没有结束，没有结束的原因可能是存储太慢或者显卡证明太慢。如果看到了`computing window post`说明计算已经结束，此时看看计算时间是否超时（例如，超过了30分钟），如果超时了那么肯定就抽查失败了。
>
>    对于没有看到`computing window post`，肯定的是该窗口的计算还没有结束，那么我们可以看看当前的时间，减去`running window post`日志的时间，就知道这个计算过程已经耗时了多久了。如果超过预期，那么我们应该仔细查看日志，看看卡在了哪一个[阶段](#%E6%8A%BD%E6%9F%A5%E8%BF%87%E7%A8%8B%E9%98%B6%E6%AE%B5)，例如是卡在显卡证明阶段？还是卡在读取存储阶段？
>
>    如果一切看起来都正常，那么此时就要考虑是否网络阻塞了，导致无法提交抽查结果。
>
>



* 抽查重合的处理

>所谓抽查重合，是指在某个窗口时间内，进行两个窗口抽查。这种情况在抽查超时的情况下，几乎必然发生。例如，当前时间段，应该进行第8个窗口的抽查，但是由于读取存储太慢（或者显卡证明太慢等等）导致第7个窗口还没有计算完毕，此时miner又开始第8个窗口的抽查计算。由于两个抽查同时进行着，那么只会慢上加慢，最后不管是第7，还是第8个，都会失败。甚至，第8个窗口在第9个窗口开始时都还没有结束，这就导致抽查一路重合下去，7，8，9，10……一路失败。
>
>此时我们应该要立即重启miner，由于miner重启后，它比较了当前的时间，发现已经到了第8个抽查窗口，他就会开始第8个窗口抽查，而放弃了第7个窗口，进而就避免了抽查重复。
>
>需要特别注意的是，重启抽查miner后，应该立即tail -f 他的log，确认它的行为是预期的，例如确认它开启的是第8个窗口的抽查，而不是第7个，因为如果重启的时机并不是在第8个窗口时间段内，而是第7个窗口的后期，那么miner会继续第7个窗口的抽查，此时我们唯有再次重启miner或者先停止miner等一小段时间，再启动miner以便彻底错开第7个窗口。



* 抽查过程阶段

>一个抽查加载及计算分为5部分，分别为：
>
>  1. 加载所有扇区p_aux文件，通过`grep 'load p_aux files end'`可以看到took时间。每个扇区的p_aux文件大小是64字节。
>  2. 加载所有扇区merkle tree root，通过`grep 'load merkle tree root: end'`可以看到took时间，每个扇区tree root大小是32字节。
>  3. 加载所有扇区merkle tree branch，通过`grep 'vanilla_proofs:finish windowPOST'`可以看到took时间。对于每个扇区，这个过程是需要反复多次读取sealed文件及每一层tree-r-last-*.dat文件的，每个扇区读取的总量大约是几十KB。
>  4. 显卡证明，通过`grep 'snark_proof:finish: windowPOST'`可以看到took时间
>  5. 关闭上述加载过程涉及到的文件句柄，通过比较`'generate_window_post:drop tree files'`和`'generate_window_post:finish'`两条日志之间的时间差获得该阶段耗时。有时候如果挂载点卡死，就会出现无法关闭文件（因为关闭文件需要挂载点及其文件系统响应）。
>
>步骤1~3是并行（具体并行数量取决于线程池线程数量配置，默认是CPU核数）读取存储的。窗口抽查除了加载及显卡计算时间，还有一些其他的时间开销，例如新封装的扇区发现等等，总的抽查耗时，以`computing window post`日志中的`elapsed`字段为准。



* 以抽查相关的环境变量

> 1. **FIL_PROOFS_WINDOW_POST_GPU**
>
>    该变量设置抽查时使用的显卡UUID，如果想使用多个显卡，那么用逗号分割填写多个显卡的UUID。
>
> 2. **BELLMAN_SYNTHESIZE_BATCH**
>
>    该变量设置进行显卡证明时，并发进行电路综合处理的数量，一般设置为4即可。这个变量影响的是证明过程中使用的CPU核心数量，因为电路综合是通过CPU进行的。
>
> 3. **BELLMAN_CALC_BATCH**
>
>    该变量设置进行显卡证明时，并发进行显卡计算处理的数量，这个值越大计算越快，但是这个值是由显卡的显存决定的，因此如果设置过大就会导致显卡显存不足，计算失败。对于显存小于20GB的卡，设置为2较为合适；对于显存大于20GB的卡，设置为4较为合适。例如，2080TI我们设置为2；3090我们设置为4；有些显卡显存小于8GB，这种显卡是没法进行抽查证明计算的，例如3070。
>
> 4. **BELLMAN_CUSTOM_GPU**
>
>    这个变量作用是，在显卡驱动无法获取到显卡的CUDA核心数量时，显式地指定显卡的CUDA数量，这样miner进行显卡证明时就能够合理地设置并发参数。目前根据测试，驱动版本460以及之前的都可以提供显卡CUDA核心数量。但是470以及更新的就不能提供了，需要设置该参数。具体来说，如果日志中，出现`WARN bellperson::gpu::utils > Number of CUDA cores for your device`，就表明需要通过该环境变量来设置CUDA核心数量了。某个显卡的CUDA核心数量，可以通过google得到。
>
> 5. **FIL_PROOFS_LOG_GEN_CACHED_PROOF**
>
>    这个变量的作用是，在加载merkle tree随机分支（这个阶段读取存储最多），把每个扇区的耗时打印出来。以便确定哪一个扇区较慢，通过找到该扇区所在的存储，进而可以到具体存储上排查原因。
>
> 6. **FIL_PROOFS_LOG_GEN_CACHED_PROOF_THRESHOLD**
>
>    这个变量的作用是设置FIL_PROOFS_LOG_GEN_CACHED_PROOF的工作阈值，单位是毫秒。默认是1000毫秒，也就是耗时大于等于1秒时才输出日志。



## 五、如何正确删除扇区

* 停任务的正确步骤是，先停apx，让机器把任务做完，等个7h，没有jobs后再把woker进程pkill  ，再remove掉所下机器的所有uuid
* 在你删除扇区之前请确保已经采取了必要的抢救措施，例如遇到存储故障，网络故障，调度故障等等，都要经过一系列的调试，故障诊断 ,最后再考虑删除扇区，谨慎删除扇区，别忘了，该命令有个选项--really-do-it



#### 5.1、如何删除packing,PreCommitFailed和SealPreCommit1Failed状态的扇区？

* 这几种状态因为还没有质押，可通过下面的命令直接删除。所有precommit阶段完成之前的扇区，都可以通过此方法删除。

```bash
lotus-miner sectors remove --really-do-it <sectorId>
```



####  5.2、如果删除状态为PreCommit1，PreCommit2，并且一直卡顿在这些状态的扇区？

* ##### 首先应尝试如下命令删除

```bash
lotus-miner sealing abort <JobId>
lotus-miner sectors remove <SectorId>
```



#### 5.3、不建议删除commitfailed. finalizedfailed　以及所有完成precommit或者完成provcommit的扇区

* 建议把错误扇区恢复成出错之前的状态，重新做出错的这个步骤

例：扇区commitfailed.此时precommit已经完成，重置扇区状态至commit1

```bash
lotus-miner sectors update-state --really-do-it <sectorId> Committing
```



#### 5.4、如何删除因为存储故障，无法恢复的扇区

* 删除扇区一定要先链上删除再本地删除，这样能最大程度的减少损失，请记住执行顺序，这个相当重要

* 对于已经上链的扇区，如果数据丢失或者恢复失败(RecoveryTimeout)，需要用下面的命令在链上销毁掉。
* 一次可以批量销毁多个扇区，**注意，链上销毁扇区会有惩罚，每销毁一个扇区大概要惩罚0.1个币**。

```bash
lotus-miner sectors terminate --really-do-it <sectorId-1> <sectorId-2>...
```

这一步的主要作用为清除链上数据，最大限度减少处罚

* ##### 等到扇区状态变为terminalfinality

* ##### 执行

```bash
cat  <sectorNum>
```

这一步的主要作用为清除存储



#### 5.6、删除扇区中最常范的错误

* 很多人会直接执行：lotus-miner sectors remove --really-do-it ,这是错误的。然后找不到扇区编号，也无法terminate. 这样的情况，可以通过

```bash
lotus-miner sectors list --fast --states Remomved
```

* 查看到扇区编号，这个时侯再执行

```bash
lotus-miner sectors terminate --really-do-it <sectorNum> 
```



##  六、扇区修复工具sealer-recover

>Filecoin在封装或挖矿过程中，可能面临扇区数据丢失，那么就要被销毁PreCommit预质押的FIL，或者终止扇区最大损失扇区的90天的收益。扇区修复能修复丢失的文件，来减少或者避免损失。
>
>矿商为了降低封装成本，不得不使用裸盘做存储，来降低成本，提高自己的竞争力，往往会直接使用裸盘做扇区的存储。 16T的盘，可以存储130多个32GiB扇区，如果损坏一个硬盘，数据无法恢复要终止扇区，最大损失扇区90天的全网平均收益。
>
>在这个情况下，扇区有2个状态会造成损失。
>
>- 扇区已经提交了PreCommit消息，但是30内未提交ProveCommit消息，会被销毁PreCommit预质押的FIL；
>- 设置 `FinalizeEarly=false`，使用先提交ProveCommit再落到存储，等同丢失扇区需要终止扇区。

#### 6.1、随便准备一台可用的算力机

#### 6.2、构建go环境

* 构建filecoin-sealer-recover，你需要安装[Go 1.16.4 or higher](https://golang.org/dl/)：

```bash
wget -c https://golang.org/dl/go1.16.4.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local
```



* 构建需要下载一些Go模块。这些通常托管在Github上，而Github来自中国的带宽较低。要解决此问题，请在运行之前通过设置以下变量来使用本地代理

```bash
export GOPROXY=https://goproxy.cn,direct
```



* 根据您的 CPU 型号，根据您的需要选择环境变量

a.如果您有AMD Zen 或 Intel Ice Lake CPU（或更高版本），请通过添加以下两个环境变量来启用 SHA 扩展的使用：

```bash
export RUSTFLAGS="-C target-cpu=native -g"
export FFI_BUILD_FROM_SOURCE=1
```



b.一些没有 ADX 指令支持的老式 Intel 和 AMD 处理器可能会因为非法指令错误而紊乱。要解决这个问题，添加 CGO_CFLAGS 环境变量:

```bash
export CGO_CFLAGS_ALLOW="-D__BLST_PORTABLE__"
export CGO_CFLAGS="-D__BLST_PORTABLE__"
```



c.默认情况下，证明库中使用“multicore-sdr”选项。 除非明确禁用，否则此功能也用于 FFI。 要禁用“multicore-sdr”依赖项的构建，请将“FFI_USE_MULTICORE_SDR”设置为“0”：

```bash
export FFI_USE_MULTICORE_SDR=0
```



* Build and install

>因为编译这个比较复杂，所以我们已经编译好，直接用我们编译好的二进制文件即可
>
>将 `sealer-recover` 解压后拷贝到` /usr/local/bin`目录下



* 查看版本

```bash
sealer-recover --version
```



* 使用方式

```bash
sealer-recover -h
```



* 启动方式

```bash
export FIL_PROOFS_USE_MULTICORE_SDR=1
export FIL_PROOFS_MAXIMIZE_CACHING=1
export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1
export FIL_PROOFS_USE_GPU_TREE_BUILDER=1

export FULLNODE_API_INFO=链节点的token
sealer-recover --miner=f01000 \
    --sectors=0 \ 
    --sectors=1 \ 
    --sectors=2 \     
    --parallel=6 \ 
    --sealing-result=/sector \ 
    --sealing-temp=/temp
```



#### 参数介绍

| 参数           | 含义                                               | 备注                                                         |
| -------------- | -------------------------------------------------- | ------------------------------------------------------------ |
| miner          | 需要修复扇区的矿工号                               | 必填                                                         |
| sectors        | 需要修复的扇区号                                   | 必填                                                         |
| parallel       | 修复扇区p1的并行数, *参考核心数进行设置*           | 默认值：1                                                    |
| sealing-result | 修复后的扇区产物路径                               | 默认值: ~/sector,可自行指定路径                              |
| sealing-temp   | 修复过程的中间产物路径，需要大空间，建议使用NVMe盘 | 默认值: ~/temp 最小空间: 32GiB # > 512GiB! 64GiB # > 1024GiB!，可自行指定路径 |

### 
