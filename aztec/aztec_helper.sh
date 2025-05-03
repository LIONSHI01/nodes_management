#!/bin/bash
# Aztec Sequencer 一键部署脚本 - by K2 节点教程分享
# Telegram: https://t.me/+EaCiFDOghoM3Yzll
# Twitter: https://x.com/BtcK241918

# 清除屏幕
clear

# 安装依赖项
function install_dependencies() {
  clear
  echo -e "\n[1/4] 正在检查并安装依赖项...\n"

  if ! command -v curl &>/dev/null; then
    echo "安装 curl..."
    sudo apt update && sudo apt install -y curl
  fi

  if ! command -v docker &>/dev/null; then
    echo "安装 Docker..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
  else
    echo "Docker 已安装，跳过。"
  fi

  if ! command -v nvm &>/dev/null; then
    echo "安装 nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  fi

  if ! command -v node &>/dev/null || [[ $(node -v | cut -d. -f1 | tr -d v) -lt 18 ]]; then
    echo "安装 Node.js v18 LTS..."
    nvm install 18
    nvm use 18
  else
    echo "Node.js 已安装，跳过。"
  fi
}

# 安装 Aztec 工具
function install_aztec() {
  clear
  echo -e "\n[2/4] 检查并安装 Aztec 工具..."
  if ! command -v aztec &>/dev/null; then
    echo "安装 Aztec 工具..."
    bash -i <(curl -s https://install.aztec.network)
  else
    echo "Aztec 工具已安装，跳过。"
  fi
}

# 启动 Sequencer 节点
function run_sequencer() {
  clear
  echo -e "\n[3/4] 配置并启动 Aztec Sequencer...\n"

  read -p "请输入您的以太坊私钥（0x开头）: " VALIDATOR_PRIVATE_KEY
  read -p "请输入您的公钥地址（0x开头）: " VALIDATOR_ADDRESS
  read -p "请输入您的 L1 RPC 地址: " L1_RPC
  read -p "请输入您的 L1 共识客户端地址（如 dRPC）: " L1_CONSENSUS_RPC
  PUBLIC_IP=$(curl -s ifconfig.me)
  echo "检测到公网 IP 为：$PUBLIC_IP"

  docker run -d \
    --name aztec-sequencer \
    --restart unless-stopped \
    -e ETHEREUM_HOSTS="$L1_RPC" \
    -e L1_CONSENSUS_HOST_URLS="$L1_CONSENSUS_RPC" \
    -e VALIDATOR_PRIVATE_KEY="$VALIDATOR_PRIVATE_KEY" \
    -e P2P_IP="$PUBLIC_IP" \
    -p 40400:40400/tcp -p 40400:40400/udp -p 8080:8080 \
    aztecprotocol/aztec:0.85.0-alpha-testnet.5 \
    sh -c "node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start \
      --network alpha-testnet --node --archiver --sequencer --sequencer.coinbase=$VALIDATOR_ADDRESS --sequencer.validatorPrivateKey=$VALIDATOR_PRIVATE_KEY --p2p.p2pIp=$PUBLIC_IP"

  echo -e "\n✅ Sequencer 节点已启动，请确保端口 40400 UDP/TCP 已开放。"
}

# 查看日志
function show_logs() {
  clear
  echo -e "\n[日志] 正在实时输出 sequencer 日志...\n"
  docker logs -f aztec-sequencer
}

# 卸载节点
function uninstall_node() {
  clear
  echo -e "\n[卸载] 正在停止并删除节点容器..."
  docker stop aztec-sequencer && docker rm aztec-sequencer
  echo "已卸载节点（数据保留在 docker 卷中）。"
}

# 重启节点
function restart_node() {
  clear
  echo -e "\n[重启] 正在重启 Aztec Sequencer 节点...\n"
  docker restart aztec-sequencer
  echo -e "\n✅ 节点已重启。"
}

# 注册为验证者
function register_validator() {
  clear
  echo -e "\n[4/4] 注册为验证者\n"
  echo "⚠️ 请确认 Sequencer 节点已完全同步并运行正常。"
  echo "📌 可通过菜单中的【查看节点日志】功能确认同步状态（直到出现区块生成日志）。"
  read -p "是否继续注册验证者？(y/n): " confirm
  if [[ "$confirm" != "y" ]]; then
    echo "已取消注册操作。"
    return
  fi

  read -p "请输入您的以太坊私钥（0x 开头）: " L1_PRIVATE_KEY
  read -p "请输入您的验证者钱包地址: " VALIDATOR_ADDRESS
  read -p "请输入您的 L1 RPC 地址: " L1_RPC

  echo -e "\n正在执行注册命令...\n"
  aztec add-l1-validator \
    --l1-rpc-urls "$L1_RPC" \
    --private-key "$L1_PRIVATE_KEY" \
    --attester "$VALIDATOR_ADDRESS" \
    --proposer-eoa "$VALIDATOR_ADDRESS" \
    --staking-asset-handler 0xF739D03e98e23A7B659408aBA8921fF3bAc4b2 \
    --l1-chain-id 11155111

  echo -e "\n✅ 验证者注册命令已执行。请确认链上是否成功注册。"
}

# 获取同步证明
function get_sync_proof() {
  clear
  echo -e "\n[同步证明] 获取最新已证明区块和证明...\n"

  block=$(curl -s -X POST -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"node_getL2Tips","params":[],"id":67}' \
  127.0.0.1:8080 | jq -r ".result.proven.number")

  echo -e "\n✅ 最新已证明区块号: $block"

  proof=$(curl -s -X POST -H 'Content-Type: application/json' \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"node_getArchiveSiblingPath\",\"params\":[\"$block\",\"$block\"],\"id\":67}" \
  127.0.0.1:8080 | jq -r ".result")

  if [ "$proof" = "null" ] || [ -z "$proof" ]; then
    echo -e "\n⚠️ 该区块未找到有效证明，请稍后重试或检查节点同步状态。"
  else
    echo -e "\n✅ 证明数据如下："
    echo "$proof"

    echo ""
    read -p "请输入您的验证者钱包地址: " wallet

    echo -e "\n📋 请复制以下指令发送到 Discord 验证频道：\n"
    echo "/operator start"
    echo "地址: $wallet"
    echo "区块: $block"
    echo "证明: $proof"
  fi
}

# 修改菜单选项
function main_menu() {
  while true; do
    clear
    echo "========= Aztec Sequencer 一键部署脚本 ========="
    echo "脚本署名: K2 节点教程分享"
    echo "Telegram: https://t.me/+EaCiFDOghoM3Yzll"
    echo "Twitter: https://x.com/BtcK241918"
    echo "==============================================="
    echo "1. 安装依赖并启动 Sequencer 节点"
    echo "2. 查看节点日志"
    echo "3. 卸载 Sequencer 节点"
    echo "4. 注册为验证者（需节点已同步）"
    echo "5. 获取同步证明"
    echo "6. 重启节点"
    echo "7. 退出"
    echo "==============================================="
    read -p "请输入选项 [1-7]: " CHOICE
    case $CHOICE in
      1)
        install_dependencies
        install_aztec
        run_sequencer
        read -n 1 -s -r -p "按任意键返回主菜单..."
        ;;
      2)
        show_logs
        read -n 1 -s -r -p "按任意键返回主菜单..."
        ;;
      3)
        uninstall_node
        read -n 1 -s -r -p "按任意键返回主菜单..."
        ;;
      4)
        register_validator
        read -n 1 -s -r -p "按任意键返回主菜单..."
        ;;
      5)
        get_sync_proof
        read -n 1 -s -r -p "按任意键返回主菜单..."
        ;;
      6)
        restart_node
        read -n 1 -s -r -p "按任意键返回主菜单..."
        ;;
      7)
        echo "退出脚本。"
        exit 0
        ;;
      *)
        echo "无效输入，请重新选择。"
        sleep 1
        ;;
    esac
  done
}

main_menu