#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/t3rn.sh"
LOGFILE="$HOME/executor/executor.log"
EXECUTOR_DIR="$HOME/executor"

# 检查是否以 root 用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以 root 用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到 root 用户，然后再次运行此脚本。"
    exit 1
fi

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由大赌社区哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "如有问题，可联系推特，仅此只有一个号"
        echo "================================================================"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "请选择要执行的操作:"
        echo "1) 执行脚本"
        echo "2) 查看日志"
        echo "3) 删除节点"
        echo "0) 更新腳本"
        echo "5) 退出"
        
        read -p "请输入你的选择 [1-3]: " choice
        
        case $choice in
            1)
                execute_script
                ;;
            2)
                view_logs
                ;;
            3)
                delete_node
                ;;
            0)
                update_script
                ;;
            5)
                echo "退出脚本。"
                exit 0
                ;;
            *)
                echo "无效的选择，请重新输入。"
                ;;
        esac
    done
}

# 执行脚本函数
function execute_script() {
    # 检查 pm2 是否安装，如果没有安装则自动安装
    if ! command -v pm2 &> /dev/null; then
        echo "pm2 未安装，正在安装 pm2..."
        # 安装 pm2
        sudo npm install -g pm2
        if [ $? -eq 0 ]; then
            echo "pm2 安装成功。"
        else
            echo "pm2 安装失败，请检查 npm 配置。"
            exit 1
        fi
    else
        echo "pm2 已安装，继续执行。"
    fi

    # 下载文件
    echo "正在下载 executor-linux-v0.47.0.tar.gz..."
    wget https://github.com/t3rn/executor-release/releases/download/v0.47.0/executor-linux-v0.47.0.tar.gz

    # 检查下载是否成功
    if [ $? -eq 0 ]; then
        echo "下载成功。"
    else
        echo "下载失败，请检查网络连接或下载地址。"
        exit 1
    fi

    # 解压文件到当前目录
    echo "正在解压文件..."
    tar -xvzf executor-linux-v0.47.0.tar.gz

    # 检查解压是否成功
    if [ $? -eq 0 ]; then
        echo "解压成功。"
    else
        echo "解压失败，请检查 tar.gz 文件。"
        exit 1
    fi

    # 检查解压后的文件名是否包含 'executor'
    echo "正在检查解压后的文件或目录名称是否包含 'executor'..."
    if ls | grep -q 'executor'; then
        echo "检查通过，找到包含 'executor' 的文件或目录。"
    else
        echo "未找到包含 'executor' 的文件或目录，可能文件名不正确。"
        exit 1
    fi

    # 提示用户输入环境变量的值，给 EXECUTOR_MAX_L3_GAS_PRICE 设置默认值为 100
    read -p "请输入 EXECUTOR_MAX_L3_GAS_PRICE 的值 [默认 1000]: " EXECUTOR_MAX_L3_GAS_PRICE
    EXECUTOR_MAX_L3_GAS_PRICE="${EXECUTOR_MAX_L3_GAS_PRICE:-1000}"

    # 提示用户输入 RPC_ENDPOINTS_OPSP，如果没有输入则使用默认值
    read -p "请输入 RPC_ENDPOINTS_OPSP 的值 [默认 https://sepolia.optimism.io]: " RPC_ENDPOINTS_OPSP
    RPC_ENDPOINTS_OPSP="${RPC_ENDPOINTS_OPSP:-https://sepolia.optimism.io}"

    # 提示用户输入 RPC_ENDPOINTS_BSSP，如果没有输入则使用默认值
    read -p "请输入 RPC_ENDPOINTS_BSSP 的值 [默认 https://sepolia.base.org]: " RPC_ENDPOINTS_BSSP
    RPC_ENDPOINTS_BSSP="${RPC_ENDPOINTS_BSSP:-https://sepolia.base.org}"

    # 提示用户输入 RPC_ENDPOINTS_BLSS，如果没有输入则使用默认值
    read -p "请输入 RPC_ENDPOINTS_BLSS 的值 [默认 https://blessnet-sepolia-testnet.rpc.caldera.xyz/http]: " RPC_ENDPOINTS_BLSS
    RPC_ENDPOINTS_BLSS="${RPC_ENDPOINTS_BLSS:-https://blessnet-sepolia-testnet.rpc.caldera.xyz/http}"

    # 提示用户输入 RPC_ENDPOINTS_ARBT，如果没有输入则使用默认值
    read -p "请输入 RPC_ENDPOINTS_ARBT 的值 [默认 https://arbitrum-sepolia-rpc.publicnode.com]: " RPC_ENDPOINTS_ARBT
    RPC_ENDPOINTS_ARBT="${RPC_ENDPOINTS_ARBT:-https://arbitrum-sepolia-rpc.publicnode.com}"
    

    # 设置环境变量
    export NODE_ENV=testnet
    export LOG_LEVEL=debug
    export LOG_PRETTY=false
    # export ENABLED_NETWORKS='base-sepolia,optimism-sepolia,l1rn'
    export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,blast-sepolia,optimism-sepolia,l1rn'
    export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
    export EXECUTOR_MAX_L3_GAS_PRICE="$EXECUTOR_MAX_L3_GAS_PRICE"

    # 新增的环境变量
    export EXECUTOR_PROCESS_ORDERS=true
    export EXECUTOR_PROCESS_CLAIMS=true
    export RPC_ENDPOINTS_OPSP="$RPC_ENDPOINTS_OPSP"
    export RPC_ENDPOINTS_BSSP="$RPC_ENDPOINTS_BSSP"
    export RPC_ENDPOINTS_BLSS="$RPC_ENDPOINTS_BLSS"
    export RPC_ENDPOINTS_ARBT="$RPC_ENDPOINTS_ARBT"
    

    # 提示用户输入私钥
    read -p "请输入 PRIVATE_KEY_LOCAL 的值: " PRIVATE_KEY_LOCAL

    # 设置私钥变量
    export PRIVATE_KEY_LOCAL="$PRIVATE_KEY_LOCAL"

    # 删除压缩文件
    echo "删除压缩包..."
    rm executor-linux-v0.57.0.tar.gz

    # 切换目录到 executor/bin
    echo "切换目录并准备使用 pm2 启动 executor..."
    cd ~/executor/executor/bin

    # 使用 pm2 启动 executor
    echo "通过 pm2 启动 executor..."
    pm2 start ./executor --name "executor" --log "$LOGFILE" --env NODE_ENV=testnet

    # 显示 pm2 进程列表
    pm2 list

    echo "executor 已通过 pm2 启动。"

    # 提示用户按任意键返回主菜单
    read -n 1 -s -r -p "按任意键返回主菜单..."
    main_menu
}

# 查看日志函数
function view_logs() {
    if [ -f "$LOGFILE" ]; then
        echo "实时显示日志文件内容（按 Ctrl+C 退出）："
        tail -f "$LOGFILE"  # 使用 tail -f 实时跟踪日志文件
    else
        echo "日志文件不存在。"
    fi
}

function update_script(){
    wget -O t3rn_node_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/refs/heads/main/t3rn/t3rn_node-helper.sh && chmod +x t3rn_node_helper.sh && ./t3rn_node_helper.sh
}

# 删除节点函数
function delete_node() {
    echo "正在停止节点进程..."

    # 使用 pm2 停止 executor 进程
    pm2 stop "executor"

    # 删除 executor 所在的目录
    if [ -d "$EXECUTOR_DIR" ]; then
        echo "正在删除节点目录..."
        rm -rf "$EXECUTOR_DIR"
        echo "节点目录已删除。"
    else
        echo "节点目录不存在，可能已被删除。"
    fi

    echo "节点删除操作完成。"

    # 提示用户按任意键返回主菜单
    read -n 1 -s -r -p "按任意键返回主菜单..."
    main_menu
}

# 启动主菜单
main_menu