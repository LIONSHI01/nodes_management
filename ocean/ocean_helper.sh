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
VPS_IP=$(hostname -I | awk '{print $1}')
DOCKER_COMPOSE_VERSION="2.20.2"
NODE_DIR="ocean"
DOCKER_COMPOSE_FILE="$NODE_DIR/docker-compose.yml"


# 检查节点是否安装
check_node_installed() {
    [ -d "$NODE_DIR" ] && [ -f "$DOCKER_COMPOSE_FILE" ]
}

# 检查 Docker 容器是否在运行
check_docker_running() {
    docker ps -a --format '{{.Names}}' | grep -q "ocean-node"
}

# 显示菜单
show_menu() {
    echo -e "${BLUE}================= Ocean 管理菜单 =================${NC}"
    echo -e "${PACKAGE_ICON} 1. 安装 Ocean 节点"
    echo -e "${WRENCH_ICON} 2. 查看节点日志"
    echo -e "${KEY_ICON} 3. 查看Dashboard"
    echo -e "${KEY_ICON} 4. 重啟節點"
    echo -e "${CROSS_MARK} 5. 刪除節點"
    echo -e "${KEY_ICON} 0. 更新Script"
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

# 安装 Ocean 节点
install_node() {
    echo -e "${PACKAGE_ICON} 更新系统..."
    sudo apt update -y && sudo apt upgrade -y
    echo -e "${PACKAGE_ICON} 安装 Git 和 curl..."
    sudo apt install -y git curl

    if ! command -v docker &> /dev/null; then
        echo -e "${PACKAGE_ICON} 安装 Docker..."
        sudo apt install -y docker.io
        sudo systemctl enable docker
        sudo systemctl start docker
    else
        echo -e "${GREEN}${CHECK_MARK} Docker 已安装。${NC}"
    fi

    if ! command -v docker-compose &> /dev/null; then
        echo -e "${PACKAGE_ICON} 安装 Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/v$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi

    if [ ! -d "$NODE_DIR" ]; then
        echo -e "${PACKAGE_ICON} 創建Ocean 文件夾..."
        mkdir ocean
    else
        echo -e "${GREEN}${CHECK_MARK} Ocean 文件夾已存在...${NC}"
    fi


    cd $NODE_DIR
    echo -e "${WRENCH_ICON} 启动 Ocean 节点..."
    echo "本機IP: ${VPS_IP}"

    curl -O https://raw.githubusercontent.com/oceanprotocol/ocean-node/main/scripts/ocean-node-quickstart.sh
    bash ocean-node-quickstart.sh
    docker-compose up -d
    echo -e "${GREEN}${CHECK_MARK} 节点安装完成！${NC}"
}

# 查看节点日志
view_logs() {
    if check_node_installed && check_docker_running; then
        echo -e "${WRENCH_ICON} 显示节点日志..."
        cd $NODE_DIR
        docker-compose logs -f
    else
        echo -e "${RED}${CROSS_MARK} 节点未安装或未运行！${NC}"
    fi
}

# 卸载 Unichain 节点
uninstall_node() {
    if check_node_installed; then
        echo -e "${CROSS_MARK} 停止并删除 Ocean 节点容器..."
        cd $NODE_DIR
        if check_docker_running; then
            docker-compose down
            echo -e "${GREEN}${CHECK_MARK} Docker 容器已停止。${NC}"
        else
            echo -e "${YELLOW}未找到正在运行的 Docker 容器。${NC}"
        fi
        cd ..
        rm -rf "$NODE_DIR"
        echo -e "${GREEN}${CHECK_MARK} 卸载完成（依赖未删除）！${NC}"
    else
        echo -e "${RED}${CROSS_MARK} 节点未安装！${NC}"
    fi
}


show_dashboard(){
    echo "http://${VPS_IP}:8083/dashboard/"
}

update_script(){
 wget -O ocean_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/refs/heads/main/ocean/ocean_helper.sh && chmod +x ocean_helper.sh && ./ocean_helper.sh
}


restart_node(){
    cd ocean/
    docker-compose restart
}

# 主程序循环
while true; do
    show_menu
    case $choice in
        1) install_node ;;
        2) view_logs ;;
        3) show_dashboard ;;
        4) restart_node ;;
        5) uninstall_node ;;
        5) echo -e "${GREEN}退出程序${NC}"; exit 0 ;;
        0) update_script;;
        *) echo -e "${RED}无效选项，请重新输入${NC}";;
    esac
done