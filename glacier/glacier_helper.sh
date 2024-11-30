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

# 导入私钥
import_private_key() {
    read -p "请输入你的私钥（64位十六进制）： " user_private_key
    if [[ ${#user_private_key} -ne 64 ]]; then
        echo -e "${RED}${CROSS_MARK} 无效的私钥！请确保私钥为64位的十六进制字符串。${NC}"
        exit 1
    fi
    mkdir -p "$NODE_DIR/geth-data/geth"
    echo "$user_private_key" > "$NODEKEY_PATH"
    echo -e "${GREEN}${CHECK_MARK} 私钥已成功导入！${NC}"
}



start_node(){
    read -p "请输入你的錢包私鑰(包括0x)：" PRIVATE_KEY
    docker run -d -e PRIVATE_KEY=$PRIVATE_KEY --name glacier-verifier docker.io/glaciernetwork/glacier-verifier:v0.0.2

}

 


# 卸载节点
uninstall_node() {
    docker stop glacier-verifier && docker rm glacier-verifier
}


restart_node(){
  docker restart glacier-verifier
}


view_logs(){
  docker logs glacier-verifier -f
}

update_script(){
 wget -O glacier_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/refs/heads/main/glacier/glacier_helper.sh && chmod +x glacier_helper.sh && ./glacier_helper.sh
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