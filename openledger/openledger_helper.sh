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
NODE_DIR="/root/openledger-bot"
REPO_ADDRESS="https://github.com/LIONSHI01/openledger-bot.git"
CONTAINER_NAME="openledger-bot"
 
 
# 显示菜单
show_menu() {
    echo -e "${BLUE}================= Initverse 管理菜单 =================${NC}"
    echo -e "${PACKAGE_ICON} 1. 安装機器人"
    echo -e "${WRENCH_ICON} 2. 查看機器人日志"
    echo -e "${WRENCH_ICON} 3. 重啟機器人"
    echo -e "${WRENCH_ICON} 9. 刪除機器人"
    echo -e "${KEY_ICON} 0. 更新Script"
    echo -e "🚪 6. 退出"
    echo -e "${BLUE}====================================================${NC}"
    read -p "请选择一个选项 [0-9]: " choice
}



# 安装 Bot
install_node() {
    # provide wallet address
    read -p "Please input EVM Wallet Address: " WALLET_ADDRESS
    git clone $REPO_ADDRESS
    cd $NODE_DIR
    git checkout lion
    
    echo "$WALLET_ADDRESS" > "account.txt"

    docker-compose up -d
}

restart_node(){
    cd $NODE_DIR
    docker-compose restart
}

 
# 查看節點日志
view_logs() {
    cd $NODE_DIR
    docker-compose logs -f
}
 

 


# 卸载節點
uninstall_node() {
    cd $NODE_DIR
    docker-compose down
    docker rm $CONTAINER_NAME
}
 

update_script(){
 wget -O openledger_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/refs/heads/main/openledger/openledger_helper.sh && chmod +x openledger_helper.sh && ./openledger_helper.sh
}


# 主程序循环
while true; do
    show_menu
    case $choice in
        1) install_node ;;
        2) view_logs ;;
        3) restart_node ;;
        9) uninstall_node ;;
        7) echo -e "${GREEN}退出程序${NC}"; exit 0 ;;
        0) update_script;;
        *) echo -e "${RED}无效选项，请重新输入${NC}";;
    esac
done