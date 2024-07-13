#/bin/bash
# k8s 发布代码

# 变量设置
time_build=`date "+%Y-%m-%d_%H_%M_%S"`
project_name='titan-nft_admin'
git_dir='/data/titan-nft/deploy'

##set color##
echoRed() { echo $'\e[0;31m'"$1"$'\e[0m'; }
echoGreen() { echo $'\e[0;32m'"$1"$'\e[0m'; }
echoYellow() { echo $'\e[0;33m'"$1"$'\e[0m'; }

echoYellow "cd 进入工作目录 $git_dir/music-nft-admin"
cd $git_dir/music-nft-admin

echoGreen "创建dockerfile文件"
cat > ${project_name}dockerfile << EOF
#开始封装nginx
FROM  registry.cn-hongkong.aliyuncs.com/nft/nginx:stable-alpine-brotli
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY   dist .
COPY nginx.conf  /etc/nginx/nginx.conf
ENTRYPOINT ["nginx", "-g", "daemon off;"]
EOF


echoGreen "创建部署文件"
cat > ${project_name}.yaml << EOF
Name: bdnft-admin
Services:
  - Image: registry.cn-hongkong.aliyuncs.com/nft/$project_name:$time_build
    CPU: 0.5
    Memory: 500
    Storage:
      Quantity: 500
    Ports:
      - Port: 80
        ExposePort: 80
    Env:
      VITE_REQUEST_BASE_URL: "61af1c9eeac7436ba16deab6cfc38c83.container2.titannet.io"
EOF





echoGreen "开始拉去代码"
cd $git_dir/music-nft-admin  && git pull  &&  git checkout main
#查看分支是否切换成功
git_branch=`git branch   | head -1`
echoGreen  "当前分支为: $git_branch"
echoGreen "开始编译代码"
/usr/local/node/bin/pnpm i && /usr/local/node/bin/pnpm build

if [ $? -eq 0 ];then
    echoGreen "代码编译成功 准备封装docker镜像......."
    echoGreen "生成镜像"
    docker build . -t registry.cn-hongkong.aliyuncs.com/nft/$project_name:$time_build  -f  ${project_name}dockerfile
    echoGreen "推送镜像"
    docker push registry.cn-hongkong.aliyuncs.com/nft/$project_name:$time_build
    
else
        echoRed "代码编译失败...."
        exit 2
fi

