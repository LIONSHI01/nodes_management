#!/bin/bash

function update_command(){
  wget -O rpc_helper_airchain.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/airchains/airchain_rpc_helper.sh && chmod +x rpc_helper_airchain.sh && ./rpc_helper_airchain.sh
}

function view_block_sync(){
  # Port changed from 26657 -> 26650 to avoid conflix with Rollup Port
  junctiond status --node http://152.53.64.82:26650 | jq .sync_info
}

function view_logs(){
  sudo journalctl -u junctiond -f --no-hostname -o cat
}


function restart_service(){
  sudo systemctl restart junctiond
}

function remove_node(){
  sudo systemctl stop junctiond
  rm -r $HOME/.junction
}

function install_rpc(){
  # Install Dependencies
  sudo apt update && sudo apt upgrade -y
sudo apt-get install git curl build-essential make jq gcc snapd chrony lz4 tmux unzip bc -y

# Install GO: (amd64 - x86)
rm -rf $HOME/go
sudo rm -rf /usr/local/go
cd $HOME
curl https://dl.google.com/go/go1.21.8.linux-amd64.tar.gz | sudo tar -C/usr/local -zxvf -
cat <<'EOF' >>$HOME/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source $HOME/.profile
go version

# Install Airchains: amd64
cd $HOME
wget https://github.com/airchains-network/junction/releases/download/v0.1.0/junctiond
chmod +x junctiond
sudo mv junctiond /usr/local/bin/
cd $HOME
junctiond version


# Set chain and Name Airchains: 
 read -p "Your RPC Node Name: " RPC_NAME
 junctiond init $RPC_NAME --chain-id junction


# Download Genesis & addressbook
 curl -Ls https://node39.top/testnet/airchains/genesis.json > $HOME/.junction/config/genesis.json 
curl -s https://snapshots-testnet.nodejumper.io/airchains-testnet/addrbook.json > $HOME/.junction/config/addrbook.json

# Set Peers
PEERS="560162c4502aea50d271b66d220fadeb5cd17038@37.27.68.29:22656,fa60f4730929eae83d00d9e21bb780b4defe6d03@89.58.28.79:11656,aeaf101d54d47f6c99b4755983b64e8504f6132d@65.21.202.124:28656,ed0fb297a9c8475bb4afacafdea5cf70aa2792d6@65.109.115.15:63656,3250f8c73d5ded86fa5d0a7b78e84715b9c03643@88.198.46.55:19656,7419a1b9753309f5f9d3c62daf882854cc0d7642@152.53.3.95:26656,2699379c4f0e3a17cf1cf6c6ed7f6a79a8fbb562@162.19.235.100:50512,82b3454d6b052703ffd0c7cafea8f69b04e700c3@161.97.145.120:26656,47f61921b54a652ca5241e2a7fc4ed8663091e89@178.63.18.157:19656,a9716527bc0c334553ff0e7df27cd9196bb89f30@92.118.58.126:43456"
sed -i 's|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.junction/config/config.toml

#Create Service
sudo tee /etc/systemd/system/junctiond.service > /dev/null <<EOF
[Unit]
Description=junctiond
After=network-online.target
[Service]
User=root
ExecStart=$(which junctiond) start
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable junctiond

#Set min gas
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.0001amf"|g' $HOME/.junction/config/app.toml

# Download Snapshort
sudo systemctl stop junctiond
cp $HOME/.junction/data/priv_validator_state.json $HOME/.junction/priv_validator_state.json.backup
curl https://snapshots-testnet.nodejumper.io/airchains-testnet/airchains-testnet_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.junction
mv $HOME/.junction/priv_validator_state.json.backup $HOME/.junction/data/priv_validator_state.json
sudo systemctl restart junctiond && sudo journalctl -u junctiond -f --no-hostname -o cat

}


function modify_port_number(){
 vim $HOME/.junction/config/config.toml
}

function modify_app_config(){
 vim $HOME/.junction/config/app.toml
}

function main_menu() {
  while true; do
      clear
      echo "Please choose the command to execute:"
      echo "1. Install RPC"
      echo "2. View Logs"
      echo "3. View Block Sync Status"
      echo "4. Restart Service"
      echo "5. Modify Port Number"
      echo "6. Modify App Config"
      echo "7. Remove Service"
      echo "0. Update Command"
      read -p "Please input (0-8): " OPTION

      case $OPTION in
          1) install_rpc ;;
          2) view_logs ;;
          3) view_block_sync ;;
          4) restart_service ;;
          5) modify_port_number ;;
          6) modify_app_config ;;
          7) remove_node ;;
          0) update_command ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu