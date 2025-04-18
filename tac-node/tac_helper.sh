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
REPO_FILE="tacchain"
SCREEN_SESSION_NAME="tac-node"

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
read -p "请输入节点名称: " NODE_NAME
echo "节点名称已记录: $NODE_NAME"

git clone https://github.com/TacBuild/tacchain
cd tacchain
make install
tacchaind init testnode --chain-id tacchain_2390-1 --home .testnet


sed -i "s/moniker = .*/moniker = \"$NODE_NAME\"/" .testnet/config/config.toml
sed -i "/\[p2p\]/a timeout_commit = \"3s\"" .testnet/config/config.toml
sed -i "/\[p2p\]/a persistent_peers = \"9b4995a048f930776ee5b799f201e9b00727ffcc@107.6.94.246:45120,e3c2479a6f418841bd64bae6dff027ea3efc1987@72.251.230.233:45120,fbf04b3d67705ed48831aa80ebe733775e672d1a@107.6.94.246:45110,5a6f0e342ea66cb769194c81141ffbff7417fbcd@72.251.230.233:45110\"" .testnet/config/config.toml


# Download Genesis File
curl https://newyork-inap-72-251-230-233.ankr.com/tac_tacd_testnet_full_tendermint_rpc_1/genesis | jq '.result.genesis' > .testnet/config/genesis.json

screen -dmS "$SCREEN_SESSION_NAME"

}


 

update_script(){
 wget -O tac_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/refs/heads/main/tac-node/tac_helper.sh && chmod +x tac_helper.sh && ./tac_helper.sh
}



 
delete_node(){
    cd $REPO_FILE
    rm -r $REPO_FILE
}


# 主程序循环
while true; do
    show_menu
    case $choice in
        1) install_bot ;;
        8) delete_node;;
        0) update_script;;
        9) echo -e "${GREEN}退出程序${NC}"; exit 0 ;;
        *) echo -e "${RED}无效选项，请重新输入${NC}";;
    esac
done