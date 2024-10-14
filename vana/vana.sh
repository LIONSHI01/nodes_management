#!/bin/bash

# DLP Validator 安装路径
DLP_PATH="$HOME/vana-dlp-chatgpt"

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 安装必要的依赖
function install_dependencies() {
    echo "安装必要的依赖..."
    apt update && apt upgrade -y
    apt install -y curl wget jq make gcc nano git software-properties-common
}

# 安装 Python 3.11 和 Poetry
function install_python_and_poetry() {
    echo "安装 Python 3.11..."
    add-apt-repository ppa:deadsnakes/ppa -y
    apt update
    apt install -y python3.11 python3.11-venv python3.11-dev python3-pip

    echo "验证 Python 版本..."
    python3.11 --version

    echo "安装 Poetry..."
    curl -sSL https://install.python-poetry.org | python3 -

    echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.bash_profile
    source $HOME/.bash_profile

    echo "验证 Poetry 安装..."
    poetry --version
}

# 安装 Node.js 和 npm
function install_nodejs_and_npm() {
    echo "检查 Node.js 是否已安装..."
    if command -v node > /dev/null 2>&1; then
        echo "Node.js 已安装，版本: $(node -v)"
    else
        echo "Node.js 未安装，正在安装..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
        apt-get install -y nodejs
    fi

    echo "检查 npm 是否已安装..."
    if command -v npm > /dev/null 2>&1; then
        echo "npm 已安装，版本: $(npm -v)"
    else
        echo "npm 未安装，正在安装..."
        apt-get install -y npm
    fi
}

# 安装 PM2
function install_pm2() {
    echo "检查 PM2 是否已安装..."
    if command -v pm2 > /dev/null 2>&1; then
        echo "PM2 已安装，版本: $(pm2 -v)"
    else
        echo "PM2 未安装，正在安装..."
        npm install pm2@latest -g
    fi
}

# 克隆 Vana DLP ChatGPT 仓库并安装依赖
function clone_and_install_repos() {
    echo "克隆 Vana DLP ChatGPT 仓库..."
    rm -rf $DLP_PATH
    git clone https://github.com/vana-com/vana-dlp-chatgpt.git $DLP_PATH
    cd $DLP_PATH
    cp .env.example .env

    echo "创建并激活 Python 虚拟环境..."
    python3.11 -m venv myenv
    source myenv/bin/activate

    echo "安装 Poetry 依赖..."
    pip install poetry
    poetry install

    echo "安装 Vana CLI..."
    pip install vana
}

# 创建钱包
function create_wallet() {
    echo "创建钱包..."
    vanacli wallet create --wallet.name default --wallet.hotkey default

    echo "请确保已在 MetaMask 中添加了 Vana Moksha Testnet 网络。"
    echo "参考步骤手动完成："
    echo "1. RPC URL: https://rpc.moksha.vana.org"
    echo "2. Chain ID: 14800"
    echo "3. Network name: Vana Moksha Testnet"
    echo "4. Currency: VANA"
    echo "5. Block Explorer: https://moksha.vanascan.io"
}

# 导出私钥
function export_private_keys() {
    echo "导出 Coldkey 私钥..."
    ./vanacli wallet export_private_key --wallet.name default --wallet.coldkey default

    echo "导出 Hotkey 私钥..."
    ./vanacli wallet export_private_key --wallet.name default --wallet.hotkey default

    # 确认备份
    read -p "是否已经备份好私钥? (y/n) " backup_confirmed
    if [ "$backup_confirmed" != "y" ]; then
        echo "请先备份好助记词, 然后再继续执行脚本。"
        exit 1
    fi
}

# 生成加密密钥
function generate_encryption_keys() {
    echo "生成加密密钥..."
    cd $DLP_PATH
    ./keygen.sh
}

# 将公钥写入 .env 文件
function write_public_key_to_env() {
    PUBLIC_KEY_FILE="$DLP_PATH/public_key_base64.asc"
    ENV_FILE="$DLP_PATH/.env"

    # 检查公钥文件是否存在
    if [ ! -f "$PUBLIC_KEY_FILE" ]; then
        echo "公钥文件不存在: $PUBLIC_KEY_FILE"
        exit 1
    fi

    # 读取公钥内容
    PUBLIC_KEY=$(cat "$PUBLIC_KEY_FILE")

    # 将公钥写入 .env 文件
    echo "PRIVATE_FILE_ENCRYPTION_PUBLIC_KEY_BASE64=\"$PUBLIC_KEY\"" >> "$ENV_FILE"

    echo "公钥已成功写入到 .env 文件中。"
}

# 部署 DLP 智能合约
function deploy_smart_contracts() {
    echo "克隆 DLP 智能合约仓库..."
    cd $HOME
    rm -rf vana-dlp-smart-contracts
    git clone https://github.com/Josephtran102/vana-dlp-smart-contracts
    cd vana-dlp-smart-contracts

    echo "安装 Yarn..."
    npm install -g yarn
    echo "验证 Yarn 版本..."
    yarn --version

    echo "安装智能合约依赖..."
    yarn install

    echo "复制并编辑 .env 文件..."
    cp .env.example .env
    nano .env  # 手动编辑 .env 文件，填入合约相关信息

    echo "部署智能合约到 Moksha 测试网..."
    npx hardhat deploy --network moksha --tags DLPDeploy
}

