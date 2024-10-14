#!/bin/bash

# 欢迎信息
echo "欢迎使用 Nesa 矿工节点安装脚本"
echo "关注我的推特获取更多更新: https://x.com/BtcK241918"

# 菜单函数
show_menu() {
    echo "请选择一个操作:"
    echo "1) 安装必要依赖并安装 Nesa 矿工节点"
    echo "2) 卸载 Nesa 矿工节点"
    echo "3) 查看日志"
    echo "4) 查看 Nesa 节点 ID"
    echo "5) 退出"
}

# 安装必要依赖并安装 Nesa 矿工节点的函数
install_nesa() {
    echo "正在安装必要的依赖..."
    sudo apt update && sudo apt install curl jq python3 -y
    
    # 安装 pip3
    if ! command -v pip3 &> /dev/null; then
        echo "未检测到 pip3，正在安装..."
        sudo apt install python3-pip -y
    fi

    # 安装 ecdsa 模块
    echo "检查并安装 ecdsa 模块..."
    if ! python3 -c "import ecdsa" &> /dev/null; then
        echo "未安装 ecdsa，正在安装..."
        pip3 install ecdsa || {
            echo "安装 ecdsa 模块失败，请手动安装。"
            return
        }
        echo "ecdsa 模块安装完成！"
    else
        echo "ecdsa 模块已安装，跳过安装步骤。"
    fi

    # 安装 Nesa 矿工节点
    echo "正在安装 Nesa 矿工节点..."
    bash <(curl -s https://raw.githubusercontent.com/nesaorg/bootstrap/master/bootstrap.sh) || {
        echo "Nesa 矿工节点安装失败！"
        return
    }
    echo "Nesa 矿工节点安装完成！"
}

# 卸载 Nesa 矿工节点的函数
uninstall_nesa() {
    echo "正在卸载 Nesa 矿工节点..."
    # 添加具体的卸载命令
    # 示例：sudo systemctl stop nesa && sudo apt remove nesa -y
    echo "Nesa 矿工节点卸载完成！"
}

# 查看日志的函数
view_logs() {
    echo "查看 Nesa 矿工节点日志..."
    if [ -f /var/log/nesa.log ]; then
        cat /var/log/nesa.log
    else
        echo "日志文件不存在！"
    fi
}

# 查看 Nesa 节点 ID 的函数
view_node_id() {
    echo "查看 Nesa 节点 ID..."
    if [ -f ~/.nesa/identity/node_id.id ]; then
        cat ~/.nesa/identity/node_id.id
    else
        echo "节点 ID 文件不存在！"
    fi
}

# 主循环
while true; do
    show_menu
    read -p "请输入选项: " choice
    case $choice in
        1)
            install_nesa
            read -p "按回车返回主菜单..."
            ;;
        2)
            uninstall_nesa
            read -p "按回车返回主菜单..."
            ;;
        3)
            view_logs
            read -p "按回车返回主菜单..."
            ;;
        4)
            view_node_id
            read -p "按回车返回主菜单..."
            ;;
        5)
            echo "退出脚本。"
            exit 0
            ;;
        *)
            echo "无效的选项，请重新选择。"
            ;;
    esac
done