#/bin/bash

# k8s 发布代码

# 变量设置
time_build=`date "+%Y-%m-%d_%H_%M_%S"`
project_name='titan-mapiserver'
git_dir='/data/titan-nft/deploy'

##set color##
echoRed() { echo $'\e[0;31m'"$1"$'\e[0m'; }
echoGreen() { echo $'\e[0;32m'"$1"$'\e[0m'; }
echoYellow() { echo $'\e[0;33m'"$1"$'\e[0m'; }


#
echoGreen 'cd 工作目录'
cd $git_dir/music-nft-api


echoGreen "创建dockerfile文件"
cat > apidockerfile << EOF
FROM centos:7.8.2003 

WORKDIR /app
run  mkdir log
COPY  mapiserver /app/
COPY  mapi-config.toml   /app/config/config.toml

EXPOSE 3100
ENTRYPOINT ["/app/mapiserver","-c","/app/config/config.toml" ]
EOF


echoGreen "创建yaml文件"
cat > apiserverv.yaml << EOF
Name: bdnft-mapi-srv
Services:
  - Image: registry.cn-hongkong.aliyuncs.com/nft/$project_name:$time_build
    CPU: 0.8
    Memory: 1000
    Storage:
      Quantity: 500
    Ports:
      - Port: 3100
        ExposePort: 80
EOF

#拉取代码
echoGreen "开始拉去代码"
cd $git_dir/music-nft-api  && git pull  &&  git checkout main
if [ $? -eq 0 ];then
        echoGreen "拉取代码成功......."
else
        echoRed "代码拉取失败...."
        exit 2
fi


#bianliang
export GOROOT=/usr/local/go
export GOPATH=/data/gopath
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

#echoGreen  '下载初始化文档工具'
#/usr/local/go/bin/go install github.com/swaggo/swag/cmd/swag@latest
#echoGreen '开始初始化文档'
#/data/gopath/bin/swag init --exclude internal/apiserver,internal/foreignserver -o docs/mapiserver -g cmd/mapiserver/main.go
#if [ $? -eq 0 ];then
#        echoGreen "初始化文档成功......."
#else
#        echoRed "初始化文档失败...."
#        exit 2
#fi


#查看分支是否切换成功
git_branch=`git branch   | head -1`
echoGreen  "当前分支为: $git_branch"
echoGreen "代码编译目录：`pwd`"


echoGreen 'copy配置文件'
cp  /data/titan-nft/deploy/config/mapi-config.toml .
go env -w GOPROXY=https://goproxy.cn
echoGreen '开始编译代码'
CGO_ENABLED=0 GOARCH=amd64 GOOS=linux && /usr/local/go/bin/go build -tags=release -a -o  mapiserver  ./cmd/mapiserver/main.go
if [ $? -eq 0 ];then
    echoGreen "代码编译成功 准备封装docker镜像......."
    echoGreen "生成镜像"
    docker build . -t registry.cn-hongkong.aliyuncs.com/nft/$project_name:$time_build  -f apidockerfile
    echoGreen "推送镜像"
    docker push registry.cn-hongkong.aliyuncs.com/nft/$project_name:$time_build
    
else
        echoRed "代码编译失败...."
        exit 2
fi

