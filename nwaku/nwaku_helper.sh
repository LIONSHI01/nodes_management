#!/bin/bash


function install(){
  git clone https://github.com/waku-org/nwaku-compose
  cd nwaku-compose


# Set Env
  # Fill in Vars in .env
  read -p "Input Infura Key : " INFURA_KEY
  read -p "Input Wallet Private Key (no 0x) : " WALLET_PRIVATE_KEY


  # Write docker-compose.yml
  tee .env > /dev/null <<EOF

  # RPC URL for accessing testnet via HTTP.
# e.g. https://sepolia.infura.io/v3/123aa110320f4aec179150fba1e1b1b1
RLN_RELAY_ETH_CLIENT_ADDRESS=https://sepolia.infura.io/v3/$INFURA_KEY

# Private key of testnet where you have sepolia ETH that would be staked into RLN contract.
# Note: make sure you don't use the '0x' prefix.
#       e.g. 0116196e9a8abed42dd1a22eb63fa2a5a17b0c27d716b87ded2c54f1bf192a0b
ETH_TESTNET_KEY=$WALLET_PRIVATE_KEY

# Password you would like to use to protect your RLN membership.
RLN_RELAY_CRED_PASSWORD=test1234

# Advanced. Can be left empty in normal use cases.
NWAKU_IMAGE=
NODEKEY=
DOMAIN=
EXTRA_ARGS=
STORAGE_SIZE=

EOF

    echo "確保錢包已有 Sepolia ETH"
    read -r response
    response=$(echo "$response" | tr '[:lower:]' '[:upper:]')
    if [[ "$response" == "Y" ]]; then
        echo "Register RLN"
      # Register 
    bash ./register_rln.sh
    else
      echo "退出安裝"
      exit 1
    fi


    # Start Node
    docker-compose up -d

}

function view_logs(){
  docker-compose logs -f nwaku
}

function restart_service(){
  cd ~/nwaku-compose
  docker-compose restart 
}

function delete_service(){
  cd ~/nwaku-compose
  docker-compose down
  cd ~
  rm -r ~/nwaku-compose
}  

function update_script(){
  wget -O nwaku_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/nwaku/nwaku_helper.sh && chmod +x nwaku_helper.sh && ./nwaku_helper.sh
}



function main_menu() {
  while true; do
      clear
      echo "Please choose the command to execute:"
      echo "1. Install"
      echo "2. View Logs"
      echo "3. Restart Node"
      echo "4. Delete Node"
      echo "0. Update Command"
      read -p "Please input (0-4): " OPTION

      case $OPTION in
          1) install ;;
          2) view_logs ;;
          3) restart_service ;;
          4) delete_service ;;
          0) update_script ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu