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
GIT_REPO="https://github.com/LIONSHI01/t3rn-bot-lion.git"
REPO_FILE="t3rn-bot-lion"
GIT_BRANCH="single"
SCREEN_SESSION_NAME="t3rn-bot"
START_BOT_COMMAND="python3 -m venv venv \
                    source venv/bin/activate \
                    pip install -r requirements.txt \
                    python bot.py"
NODE_BINARY="start.sh"
NODE_START_BINARY="install.sh"

# 显示菜单
show_menu() {
    echo -e "${BLUE}================= Glacier 管理菜单 =================${NC}"
    echo -e "${PACKAGE_ICON} 1. 安装節點"
    echo -e "${PACKAGE_ICON} 2. 查看日誌"
    echo -e "${PACKAGE_ICON} 3. 更新ENV"
    echo -e "${WRENCH_ICON} 0. 更新Script"
    echo -e "🚪 9. 退出"
    echo -e "${BLUE}====================================================${NC}"
    read -p "请选择一个选项 [0-5]: " choice
}


download_repo(){
    git clone $GIT_REPO
    cd $REPO_FILE
    git checkout $GIT_BRANCH
}


install_dependencies(){
    sudo apt update
    sudo apt upgrade -y



    # 检查是否安装了 git
    if ! command -v git &> /dev/null; then
        echo "Git 未安装，请先安装 Git。"
        exit 1
    fi

    # 检查是否安装了 python3-pip 和 python3-venv
    if ! command -v pip3 &> /dev/null; then
        echo "pip 未安装，正在安装 python3-pip..."
        sudo apt update
        sudo apt install -y python3-pip
    fi

    if ! command -v python3 -m venv &> /dev/null; then
        echo "python3-venv 未安装，正在安装 python3-venv..."
        sudo apt update
        sudo apt install -y python3-venv
    fi
}

start_node(){
# Download repo
    download_repo



    read -p "请输入你的錢包私鑰(包括0x)：" PRIVATE_KEY
    read -p "Eth Amount To Bridge：" BRIDGE_AMOUNT
    read -p "Data for OP to Base：" DATA_BRIDGE_OP_TO_BASE
    read -p "Data for Base to OP：" DATA_BRIDGE_BASE_TO_OP
    read -p "Base Sepolia RPC[選用默認按enter]：" BASE_SEPOLIA_RPC
    BASE_SEPOLIA_RPC="${BASE_SEPOLIA_RPC:-https://base-sepolia.g.alchemy.com/v2/-VC9eV1WUDDNqcGzeKGKZ5d8E1YFb4Tt}"
    read -p "OP Sepolia RPC[選用默認按enter]：" OP_SEPOLIA_RPC
    OP_SEPOLIA_RPC="${OP_SEPOLIA_RPC:-https://opt-sepolia.g.alchemy.com/v2/-VC9eV1WUDDNqcGzeKGKZ5d8E1YFb4Tt}"

    tee .env > /dev/null <<EOF
    PRIVATE_KEY=$PRIVATE_KEY
    BRIDGE_AMOUNT=$BRIDGE_AMOUNT
    DATA_BRIDGE_BASE_TO_OP=$DATA_BRIDGE_BASE_TO_OP
    DATA_BRIDGE_OP_TO_BASE=$DATA_BRIDGE_OP_TO_BASE
    BASE_SEPOLIA_RPC=$BASE_SEPOLIA_RPC
    OP_SEPOLIA_RPC=$OP_SEPOLIA_RPC
EOF

    chmod 744 $NODE_START_BINARY
    screen -dmS "$SCREEN_SESSION_NAME" bash -c "./$NODE_START_BINARY"
}

 


update_script(){
 wget -O t3rn_bridge_start.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/refs/heads/main/t3rn/t3rn_bridge_start.sh && chmod +x t3rn_bridge_start.sh && ./t3rn_bridge_start.sh
}


update_env(){
     read -p "Number of ETH to Bridge:" BRIDGE_AMOUNT
     read -p "Data from OP to Base:" DATA_BRIDGE_OP_TO_BASE
     read -p "Data from Base to OP:" DATA_BRIDGE_BASE_TO_OP

     sed -i "s/BRIDGE_AMOUNT=.*/BRIDGE_AMOUNT=$BRIDGE_AMOUNT/" .env
     sed -i "s/DATA_BRIDGE_BASE_TO_OP=.*/DATA_BRIDGE_BASE_TO_OP=$DATA_BRIDGE_BASE_TO_OP/" .env
     sed -i "s/DATA_BRIDGE_OP_TO_BASE=.*/DATA_BRIDGE_OP_TO_BASE=$DATA_BRIDGE_OP_TO_BASE/" .env

}


view_logs(){
    screen -r "$SCREEN_SESSION_NAME"
}


# 主程序循环
while true; do
    show_menu
    case $choice in
        1) start_node ;;
        2) view_logs;;
        3) update_env;;
        0) update_script;;
        9) echo -e "${GREEN}退出程序${NC}"; exit 0 ;;
        *) echo -e "${RED}无效选项，请重新输入${NC}";;
    esac
done