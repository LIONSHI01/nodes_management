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
GIT_REPO="https://github.com/LIONSHI01/UNICH.git"
REPO_FILE="UNICH"
GIT_BRANCH="lion"
CONTAINER_NAME="unich_bot"

# 显示菜单
show_menu() {
    echo -e "${BLUE}================= Unich 管理菜单 =================${NC}"
    echo -e "${PACKAGE_ICON} 1. 安装"
    echo -e "${PACKAGE_ICON} 2. 查看日誌"
    echo -e "${CROSS_MARK} 8. 刪除機器人及文件"
    echo -e "${WRENCH_ICON} 0. 更新Script"
    echo -e "🚪 9. 退出"
    echo -e "${BLUE}====================================================${NC}"
    read -p "请选择一个选项 [0-5]: " choice
}


 


install_bot(){    

    git clone $GIT_REPO
    cd $REPO_FILE
    git checkout $GIT_BRANCH



    read -p "Token:" TOKEN
    if [ -f tokens.txt ]; then
        echo "tokens.txt already exists. Overwriting..."
        rm tokens.txt
    fi
    tee tokens.txt > /dev/null <<EOF
    $TOKEN
EOF

    start


}


 
start(){
    docker compose up -d
    docker compose logs -f
}

update_script(){
 wget -O unich_bot_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/refs/heads/main/unich-bot/unich_bot_helper.sh && chmod +x unich_bot_helper.sh && ./unich_bot_helper.sh
}



view_logs(){
    docker compose logs $CONTAINER_NAME -f
}

delete_bot(){
    cd $REPO_FILE
    docker compose down
    rm -r $REPO_FILE
}


# 主程序循环
while true; do
    show_menu
    case $choice in
        1) install_bot ;;
        2) view_logs;;
        8) delete_bot;;
        0) update_script;;
        9) echo -e "${GREEN}退出程序${NC}"; exit 0 ;;
        *) echo -e "${RED}无效选项，请重新输入${NC}";;
    esac
done