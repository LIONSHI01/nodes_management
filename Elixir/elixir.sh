#!/bin/bash

# 检查脚本是否以root权限运行
if [ "$(id -u)" != "0" ]; then
    echo "请以root权限运行此脚本。"
    echo "使用 'sudo -i' 切换到root用户后重试。"
    exit 1
fi

# 检查并安装Docker
function ensure_docker_installed() {
    if ! command -v docker &> /dev/null; then
        echo "Docker未检测到，正在安装..."
        curl -fsSL https://get.docker.com | bash
        echo "Docker已成功安装。"
    else
        echo "Docker已安装。"
    fi
}

# 安装节点
function install_validator_node() {
    ensure_docker_installed

    # 获取用户输入的配置参数
    read -p "请输入验证节点的IP地址: " ip_address
    read -p "请输入验证节点的名称: " validator_name
    read -p "请输入奖励收取地址: " beneficiary_address
    read -p "请输入签名者私钥(去掉0x前缀): " private_key

    # 将配置参数保存到 validator.env 文件
    cat <<EOF > validator.env
ENV=testnet-3

STRATEGY_EXECUTOR_IP_ADDRESS=${ip_address}
STRATEGY_EXECUTOR_DISPLAY_NAME=${validator_name}
STRATEGY_EXECUTOR_BENEFICIARY=${beneficiary_address}
SIGNER_PRIVATE_KEY=${private_key}
EOF

    echo "配置已保存至 validator.env 文件。"

    # 拉取 Docker 镜像
    docker pull elixirprotocol/validator:v3

    # 自动检测是否在Apple/ARM架构上运行
    architecture=$(uname -m)
    if [[ "$architecture" == "arm64" || "$architecture" == "aarch64" ]]; then
        echo "检测到ARM架构，使用amd64镜像运行..."
        docker run -it -d \
          --env-file validator.env \
          --name elixir \
          --platform linux/amd64 \
          elixirprotocol/validator:v3
    else
        echo "检测到非ARM架构，使用默认镜像运行..."
        docker run -it -d \
          --env-file validator.env \
          --name elixir \
          elixirprotocol/validator:v3
    fi

    # 操作完成后返回主菜单
    echo "节点安装完成。即将返回主菜单..."
    sleep 2
    display_main_menu
}

# 查看Docker容器日志
function view_docker_logs() {
    echo "正在查看Elixir Docker容器的日志..."
    docker logs -f elixir

    # 返回主菜单
    echo "日志查看结束。即将返回主菜单..."
    sleep 2
    display_main_menu
}

# 启动Watchtower进行自动更新并自动重启容器
function start_watchtower_auto_update() {
    echo "正在启动Watchtower进行自动更新并重启容器..."
    docker run -d \
        --name watchtower \
        -v /var/run/docker.sock:/var/run/docker.sock \
        containrrr/watchtower --interval 86400 --restart elixir  # 每24小时检查一次更新并重启

    # 操作完成后返回主菜单
    echo "Watchtower已启动，正在监控Elixir容器的更新。即将返回主菜单..."
    sleep 2
    display_main_menu
}

# 立即检查更新并重启容器
function check_update_now() {
    echo "正在立即检查并更新Elixir容器..."
    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        containrrr/watchtower -c --run-once elixir  # 立即检查更新并重启

    # 操作完成后返回主菜单
    echo "更新检查已完成。即将返回主菜单..."
    sleep 2
    display_main_menu
}

# 停止Watchtower自动更新
function stop_watchtower_auto_update() {
    echo "正在停止Watchtower自动更新..."
    docker stop watchtower && docker rm watchtower

    # 操作完成后返回主菜单
    echo "Watchtower已停止。即将返回主菜单..."
    sleep 2
    display_main_menu
}

# 检查Watchtower状态
function check_watchtower_status() {
    if docker ps --filter "name=watchtower" --format '{{.Names}}' | grep -q "watchtower"; then
        echo "Watchtower正在运行，并监控Elixir容器的更新。"
    else
        echo "Watchtower未运行。"
    fi

    # 操作完成后返回主菜单
    echo "状态检查完成。即将返回主菜单..."
    sleep 2
    display_main_menu
}

# 主菜单
function display_main_menu() {
    clear
    echo "===================== Elixir V3 节点管理 ========================="
    echo "请选择需要执行的操作:"
    echo "1. 安装Elixir V3节点"
    echo "2. 查看Docker日志"
    echo "3. 启动自动更新"
    echo "4. 停止自动更新"
    echo "5. 检查自动更新状态"
    echo "6. 立即检查更新"
    echo "0. 退出"
    
    read -p "请输入选项（0-6）: " OPTION
    case $OPTION in
        1) install_validator_node ;;
        2) view_docker_logs ;;
        3) start_watchtower_auto_update ;;
        4) stop_watchtower_auto_update ;;
        5) check_watchtower_status ;;
        6) check_update_now ;;  # 立即检查更新的选项
        0) exit 0 ;;
        *) echo "无效的选项，请输入 0-6 之间的数字。" ;;
    esac
}

# 运行主菜单
while true; do
    display_main_menu
done