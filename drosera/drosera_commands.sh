#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 图标定义
CHECK_MARK="✅"
CROSS_MARK="❌"
PACKAGE_ICON="📦"
WRENCH_ICON="🔧"
KEY_ICON="🔑"
REPO_FILE="Drosera-Network/"

# 显示菜单
show_menu() {
    echo -e "${BLUE}================= Unich 管理菜单 =================${NC}"
    echo -e "${PACKAGE_ICON} 1. 安装"
    echo -e "${PACKAGE_ICON} 2. Setup Trap"
    echo -e "${PACKAGE_ICON} 3. 查看日誌"
    echo -e "${CROSS_MARK} 8. 刪除機器人及文件"
    echo -e "${WRENCH_ICON} 0. 更新Script"
    echo -e "🚪 9. 退出"
    echo -e "${BLUE}====================================================${NC}"
    read -p "请选择一个选项 [0-5]: " choice
}


 
install_dependencies(){
  sudo apt-get update && sudo apt-get upgrade -y
  sudo apt install curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev  -y



# Setup Drosera CLI
curl -L https://app.drosera.io/install | bash
source /root/.bashrc
droseraup

# Setup Foundry CLI
curl -L https://foundry.paradigm.xyz | bash
source /root/.bashrc
foundryup

# Setup Bun
curl -fsSL https://bun.sh/install | bash
source /root/.bashrc

}



install_bot(){    
read -p "请输入錢包地址: " WALLET_ADDRESS
read -p "请输入私鑰: " PRIVATE_KEY
read -p "请输入Github_Email: " Github_Email
read -p "请输入Github_Username: " Github_Username



install_dependencies


# Deploy Contract & Trap
if [ -d "my-drosera-trap" ]; then
  cd my-drosera-trap
else
  mkdir my-drosera-trap
  cd my-drosera-trap
fi



# Set up github config
git config --global user.email "$Github_Email"
git config --global user.name "$Github_Username"


# Initialize Trap
forge init -t drosera-network/trap-foundry-template

# Compile Trap
curl -fsSL https://bun.sh/install | bash
bun install
forge build


# Set your drosera private key
DROSERA_PRIVATE_KEY=$PRIVATE_KEY drosera apply

}



setup_trap(){
  echo "請確保你已經stake ETH"

  read -p "请输入VPS_IP: " VPS_IP
  read -p "请输入錢包地址: " WALLET_ADDRESS
  read -p "请输入私鑰: " PRIVATE_KEY
  read -p "请输入RPC: " ALCHEMY_RPC



  cd ~
  drosera dryrun
  cd my-drosera-trap

  # Edit drosera.toml
  echo "private_trap=true" >> drosera.toml
  sed -i "s/whitelist = .*/whitelist = [\"$WALLET_ADDRESS\"]/" drosera.toml

#   Update Trap Configuration
    DROSERA_PRIVATE_KEY=$PRIVATE_KEY drosera apply


    cd ~


# Download Operator CLI

curl -LO https://github.com/drosera-network/releases/releases/download/v1.16.2/drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
tar -xvf drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz

# Test the CLI with ./drosera-operator --version
./drosera-operator --version
sudo cp drosera-operator /usr/bin
drosera-operator


# Install image
docker pull ghcr.io/drosera-network/drosera-operator:latest

# Register Operator
drosera-operator register --eth-rpc-url $ALCHEMY_RPC --eth-private-key $PRIVATE_KEY


# Clone github repo
cd ~
git clone https://github.com/0xmoei/Drosera-Network
cd Drosera-Network
cp .env.example .env

sed -i "s/ETH_PRIVATE_KEY=.*/ETH_PRIVATE_KEY=$PRIVATE_KEY/" .env
sed -i "s/VPS_IP=.*/VPS_IP=$VPS_IP/" .env

# Start container
docker-compose up -d
docker-compose logs -f


}

 

update_script(){
 wget -O drosera_commands.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/refs/heads/main/drosera/drosera_commands.sh && chmod +x drosera_commands.sh && ./drosera_commands.sh
}


 
delete_node(){
    cd $REPO_FILE
    docker-compose down
    rm -r $REPO_FILE
}


view_logs(){
    cd $REPO_FILE
    docker-compose logs -f
}

# 主程序循环
while true; do
    show_menu
    case $choice in
        1) install_bot ;;
        2) setup_trap ;;
        3) view_logs ;;
        8) delete_node;;
        0) update_script;;
        9) echo -e "${GREEN}退出程序${NC}"; exit 0 ;;
        *) echo -e "${RED}无效选项，请重新输入${NC}";;
    esac
done