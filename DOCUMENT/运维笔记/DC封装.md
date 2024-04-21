## DC封装

1，lotus，lotusminer，lotusworker程序需要1.17.0以上

版本低于1.17.0需要部署boost v1.2.0的，默认是v1.4.0

#### 部署boost接单程序，在miner机器上部署

###### 1，部署go程序

```bash
wget -c https://golang.org/dl/go1.18.1.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local

echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc && source ~/.bashrc
```

###### 2，部署rsut程序

```bash 
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh     
屏幕输出    填1
source "$HOME/.cargo/env"
```

###### 3，安装依赖

```bash
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt install mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config curl clang build-essential hwloc libhwloc-dev wget -y
#git拉代码失败的话，需要删除/opt/raid/boost/boost后多安装几次依赖
```

###### 4，刷环境变量

```bash
export RUSTFLAGS="-C target-cpu=native -g"
export FFI_BUILD_FROM_SOURCE=1
```

###### 5，拉代码

```bash
mkdir /opt/raid0/boost
cd /opt/raid0/boost

git clone https://github.com/filecoin-project/boost
cd boost
make build
sudo make install
```

###### 6,获取4个环境变量

```bash
export $(lotus auth api-info --perm=admin)
export $(lotus-miner auth api-info --perm=admin)

export APISEALER=`lotus-miner auth api-info --perm=admin`
export APISECTORINDEX=`lotus-miner auth api-info --perm=admin`

把这4个变量写入/opt/raid0/boost/profile
```

###### 7，初始化boostd

```bash
source  /opt/raid0/boost/profile
boostd --vv init \
       --api-sealer=$APISEALER \
       --api-sector-index=$APISECTORINDEX \
       --wallet-publish-storage-deals=$PUBLISH_STORAGE_DEALS_WALLET \
       --wallet-deal-collateral=(写入worker钱包地址) \
       --max-staging-deals-bytes=50000000000
```

###### 8，启动脚本

```bash
#创建boost启动脚本
vim /opt/raid0/boost/start_boost.sh

#!/bin/bash
source  /opt/raid0/boost/profile
logbak=/opt/raid0/boost/logbak
time=`date +%Y%m%d%H%M%S`
[ -f /opt/raid0/boost/logs ] && mkdir -p $logbak && mv /opt/raid0/boost/logs $logbak/miner_${time}.log
nohup boostd --vv run  > /opt/raid0/boost/logs 2>&1 &

#启动boost脚本
bash /opt/raid0/boost/start_boost.sh
```

###### 9,修改boost配置文件

vim ~/.boost/config.toml

```bash
[API]
  ListenAddress = "/ip4/127.0.0.1/tcp/1288/http"
  RemoteListenAddress = "127.0.0.1:1288"
  Timeout = "30s"
  
[Libp2p]
  ListenAddresses = ["/ip4/39.109.85.24/tcp/12288", "/ip6/::/tcp/12288"]
  AnnounceAddresses = ["/ip4/39.109.85.24/tcp/12288"]
  
[Wallets]
  Miner = "f01943316"
  PublishStorageDeals = "f3tgbpvqo3t53i47gmligo7gavizcjpxttontlbhvfifwkblwpzegdfci4daeqhwk7wmjcec6thoudntathzjq"
  DealCollateral = "f3tgbpvqo3t53i47gmligo7gavizcjpxttontlbhvfifwkblwpzegdfci4daeqhwk7wmjcec6thoudntathzjq"
  PledgeCollateral = ""

[LotusFees]
  MaxPublishDealsFee = "0.5 FIL"
  MaxMarketBalanceAddFee = "0.07 FIL"
```

###### 10,修改调度miner的配置文件

vim /opt/raid0/lotusminer-sealing/lotusminer/config.toml

```bash
#最底下面添加
[Subsystems]
  EnableMining = true
  EnableSealing = true
  EnableSectorStorage = true
  EnableMarkets = false
```

vim  /opt/raid0/lotusminer-sealing/profile

```bash
#真实数据
export FIL_PROOFS_USE_MULTICORE_SDR=1
export LOTUS_MARKETS_PATH=/root/.boost
```

修改完后重启调度miner和boost

```bash
pgrep lotus -a | grep lotusminer-sealing  |awk   '{print "kill -9 "$1}' |bash
pgrep boost -a |awk   '{print "kill -9 "$1}' |bash

bash /opt/raid0/lotusminer-sealing/start_lotusminer.sh
bash /opt/raid0/boost/start_boost.sh
```



###### 11,调度miner发布p2p地址

lotus-miner actor set-addrs  "/ip4/39.109.85.24/tcp/12288"     

###### 12，随便找个miner询价测试

