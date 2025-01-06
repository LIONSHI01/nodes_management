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



 
 
# 显示菜单
show_menu() {
    echo -e "${BLUE}================= Glacier 管理菜单 =================${NC}"
    echo -e "${PACKAGE_ICON} 1. 安装節點"
    echo -e "${PACKAGE_ICON} 2. 查看日誌"
    echo -e "${PACKAGE_ICON} 3. 重啟節點"
    echo -e "${WRENCH_ICON} 7. 刪除節點"
    echo -e "${WRENCH_ICON} 0. 更新Script"
    echo -e "🚪 9. 退出"
    echo -e "${BLUE}====================================================${NC}"
    read -p "请选择一个选项 [0-5]: " choice
}





start_node(){
    mkdir plaza_bot
    cd plaza_bot
    git clone https://github.com/LIONSHI01/plaza.git .
    git checkout lion
    

    read -p "请输入你的錢包地址：" ADDRESS
    read -p "请输入你的錢包私鑰(包括0x)：" PRIVATE_KEY

    tee .env > /dev/null <<EOF
    address=$ADDRESS
    private_key=$PRIVATE_KEY
EOF

    docker-compose up -d
    
}

 


# 卸载节点
uninstall_node() {
    docker stop plaza_bot && docker rm plaza_bot
}


restart_node(){
  docker restart plaza_bot
}


view_logs(){
  docker logs plaza_bot -f
}

update_script(){
 wget -O plaza_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/refs/heads/main/plaza/plaza_helper.sh && chmod +x plaza_helper.sh && ./plaza_helper.sh
}





# 主程序循环
while true; do
    show_menu
    case $choice in
        1) start_node ;;
        2) view_logs ;;
        3) restart_node ;;
        7) uninstall_node ;;
        0) update_script;;
        9) echo -e "${GREEN}退出程序${NC}"; exit 0 ;;
        *) echo -e "${RED}无效选项，请重新输入${NC}";;
    esac
done