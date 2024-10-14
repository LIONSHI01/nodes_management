#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 检查并安装Docker
function check_and_install_docker() {
    if ! command -v docker &> /dev/null; then
        echo "未检测到 Docker，正在安装..."
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce
        echo "Docker 已安装。"
    else
        echo "Docker 已安装。"
    fi
}

# 检查并安装Git
function check_and_install_git() {
    if ! command -v git &> /dev/null; then
        echo "未检测到 Git，正在安装..."
        sudo apt-get update
        sudo apt-get install -y git
        echo "Git 已安装。"
    else
        echo "Git 已安装。"
    fi
}

# 安装Kroma Validator节点
function install_kroma_validator() {
    check_and_install_docker
    check_and_install_git

    # 克隆kroma-up仓库
    git clone https://github.com/kroma-network/kroma-up.git
    cd kroma-up

    # 运行startup脚本
    ./startup.sh mainnet

    # 读取并修改.env文件
    if [ -f .env ]; then
        # 用户输入L1 RPC端点
        read -p "请输入L1 Beacon RPC端点 (https://...): " l1_beacon_endpoint
        read -p "请输入L1 RPC端点 (https://...): " l1_rpc_endpoint
        read -p "请输入L1 Validator RPC端点 (wss://...): " l1_validator_rpc_endpoint
        sed -i "s|KROMA_NODE__L1_BEACON_ENDPOINT=|KROMA_NODE__L1_BEACON_ENDPOINT=$l1_beacon_endpoint|" .env
        sed -i "s|KROMA_NODE__L1_RPC_ENDPOINT=|KROMA_NODE__L1_RPC_ENDPOINT=$l1_rpc_endpoint|" .env
        sed -i "s|KROMA_VALIDATOR__L1_RPC_ENDPOINT=|KROMA_VALIDATOR__L1_RPC_ENDPOINT=$l1_validator_rpc_endpoint|" .env

        # 用户选择使用助记词或私钥
        read -p "您想使用助记词(1)还是私钥(2)? 请输入1或2: " key_choice
        if [ "$key_choice" = "1" ]; then
            read -p "请输入您的助记词: " mnemonic
            read -p "请输入HD路径 (默认为 m/44'/60'/0'/0/0): " hd_path
            hd_path=${hd_path:-"m/44'/60'/0'/0/0"}
            sed -i "s|KROMA_VALIDATOR__MNEMONIC=|KROMA_VALIDATOR__MNEMONIC=$mnemonic|" .env
            sed -i "s|KROMA_VALIDATOR__HD_PATH=|KROMA_VALIDATOR__HD_PATH=$hd_path|" .env
        else
            read -p "请输入您的私钥 (不需要0x前缀): " private_key
            sed -i "s|KROMA_VALIDATOR__PRIVATE_KEY=|KROMA_VALIDATOR__PRIVATE_KEY=$private_key|" .env
        fi

        # 配置验证者角色
        read -p "是否允许公共轮次(需要先运行prover，如果没运行，请选n)? (y/n): " allow_public_round
        if [ "$allow_public_round" = "y" ]; then
            sed -i "s|KROMA_VALIDATOR__ALLOW_PUBLIC_ROUND=false|KROMA_VALIDATOR__ALLOW_PUBLIC_ROUND=true|" .env
        fi

        echo ".env 文件已更新。"
    else
        echo "错误：.env 文件不存在。请检查 startup.sh 脚本是否正确执行。"
        exit 1
    fi

    # 启动验证者节点
    docker compose -f docker-compose-mainnet.yml --profile validator up -d

    echo "Kroma Validator 节点已启动。"
}

# 查看Docker日志功能
function check_docker_logs() {
    cd ~/kroma-up
    docker compose -f docker-compose-mainnet.yml logs -f
}

# 删除Docker容器功能
function delete_docker_container() {
    echo "删除Kroma Docker容器..."
    docker compose -f docker-compose-mainnet.yml --profile validator down -v
    if [ $? -ne 0 ]; then
        echo "尝试强制删除网络..."
        docker network rm -f kroma-up_default
    fi
    echo "Kroma Docker容器已删除。"
}

# 主菜单
function main_menu() {
    clear
    echo "脚本以及教程由推特用户大赌哥 @y95277777 编写，免费开源，请勿相信收费"
    echo "=====================Kroma Mainnet Validator 安装========================="
    echo "节点社区 Telegram 群组:https://t.me/niuwuriji"
    echo "节点社区 Telegram 频道:https://t.me/niuwuriji"
    echo "节点社区 Discord 社群:https://discord.gg/GbMV5EcNWF"
    echo "请选择要执行的操作:"
    echo "1. 安装Kroma 验证者 节点"
    echo "2. 查看Kroma 验证者 日志"
    echo "3. 删除Kroma 验证者 Docker 节点"
    read -p "请输入选项（1-3）: " OPTION

    case $OPTION in
    1) install_kroma_validator ;;
    2) check_docker_logs ;;
    3) delete_docker_container ;;
    *) echo "无效选项。" ;;
    esac
    
}

# 显示主菜单
main_menu