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
    echo -e "${BLUE}================= Cytic 管理菜单 =================${NC}"
    echo -e "${PACKAGE_ICON} 1. 安装 Cytic 节点"
    echo -e "${KEY_ICON} 2. 导出私钥"
    echo -e "${PACKAGE_ICON} 3. 刪除節點"
    echo -e "${WRENCH_ICON} 0. 更新Script"
    echo -e "🚪 5. 退出"
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

# 安装 Unichain 节点
install_node() {
  read -p "请输入你的錢包地址：" WALLET_ADDRESS
  curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/setup_linux.sh > ~/setup_linux.sh && bash ~/setup_linux.sh $WALLET_ADDRESS

  start_node
}

start_node(){
    screen -dmS cytic
    cd ~/cysic-verifier/ && bash start.sh
}

update_node_script(){
    cd ~/spheron/
    sed -i "s|FIZZUP_VERSION=.*|FIZZUP_VERSION=\"v1.1.4\"|" fizzup-v1.1.0.sh
    bash fizzup-v1.1.0.sh
}


# 卸载 Unichain 节点
uninstall_node() {
   rm -r cysic-verifier/
}

# 导出私钥
export_private_key() {
  cd ~/.cysic/keys
}

update_script(){
 wget -O cysic_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/refs/heads/main/cysic/cysic_helper.sh && chmod +x cysic_helper.sh && ./cysic_helper.sh
}

# 主程序循环
while true; do
    show_menu
    case $choice in
        1) install_node ;;
        2) export_private_key ;;
        3) uninstall_node ;;
        4) echo -e "${GREEN}退出程序${NC}"; exit 0 ;;
        0) update_script;;
        *) echo -e "${RED}无效选项，请重新输入${NC}";;
    esac
done