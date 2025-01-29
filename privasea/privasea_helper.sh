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





install_node(){

    docker pull privasea/acceleration-node-beta:latest
    mkdir -p ~/privasea/config && cd ~/privasea
    docker run --rm -it -v "$HOME/privasea/config:/app/config" privasea/acceleration-node-beta:latest ./node-calc new_keystore
    mv $HOME/privasea/config/UTC--* $HOME/privasea/config/wallet_keystore

    
}

start_node(){
  read -p "请輸入Keystore 密码：" ENTER_YOUR_KEYSTORE_PASSWORD
  KEYSTORE_PASSWORD=ENTER_YOUR_KEYSTORE_PASSWORD && docker run -d --name privanetix-node -v "$HOME/privasea/config:/app/config" -e KEYSTORE_PASSWORD=$KEYSTORE_PASSWORD privasea/acceleration-node-beta:latest
}

 


# 卸载节点
uninstall_node() {
    docker stop privanetix-node && docker rm privanetix-node
}


restart_node(){
  docker restart privanetix-node
}


view_logs(){
  docker logs privanetix-node -f
}

update_script(){
 wget -O privasea_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/refs/heads/main/privasea/privasea_helper.sh && chmod +x privasea_helper.sh && ./privasea_helper.sh
}





# 主程序循环
while true; do
    show_menu
    case $choice in
        1) install_node ;;
        2) view_logs ;;
        3) restart_node ;;
        7) uninstall_node ;;
        0) update_script;;
        9) echo -e "${GREEN}退出程序${NC}"; exit 0 ;;
        *) echo -e "${RED}无效选项，请重新输入${NC}";;
    esac
done