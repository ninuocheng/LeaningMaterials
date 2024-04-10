#!/bin/bash

# Kubernetes 代码发布脚本

# 设置变量
time_build=$(date "+%Y-%m-%d_%H_%M_%S")
project_name='deploy-huygens-dashboard-test1'
git_dir='/data/titan-nft/deploy'

# 设置颜色输出函数
echoRed() { echo $'\e[0;31m'"$1"$'\e[0m'; }
echoGreen() { echo $'\e[0;32m'"$1"$'\e[0m'; }
echoYellow() { echo $'\e[0;33m'"$1"$'\e[0m'; }

# 执行命令前先 cd 到指定目录
cd_to_directory() {
    local dir="$1"
    echoYellow "cd 到工作目录 $dir"
    cd "$dir" || { echoRed "无法切换到目录 $dir"; exit 1; }
}

# 创建 Dockerfile
create_dockerfile() {
    echoGreen "创建 Dockerfile 文件"
    cat >"${project_name}dockerfile" <<EOF
# 开始封装nginx
FROM registry.cn-hongkong.aliyuncs.com/nft/nginx:stable-alpine-brotli
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY dist .
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
# 在 nginx.conf 文件中添加 try_files 配置项
ENTRYPOINT ["nginx", "-g", "daemon off;"]
EOF
}

# 创建部署文件
create_deployment_file() {
    echoGreen "创建部署文件"
    cat >"${project_name}.yaml" <<EOF
Name: browser-web-new
Services:
  - Image: registry.cn-hongkong.aliyuncs.com/nft/$project_name:$time_build
    CPU: 0.5
    Memory: 500
    Storage:
      Quantity: 500
    Ports:
      - Port: 80
        ExposePort: 80
EOF
}

# 拉取代码
pull_code() {
    echoGreen "开始拉去代码"
    cd_to_directory "$git_dir/new-browser-deployment"

    git checkout .
    # 拉取最新代码
    git fetch origin

    # 检查是否有未拉取的更改
    if [ "$(git diff HEAD origin/test1 --quiet)" ]; then
        echoGreen "代码已经是最新的，无需拉取"
    else
        # 有未拉取的更改，执行拉取操作
        echoGreen "有新的更改，正在拉取代码..."
        git checkout . && git pull && git checkout test1

        if [ $? -eq 0 ]; then
            echoGreen "拉取代码成功......."
        else
            echoRed "代码拉取失败...."
            exit 2
        fi
    fi

    # 检查分支是否切换成功
    git_branch=$(git branch | grep "*")
    echoGreen "当前分支为: $git_branch"
}

# 切换 Node.js 版本
switch_node_version() {
    echoGreen "切换 Node.js 版本"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # 加载 nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # 加载 nvm bash_completion

    nvm use 14.19.0
}

# 编译代码
build_code() {
    echoGreen '开始编译代码'
    echoGreen "代码编译目录：$(pwd)"
    /usr/local/node/bin/npm i
    /usr/local/node/bin/npm run build

    if [ $? -eq 0 ]; then
        echoGreen "代码编译成功，准备封装 Docker 镜像......."
        echoGreen "生成镜像"
        docker build . -t registry.cn-hongkong.aliyuncs.com/nft/$project_name:$time_build -f ${project_name}dockerfile
        echoGreen "推送镜像"
        docker push registry.cn-hongkong.aliyuncs.com/nft/$project_name:$time_build
    else
        echoRed "代码编译失败...."
        exit 2
    fi
}

# 主函数
main() {
    create_dockerfile
    create_deployment_file
    pull_code
    switch_node_version
    build_code
}

# 执行主函数
main

