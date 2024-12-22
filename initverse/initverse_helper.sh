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

# 变量定义
NODE_DIR="initverse"
WALLET_ADDRESS_PATH="$NODE_DIR/wallet.txt" 
SCREEN_NAME="initverse"
 
 
# 显示菜单
show_menu() {
    echo -e "${BLUE}================= Initverse 管理菜单 =================${NC}"
    echo -e "${PACKAGE_ICON} 1. 安装 Initverse 节点"
    echo -e "${WRENCH_ICON} 2. 查看节点日志"
    echo -e "${WRENCH_ICON} 3. 查看节点狀態"
    echo -e "${WRENCH_ICON} 4. 刪除节点"
    echo -e "${KEY_ICON} 0. 更新Script"
    echo -e "🚪 5. 退出"
    echo -e "${BLUE}====================================================${NC}"
    read -p "请选择一个选项 [0-5]: " choice
}



# 安装 Initverse 节点
install_node() {
    # provide wallet address
    read -p "Please input EVM Wallet Address: " WALLET_ADDRESS
    mkdir initverse
    cd $NODE_DIR

    # Download official repo
    wget https://github.com/Project-InitVerse/ini-miner/releases/download/v1.0.0/iniminer-linux-x64
    chmod +x iniminer-linux-x64

    echo "$WALLET_ADDRESS" > "$WALLET_ADDRESS_PATH"

    screen -dmS $SCREEN_NAME
    ./iniminer-linux-x64 --pool stratum+tcp://$WALLET_ADDRESS.Worker001@pool-core-testnet.inichain.com:32672 --cpu-devices 1

}

restart_node(){
    cd $NODE_DIR
    WALLET_ADDRESS_RECORD=$(cat "$WALLET_ADDRESS_PATH")

    screen -dmS $SCREEN_NAME
    ./iniminer-linux-x64 --pool stratum+tcp://$WALLET_ADDRESS_RECORD.Worker001@pool-core-testnet.inichain.com:32672 --cpu-devices 1

}

# 查看节点日志
view_logs() {
    screen -r $SCREEN_NAME
}

# Check Node Status
check_node_status(){
    cd $NODE_DIR
    WALLET_ADDRESS_RECORD=$(cat "$WALLET_ADDRESS_PATH")

    echo "https://genesis-testnet.yatespool.com/mining/$WALLET_ADDRESS_RECORD/data"
}



# 卸载节点
uninstall_node() {
    rm -r $NODE_DIR
}
 

update_script(){
 wget -O initverse_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/refs/heads/main/initverse/initverse_helper.sh && chmod +x initverse_helper.sh && ./initverse_helper.sh
}

# 主程序循环
while true; do
    show_menu
    case $choice in
        1) install_node ;;
        2) view_logs ;;
        3) check_node_status ;;
        4) uninstall_node ;;
        5) echo -e "${GREEN}退出程序${NC}"; exit 0 ;;
        0) update_script;;
        *) echo -e "${RED}无效选项，请重新输入${NC}";;
    esac
done