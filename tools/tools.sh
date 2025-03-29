#!/bin/bash

function install_docker(){
# 检查 Docker 是否已安装
echo "检查 Docker 是否已安装..."
if command -v docker &> /dev/null; then
  echo " - Docker 已安装，跳过此步骤。"
else
  echo " - Docker 未安装，正在进行安装..."
  
  # 更新 apt 包索引
  sudo apt update
  
  # 安装必要的包，确保 apt 通过 HTTPS 使用仓库
  sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
  
  # 导入 Docker 官方的 GPG 密钥
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  
  # 添加 Docker 官方仓库
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  
  # 更新 apt 包索引（加入 Docker 仓库后）
  sudo apt update
  
  # 安装 Docker CE (Community Edition)
  sudo apt install -y docker-ce docker-ce-cli containerd.io
  
  # 启动并启用 Docker 服务
  sudo systemctl enable docker
  sudo systemctl start docker
  
  # 确认 Docker 版本
  echo "Docker 安装完成，当前版本："
  docker --version
fi
}

function install_docker_compose(){
# 检查 Docker Compose 安装情况
echo "检查 Docker Compose 是否已安装..."
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
  echo " - Docker Compose 未安装，正在进行安装..."
  sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-$(uname -s)-$(uname -m)" \
       -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
else
  echo " - Docker Compose 已安装，跳过此步骤。"
fi

echo "[确认] Docker Compose 版本:"
docker compose version || docker-compose version
}

function install_nodejs_and_npm() {
    if command -v node > /dev/null 2>&1; then
        echo "Node.js 已安装"
    else
        echo "Node.js 未安装，正在安装..."
        curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi

    if command -v npm > /dev/null 2>&1; then
        echo "npm 已安装"
    else
        echo "npm 未安装，正在安装..."
        sudo apt-get install -y npm
    fi
}

# 检查并安装 PM2
function install_pm2() {
    if command -v pm2 > /dev/null 2>&1; then
        echo "PM2 已安装"
    else
        echo "PM2 未安装，正在安装..."
        npm install pm2@latest -g
    fi
}

function install_go(){
  rm -rf $HOME/go
sudo rm -rf /usr/local/go
cd $HOME
curl https://dl.google.com/go/go1.21.8.linux-amd64.tar.gz | sudo tar -C/usr/local -zxvf -
cat <<'EOF' >>$HOME/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source $HOME/.profile
go version

}

function vps_starter(){
  apt-get update && apt-get upgrade
  apt install screen
  apt install ncdu
  apt install vim
  apt install snap
  snap install btop
  install_docker
  install_docker_compose
  install_go
  install_nodejs_and_npm
  install_pm2
}

 


function main_menu() {
  while true; do
      clear
      echo "Please choose the command to execute:"
      echo "1. Install Basic Dependencies"
      read -p "Please input (1-2): " OPTION

      case $OPTION in
          1) vps_starter ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu