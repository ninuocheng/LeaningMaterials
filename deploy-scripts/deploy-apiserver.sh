#/bin/bash

# k8s 发布代码

# 变量设置
time_build=`date "+%Y-%m-%d_%H_%M_%S"`
project_name='titan-apiserver'
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
run  mkdir ttf
COPY  apiserver /app/
COPY  docs/apiserver /app/docs/apiserver
COPY  config.toml   /app/config/config.toml
COPY  ttf/comic.ttf   /app/ttf/comic.ttf
COPY  datajson /app/datajson
COPY  pay  /app/pay
EXPOSE 3100
ENTRYPOINT ["/app/apiserver","-c","/app/config/config.toml" ]

EOF


echoGreen "创建yaml文件"
cat > apiserverv.yaml << EOF
Name: bdnft-api-srv
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

#echoGreen '开始初始化文档'
#/data/gopath/bin/swag init --exclude internal/foreignserver,internal/mapiserver -o docs/apiserver -g cmd/apiserver/main.go
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
cp  /data/titan-nft/deploy/config/config.toml .
echoGreen '开始编译代码'
go env -w GOPROXY=https://goproxy.cn
CGO_ENABLED=0 GOARCH=amd64 GOOS=linux &&  /usr/local/go/bin/go build -tags=release -a -o  apiserver  ./cmd/apiserver/main.go
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