# 注册验证器
function register_validator() {
    cd $HOME
    cd vana-dlp-chatgpt
    echo "注册验证器..."
    ./vanacli dlp register_validator --stake_amount 10

    # 获取 Hotkey 地址
    read -p "请输入您的 Hotkey 钱包地址: " HOTKEY_ADDRESS

    echo "批准验证器..."
    ./vanacli dlp approve_validator --validator_address="$HOTKEY_ADDRESS"
}

# 创建 .env 文件
function create_env_file() {
    echo "创建 .env 文件..."
    read -p "请输入 DLP 合约地址: " DLP_CONTRACT
    read -p "请输入 DLP Token 合约地址: " DLP_TOKEN_CONTRACT
    read -p "请输入 OpenAI API Key: " OPENAI_API_KEY

    cat <<EOF > $DLP_PATH/.env
# The network to use, currently Vana Moksha testnet
OD_CHAIN_NETWORK=moksha
OD_CHAIN_NETWORK_ENDPOINT=https://rpc.moksha.vana.org

# Optional: OpenAI API key for additional data quality check
OPENAI_API_KEY="$OPENAI_API_KEY"

# Optional: Your own DLP smart contract address once deployed to the network, useful for local testing
DLP_MOKSHA_CONTRACT="$DLP_CONTRACT"

# Optional: Your own DLP token contract address once deployed to the network, useful for local testing
DLP_TOKEN_MOKSHA_CONTRACT="$DLP_TOKEN_CONTRACT"
EOF
}

# 创建 PM2 配置文件
function create_pm2_config() {
    echo "创建 PM2 配置文件..."
    cat <<EOF > $DLP_PATH/ecosystem.config.js
module.exports = {
  apps: [
    {
      name: 'vana-validator',
      script: '$HOME/.local/bin/poetry',
      args: 'run python -m chatgpt.nodes.validator',
      cwd: '$DLP_PATH',
      interpreter: 'none', // 指定 "none" 以避免 PM2 使用默认的 Node.js 解释器
      env: {
        PATH: '/root/.local/bin:/usr/local/bin:/usr/bin:/bin:/root/vana-dlp-chatgpt/myenv/bin',
        PYTHONPATH: '/root/vana-dlp-chatgpt',
        OD_CHAIN_NETWORK: 'moksha',
        OD_CHAIN_NETWORK_ENDPOINT: 'https://rpc.moksha.vana.org',
        OPENAI_API_KEY: '$OPENAI_API_KEY',
        DLP_MOKSHA_CONTRACT: '$DLP_CONTRACT',
        DLP_TOKEN_MOKSHA_CONTRACT: '$DLP_TOKEN_CONTRACT',
        PRIVATE_FILE_ENCRYPTION_PUBLIC_KEY_BASE64: '$PUBLIC_KEY'
      },
      restart_delay: 10000, // 重启延迟，单位毫秒
      max_restarts: 10, // 最大重启次数
      autorestart: true,
      watch: false,
      // 可根据需要添加更多配置
    },
  ],
};
EOF
}

# 使用 PM2 启动 DLP Validator 节点
function start_validator() {
    echo "使用 PM2 启动 DLP Validator 节点..."
    pm2 start $DLP_PATH/ecosystem.config.js

    echo "设置 PM2 开机自启..."
    pm2 startup systemd -u root --hp /root
    pm2 save

    echo "DLP Validator 节点已启动。您可以使用 'pm2 logs vana-validator' 查看日志。"
}

# 安装 DLP Validator 节点
function install_dlp_node() {
    install_dependencies
    install_python_and_poetry
    install_nodejs_and_npm
    install_pm2
    clone_and_install_repos
    create_wallet
    export_private_keys
    generate_encryption_keys
    write_public_key_to_env 
    deploy_smart_contracts
    create_env_file
    register_validator
    create_pm2_config
    start_validator
}

# 查看节点日志
function check_node() {
    pm2 logs vana-validator
}

# 卸载节点
function uninstall_node() {
    echo "卸载 DLP Validator 节点..."
    pm2 delete vana-validator
    rm -rf $DLP_PATH
    echo "DLP Validator 节点已删除。"
}

# 主菜单
function main_menu() {
    clear
    echo "脚本以及教程由推特用户大赌哥 @y95277777 编写，免费开源，请勿相信收费"
    echo "========================= VANA DLP Validator 节点安装 ======================================="
    echo "节点社区 Telegram 群组:https://t.me/niuwuriji"
    echo "节点社区 Telegram 频道:https://t.me/niuwuriji"
    echo "节点社区 Discord 社群:https://discord.gg/GbMV5EcNWF"    
    echo "请选择要执行的操作:"
    echo "1. 安装 DLP Validator 节点"
    echo "2. 查看节点日志"
    echo "3. 删除节点"
    read -p "请输入选项（1-3）: " OPTION
    case $OPTION in
    1) install_dlp_node ;;
    2) check_node ;;
    3) uninstall_node ;;
    *) echo "无效选项。" ;;
    esac
}

# 显示主菜单
main_menu