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
DROSERA_TRAP_FILE="my-drosera-trap"

# 显示菜单
show_menu() {
    echo -e "${BLUE}================= Unich 管理菜单 =================${NC}"
    echo -e "${PACKAGE_ICON} 1. 安装環境"
    echo -e "${PACKAGE_ICON} 2. 檢查安裝環境"
    echo -e "${PACKAGE_ICON} 3. 安裝節點"
    echo -e "${PACKAGE_ICON} 4. Setup Trap"
    echo -e "${PACKAGE_ICON} 5. 查看日誌"
    echo -e "${PACKAGE_ICON} 6. 更新節點"
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
source ~/.bashrc
droseraup

# Setup Foundry CLI
curl -L https://foundry.paradigm.xyz | bash
source /root/.bashrc
source ~/.bashrc
foundryup

# Setup Bun
curl -fsSL https://bun.sh/install | bash
source /root/.bashrc

source /root/.bashrc
source ~/.bashrc
droseraup
foundryup

if command -v drosera &> /dev/null
then
    echo "Drosera is installed"
else
    echo "Drosera is not installed"
fi


if command -v forge &> /dev/null
then
    echo "Forge is installed"
else
    echo "Forge is not installed"
fi



}

check_dependencies(){
    source /root/.bashrc
source ~/.bashrc
droseraup
foundryup
}



install_node(){    
read -p "请输入Github_Email: " Github_Email
read -p "请输入Github_Username: " Github_Username
read -p "请输入錢包地址: " WALLET_ADDRESS
read -p "请输入私鑰: " PRIVATE_KEY



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
  read -p "请输入RPC: " ALCHEMY_RPC
  read -p "请输入VPS_IP: " VPS_IP
  read -p "请输入錢包地址: " WALLET_ADDRESS
  read -p "请输入私鑰: " PRIVATE_KEY



  cd ~
  cd my-drosera-trap

  # Edit drosera.toml
  echo "private_trap = true" >> drosera.toml
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
    cd ~
    rm -r $REPO_FILE
    rm -r $DROSERA_TRAP_FILE

}


view_logs(){
    cd $REPO_FILE
    docker-compose logs -f
}


# 命令4：升级到1.17并修改drosera_rpc
function upgrade_to_1_17() {
    # 安装 Drosera
    echo "正在安装 Drosera..."
    curl -L https://app.drosera.io/install | bash || { echo "Drosera 安装失败"; exit 1; }
    source /root/.bashrc
    source ~/.bashrc
    export PATH=$PATH:/root/.drosera/bin
    echo 'export PATH=$PATH:/root/.drosera/bin' >> /root/.bashrc
    if command -v droseraup &> /dev/null; then
        droseraup || { echo "droseraup 执行失败"; exit 1; }
        echo "Drosera 安装完成"
    else
        echo "droseraup 命令未找到，Drosera 安装失败"
        exit 1
    fi

    # 检查 Drosera 二进制文件并验证版本
    DROsera_BIN="/root/.drosera/bin/drosera"
    if [ -f "$DROsera_BIN" ]; then
        echo "找到 Drosera，正在验证版本..."
        $DROsera_BIN --version || { echo "Drosera 版本检查失败"; exit 1; }
        echo "Drosera 版本检查成功"
    else
        echo "Drosera 未找到（$DROsera_BIN 不存在）"
        exit 1
    fi

    # 切换到 my-drosera-trap 目录
    echo "切换到 /root/my-drosera-trap 目录..."
    cd /root/my-drosera-trap || { echo "错误：无法切换到 /root/my-drosera-trap 目录，请确保目录存在"; exit 1; }

    # 检查 drosera.toml 文件
    DROsera_TOML="/root/my-drosera-trap/drosera.toml"
    if [ ! -f "$DROsera_TOML" ]; then
        echo "错误：未找到 drosera.toml 文件 ($DROsera_TOML)。请确保 Drosera 安装正确并生成了配置文件。"
        exit 1
    fi

    # 修改 drosera.toml 中的 drosera_rpc
    DROsera_RPC="https://relay.testnet.drosera.io"  # 使用指定的 RPC 端点
    echo "正在更新 drosera.toml 中的 drosera_rpc 配置..."
    if grep -q "^drosera_rpc = " "$DROsera_TOML"; then
        # 如果 drosera_rpc 存在，替换其值
        sed -i "s|^drosera_rpc = .*|drosera_rpc = \"$DROsera_RPC\"|" "$DROsera_TOML"
        echo "已更新 drosera_rpc 为 $DROsera_RPC"
    else
        # 如果 drosera_rpc 不存在，追加到文件末尾
        echo "drosera_rpc = \"$DROsera_RPC\"" >> "$DROsera_TOML"
        echo "已添加 drosera_rpc = $DROsera_RPC 到 drosera.toml"
    fi

    # 验证 drosera.toml 是否正确更新
    if grep -q "drosera_rpc = \"$DROsera_RPC\"" "$DROsera_TOML"; then
        echo "drosera.toml 配置验证通过"
    else
        echo "错误：drosera.toml 中的 drosera_rpc 配置更新失败"
        exit 1
    fi

    # 提示用户输入EVM钱包私钥
    echo "请确保你的钱包地址在 Holesky 测试网上有足够的 ETH 用于交易。"
    while true; do
        echo "请输入 EVM 钱包私钥（隐藏输入）："
        read -s DROSERA_PRIVATE_KEY
        if [ -z "$DROSERA_PRIVATE_KEY" ]; then
            echo "错误：私钥不能为空，请重新输入"
        else
            break
        fi
    done

    # 执行 drosera apply
    echo "正在执行 drosera apply..."
    echo "等待 20 秒以确保准备就绪..."
    sleep 20
    export DROSERA_PRIVATE_KEY="$DROSERA_PRIVATE_KEY"
    if echo "ofc" | drosera apply; then
        echo "drosera apply 完成"
    else
        echo "drosera apply 失败，请手动运行 'cd /root/my-drosera-trap && export DROSERA_PRIVATE_KEY=your_private_key && echo \"ofc\" | drosera apply' 并检查错误日志。"
        unset DROSERA_PRIVATE_KEY
        exit 1
    fi

    # 清理私钥变量
    unset DROSERA_PRIVATE_KEY
    echo "私钥变量已清理"

    echo "升级到1.17及drosera apply执行完成"
    echo "按任意键返回主菜单..."
    read -r
}

# 主程序循环
while true; do
    show_menu
    case $choice in
        1) install_dependencies ;;
        2) check_dependencies ;;
        3) install_node ;;
        4) setup_trap ;;
        5) view_logs ;;
        6) upgrade_to_1_17 ;;
        8) delete_node;;
        0) update_script;;
        9) echo -e "${GREEN}退出程序${NC}"; exit 0 ;;
        *) echo -e "${RED}无效选项，请重新输入${NC}";;
    esac
done