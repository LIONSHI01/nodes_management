#!/usr/bin/env bash

# 检查是否以 root 用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以 root 用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到 root 用户，然后再次运行此脚本。"
    exit 1
fi

# 脚本保存路径
SCRIPT_PATH="$HOME/Ritual.sh"

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由大赌社区哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "如有问题，可联系推特，仅此只有一个号"
        echo "================================================================"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "请选择要执行的操作:"
        echo "1) 安装 Ritual 节点"
        echo "2. 查看 Ritual 节点日志"
        echo "3. 删除 Ritual 节点"
        echo "4. 退出脚本"
        
        read -p "请输入您的选择: " choice

        case $choice in
            1) 
                install_ritual_node
                ;;
            2)
                view_logs
                ;;
            3)
                remove_ritual_node
                ;;
            4)
                echo "退出脚本！"
                exit 0
                ;;
            *)
                echo "无效选项，请重新选择。"
                ;;
        esac

        echo "按任意键继续..."
        read -n 1 -s
    done
}

# 安装 Ritual 节点函数
function install_ritual_node() {

# 系统更新及必要的软件包安装 (包含 Python 和 pip)
echo "系统更新及安装必要的包..."
sudo apt update && sudo apt upgrade -y
sudo apt -qy install curl git jq lz4 build-essential screen python3 python3-pip

# 安装或升级 Python 包
echo "[提示] 升级 pip3 并安装 infernet-cli / infernet-client"
pip3 install --upgrade pip
pip3 install infernet-cli infernet-client

 
# 检查 Docker 是否已安装
echo "检查 Docker 是否已安装..."
if command -v docker &> /dev/null; then
  echo " - Docker 已安装，跳过此步骤。"
else
  echo " - Docker 未安装，正在进行安装..."
  
  # 更新 apt 包索引
  sudo apt update
  
  # 安装必要的包，确保 apt 通过 HTTPS 使用仓库
  sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
  
  # 导入 Docker 官方的 GPG 密钥
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  
  # 添加 Docker 官方仓库
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  
  # 更新 apt 包索引（加入 Docker 仓库后）
  sudo apt update
  
  # 安装 Docker CE (Community Edition)
  sudo apt install -y docker-ce docker-ce-cli containerd.io
  
  # 启动并启用 Docker 服务
  sudo systemctl enable docker
  sudo systemctl start docker
  
  # 确认 Docker 版本
  echo "Docker 安装完成，当前版本："
  docker --version
fi

# 检查 Docker Compose 安装情况
echo "检查 Docker Compose 是否已安装..."
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
  echo " - Docker Compose 未安装，正在进行安装..."
  sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-$(uname -s)-$(uname -m)" \
       -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
else
  echo " - Docker Compose 已安装，跳过此步骤。"
fi

echo "[确认] Docker Compose 版本:"
docker compose version || docker-compose version

# 安装 Foundry 并设置环境变量
 
echo
echo "安装 Foundry "
# 如果 anvil 正在运行则停止
if pgrep anvil &>/dev/null; then
  echo "[警告] anvil 正在运行，正在关闭以更新 Foundry。"
  pkill anvil
  sleep 2
fi

cd ~ || exit 1
mkdir -p foundry
cd foundry
curl -L https://foundry.paradigm.xyz | bash

# 安装或更新
$HOME/.foundry/bin/foundryup

# 将 ~/.foundry/bin 添加到 PATH
if [[ ":$PATH:" != *":$HOME/.foundry/bin:"* ]]; then
  export PATH="$HOME/.foundry/bin:$PATH"
fi

echo "[确认] forge 版本:"
forge --version || {
  echo "[错误] 无法找到 forge 命令，可能是 ~/.foundry/bin 未添加到 PATH 或安装失败。"
  exit 1
}

# 删除 /usr/bin/forge 防止 ZOE 错误
if [ -f /usr/bin/forge ]; then
  echo "[提示] 删除 /usr/bin/forge..."
  sudo rm /usr/bin/forge
fi

echo "[提示] Foundry 安装及环境变量配置完成。"
cd ~ || exit 1

 
# 克隆 infernet-container-starter
 
# 检查目录是否存在，存在则删除
if [ -d "infernet-container-starter" ]; then
    echo "目录 infernet-container-starter 已存在，正在删除..."
    rm -rf "infernet-container-starter"
    echo "目录 infernet-container-starter 已删除。"
fi

# 克隆仓库
echo "克隆 infernet-container-starter..."
git clone https://github.com/ritual-net/infernet-container-starter

# 进入目录
cd infernet-container-starter || { echo "[错误] 进入目录失败"; exit 1; }

# 拉取 Docker 镜像
echo "拉取 Docker 镜像..."
docker pull ritualnetwork/hello-world-infernet:latest

# 在 screen 会话中进行初始部署(make deploy-container)
 
echo " 检查 screen 会话 ritual 是否存在..."

# 检查 'ritual' 会话是否存在
if screen -list | grep -q "ritual"; then
    echo "[提示] 发现 ritual 会话正在运行，正在终止..."
    screen -S ritual -X quit
    sleep 1
fi

echo "在 screen -S ritual 会话中开始容器部署..."
sleep 1

# 启动新的 screen 会话进行部署
screen -S ritual -dm bash -c 'project=hello-world make deploy-container; exec bash'

echo "[提示] 部署工作正在后台的 screen 会话 (ritual) 中进行。"

# 用户输入 (Private Key)
 
echo
echo "配置 Ritual Node 文件..."

read -p "请输入您的 Private Key (0x...): " PRIVATE_KEY

# 默认设置
RPC_URL="https://mainnet.base.org/"
RPC_URL_SUB="https://mainnet.base.org/"
# 替换 registry 地址
REGISTRY="0x3B1554f346DFe5c482Bb4BA31b880c1C18412170"
SLEEP=3
START_SUB_ID=160000
BATCH_SIZE=50  # 推荐使用公用 RPC
TRAIL_HEAD_BLOCKS=3
INFERNET_VERSION="1.4.0"  # infernet 镜像标签

 
# 修改 config.json / Deploy.s.sol / docker-compose.yaml / Makefile
 

# 修改 deploy/config.json
sed -i "s|\"registry_address\": \".*\"|\"registry_address\": \"$REGISTRY\"|" deploy/config.json
sed -i "s|\"private_key\": \".*\"|\"private_key\": \"$PRIVATE_KEY\"|" deploy/config.json
sed -i "s|\"sleep\": [0-9]*|\"sleep\": $SLEEP|" deploy/config.json
sed -i "s|\"starting_sub_id\": [0-9]*|\"starting_sub_id\": $START_SUB_ID|" deploy/config.json
sed -i "s|\"batch_size\": [0-9]*|\"batch_size\": $BATCH_SIZE|" deploy/config.json
sed -i "s|\"trail_head_blocks\": [0-9]*|\"trail_head_blocks\": $TRAIL_HEAD_BLOCKS|" deploy/config.json
sed -i 's|"rpc_url": ".*"|"rpc_url": "https://mainnet.base.org"|' deploy/config.json
sed -i 's|"rpc_url": ".*"|"rpc_url": "https://mainnet.base.org"|' projects/hello-world/container/config.json


# 修改 projects/hello-world/container/config.json
sed -i "s|\"registry_address\": \".*\"|\"registry_address\": \"$REGISTRY\"|" projects/hello-world/container/config.json
sed -i "s|\"private_key\": \".*\"|\"private_key\": \"$PRIVATE_KEY\"|" projects/hello-world/container/config.json
sed -i "s|\"sleep\": [0-9]*|\"sleep\": $SLEEP|" projects/hello-world/container/config.json
sed -i "s|\"starting_sub_id\": [0-9]*|\"starting_sub_id\": $START_SUB_ID|" projects/hello-world/container/config.json
sed -i "s|\"batch_size\": [0-9]*|\"batch_size\": $BATCH_SIZE|" projects/hello-world/container/config.json
sed -i "s|\"trail_head_blocks\": [0-9]*|\"trail_head_blocks\": $TRAIL_HEAD_BLOCKS|" projects/hello-world/container/config.json

# 修改 Deploy.s.sol
sed -i "s|\(registry\s*=\s*\).*|\1$REGISTRY;|" projects/hello-world/contracts/script/Deploy.s.sol
sed -i "s|\(RPC_URL\s*=\s*\).*|\1\"$RPC_URL\";|" projects/hello-world/contracts/script/Deploy.s.sol

# 使用 latest node 镜像
sed -i 's|ritualnetwork/infernet-node:[^"]*|ritualnetwork/infernet-node:latest|' deploy/docker-compose.yaml

# 修改 Makefile (sender, RPC_URL)
MAKEFILE_PATH="projects/hello-world/contracts/Makefile"
sed -i "s|^sender := .*|sender := $PRIVATE_KEY|"  "$MAKEFILE_PATH"
sed -i "s|^RPC_URL := .*|RPC_URL := $RPC_URL|"    "$MAKEFILE_PATH"

 
# 进入项目目录
cd ~/infernet-container-starter || exit 1

# 重启容器
echo
echo "docker compose down & up..."
docker compose -f deploy/docker-compose.yaml down
docker compose -f deploy/docker-compose.yaml up -d

echo
echo "[提示] 容器正在后台 (-d) 运行。"
echo "使用 docker ps 查看状态。日志查看：docker logs infernet-node"

# 安装 Forge 库 (解决冲突)
echo
echo "安装 Forge (项目依赖)"
cd projects/hello-world/contracts || exit 1
rm -rf lib/forge-std
rm -rf lib/infernet-sdk

forge install --no-commit foundry-rs/forge-std
forge install --no-commit ritual-net/infernet-sdk

# 重启容器
echo
echo "重启 docker compose..."
cd ~/infernet-container-starter || exit 1
docker compose -f deploy/docker-compose.yaml down
docker compose -f deploy/docker-compose.yaml up -d
echo "[提示] 查看 infernet-node 日志：docker logs infernet-node"

# 部署项目合约 
 
echo
echo "部署项目合约..."
DEPLOY_OUTPUT=$(project=hello-world make deploy-contracts 2>&1)
echo "$DEPLOY_OUTPUT"

# 提取新部署的合约地址（例如：Deployed SaysHello:  0x...）
NEW_ADDR=$(echo "$DEPLOY_OUTPUT" | grep -oP 'Deployed SaysHello:\s+\K0x[0-9a-fA-F]{40}')
if [ -z "$NEW_ADDR" ]; then
  echo "[警告] 未找到新合约地址。可能需要手动更新 CallContract.s.sol。"
else
  echo "[提示] 部署的 SaysHello 地址: $NEW_ADDR"
  # 在 CallContract.s.sol 中替换旧地址为新地址
  # 例如：SaysGM saysGm = SaysGM(0x13D69Cf7...) -> SaysGM saysGm = SaysGM(0xA529dB3c9...)
  sed -i "s|SaysGM saysGm = SaysGM(0x[0-9a-fA-F]\+);|SaysGM saysGm = SaysGM($NEW_ADDR);|" \
      projects/hello-world/contracts/script/CallContract.s.sol

  # 执行 call-contract
  echo
  echo "使用新地址执行 call-contract..."
  project=hello-world make call-contract
fi

echo
echo "===== Ritual Node 完成====="

  # 提示用户按任意键返回主菜单
  read -n 1 -s -r -p "按任意键返回主菜单..."
  main_menu
}

# 查看 Ritual 节点日志
function view_logs() {
    echo "正在查看 Ritual 节点日志..."
    docker logs -f infernet-node
}

# 删除 Ritual 节点
function remove_ritual_node() {
    echo "正在删除 Ritual 节点..."

    # 停止并移除 Docker 容器
    echo "停止并移除 Docker 容器..."
    cd /root/infernet-container-starter
    docker compose down

    # 删除仓库文件
    echo "删除相关文件..."
    rm -rf ~/infernet-container-starter

    # 删除 Docker 镜像
    echo "删除 Docker 镜像..."
    docker rmi ritualnetwork/hello-world-infernet:latest

    echo "Ritual 节点已成功删除！"
}

# 调用主菜单函数
main_menu