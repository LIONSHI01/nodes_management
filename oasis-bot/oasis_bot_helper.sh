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
GIT_REPO="https://github.com/LIONSHI01/oasis-bot.git"
REPO_FILE="oasis-bot"
GIT_BRANCH="lion"
CONTAINER_NAME="oasis_bot"
START_BOT_COMMAND="python3 -m venv venv \
                    source venv/bin/activate \
                    pip install -r requirements.txt \
                    python bot.py"
NODE_BINARY="start.sh"

# 显示菜单
show_menu() {
    echo -e "${BLUE}================= Oasis 管理菜单 =================${NC}"
    echo -e "${PACKAGE_ICON} 1. 安装"
    echo -e "${PACKAGE_ICON} 2. 設定Providers"
    echo -e "${PACKAGE_ICON} 3. 啟動機器人"
    echo -e "${PACKAGE_ICON} 4. 查看日誌"
    echo -e "${WRENCH_ICON} 0. 更新Script"
    echo -e "🚪 9. 退出"
    echo -e "${BLUE}====================================================${NC}"
    read -p "请选择一个选项 [0-5]: " choice
}


 


install_bot(){    

    git clone $GIT_REPO
    cd $REPO_FILE
    git checkout $GIT_BRANCH


    read -p "Email:" EMAIL
    read -p "Password:" PASSWORD

    
    tee accounts.txt > /dev/null <<EOF
    $EMAIL|$PASSWORD
EOF

    yarn

}


setup(){
    yarn setup    
}
 
start(){
    docker compose up -d
    docker compose logs -f
}

update_script(){
 wget -O oasis_bot_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/refs/heads/main/oasis-bot/oasis_bot_helper.sh && chmod +x oasis_bot_helper.sh && ./oasis_bot_helper.sh
}



view_logs(){
    docker compose logs $CONTAINER_NAME -f
}


# 主程序循环
while true; do
    show_menu
    case $choice in
        1) install_bot ;;
        2) setup ;;
        3) start ;;
        4) view_logs;;
        0) update_script;;
        9) echo -e "${GREEN}退出程序${NC}"; exit 0 ;;
        *) echo -e "${RED}无效选项，请重新输入${NC}";;
    esac
done