```bash
#询价命令
lotus client query-ask    f01943316
#询价卡住不返回结果是询价失败

#查询节点的pees ID
lotus state miner-info  f01943316
#查询miner的pees ID和boost的pees ID 对比
lotus-miner  net id
boostd  net id 
#以boostd的peers ID为准，在调度miner上更换bootsd的peers ID
lotus-miner actor set-peer-id  12D3KooWBZL9NUDNUdBfMFpAQSxxMoGs57GAE3x7kuQiLkWVGbfA
#再次询价后可以了
lotus client query-ask    f01943316
Ask: f01943316
Price per GiB: 0.0000000005 FIL
Verified Price per GiB: 0.00000000005 FIL
Max Piece size: 64 GiB
Min Piece size: 256 B

#需要把Price和Verified的价格改为0，在调度miner上操作
lotus-miner storage-deals  set-ask  --price 0.0000000   --verified-price 0.0000000  --min-piece-size 1GB    --max-piece-size 64GB

#再次询价
lotus client query-ask  f01943316
Ask: f01943316
Price per GiB: 0 FIL
Verified Price per GiB: 0 FIL
Max Piece size: 64 GiB
Min Piece size: 1 GiB
```

###### 13,转币到market

```bash
#lotus 使用worker钱包转币到market
#--from是指定哪个钱包地址
#--address是指定哪个miner的market
#后面跟着的数量表示为多少fil
lotus wallet market  add --from  f3tgbpvqo3t53i47gmligo7gavizcjpxttontlbhvfifwkblwpzegdfci4daeqhwk7wmjcec6thoudntathzjq  --address f01943316  99
```

###### 14，boostd导入订单

```bash
#boost导入订单，根据客户端提供的信息导入DC订单
boostd import-data   <uuid>    <carfile的绝对路径>
```

## DC发单

#### 部署boost发单程序

###### 1，部署go程序

```bash
wget -c https://golang.org/dl/go1.18.1.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local

echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc && source ~/.bashrc
```

###### 2，部署rsut程序

```bash 
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh     
屏幕输出    填1
source "$HOME/.cargo/env"
```

###### 3，安装依赖

```bash
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt install mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config curl clang build-essential hwloc libhwloc-dev wget -y
#git拉代码失败的话，需要删除/opt/raid/boost/boost后多安装几次依赖
```

###### 4，刷环境变量

```bash
export RUSTFLAGS="-C target-cpu=native -g"
export FFI_BUILD_FROM_SOURCE=1
```

###### 5，拉代码

```bash
mkdir /opt/raid0/boost
cd /opt/raid0/boost

git clone https://github.com/filecoin-project/boost
cd boost
make build
sudo make install
```

###### 6，初始化boost

```bash
#获取lotus的api
lotus auth api-info --perm admin 

#初始化boost
boost -vv init
```

###### 7，boost发单

```bash
#先向miner询价，价格为0就可以发单
lotus client query-ask  <miner_id>

#boost发单命令
boost offline-deal  --verified=true  --provider=f01****     --duration=1526400  --commp=baga6ea4seaqa23hr*****   --car-size=23890224298  --start-epoch=2317000   --piece-size=34359738368  --payload-cid=0    --payload-cid=bafybeideta5t****

#offline-deal       #表示订单为离线订单
#--verified         #表示订单已验证  
#--provider         #存储提供商节点号 
#--duration         #订单封装成扇区后的生命周期
#--commp            #切car生成的piece_cid
#--car-size         #carfile文件的大小，需要字节用量 
#--start-epoch      #订单到期高度，不能超过7天（也就是说一个订单发出去后，7天内不封装完就会过期）
#--piece-size       #发出去订单的大小（精确到字节，32G=34359738368）
#--storage-price    #存储的价格（值必须为0）
#--payload-cid      #切car生成的deal_cid
```

## singularity（奇点）

#### 切car工具

###### 1，拉代码，构建程序

```bash
#安装环境
# Install nvm (https://github.com/nvm-sh/nvm#install--update-script)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.bashrc
nvm install 16

#拉代码，构建程序
git clone https://github.com/tech-greedy/singularity.git
cd singularity
npm ci
npm run build
npm link
singularity -h

#有可能需要依赖
git clone https://github.com/tech-greedy/go-generate-car.git
cd go-generate-car
make
```

###### 2，初始化singularity

```bash
#初始化
singularity init

#启动singularity守护进程（后台运行）
tmux  
export SINGULARITY_PATH=/the/path/to/the/repo
singularity  daemon

#配置文件在/the/path/to/the/repo目录下，使用外部mongodb可以在里面配置，切car任务数量和切car大小比例也在配置文件里面，singularity也是一个发单工具，发单工具不好用，发单还是得boost工具

#singularity 配置文件
vim  /the/path/to/the/repo/default.toml

[deal_preparation_service]     
minDealSizeRatio = 0.55        #car最小比例
maxDealSizeRatio = 0.95        #car最大比例 

[deal_preparation_worker]
num_workers = 30               #car线程，默认是4个线程（一个线程消耗1个cpu核心）
```

######  3，singularity命令的使用

```bash
#singularity切car是以数据目录为单位去切，建议一个数据目录不要超过20T(简称为数据集)

#切car命令，（时间比较长，建议放tmux）
singularity   prep  create  <数据集名字>   <数据集源路径>  <切好后数据集存放路径>

#查看数据集
singularity prep   list

#查看car数据
singularity prep   status   <数据集名字>

#删除数据集（加上--purge，删除数据集和数据）
singularity prep remove  <数据集名字>
```



