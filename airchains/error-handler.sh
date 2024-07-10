#!/bin/bash

function roll_back(){
  sudo systemctl stop stationd
  cd $HOME/tracks
  go run cmd/main.go rollback
  go run cmd/main.go rollback
  go run cmd/main.go rollback
  sudo systemctl restart stationd
}

function change_rpc(){
  read -p "Please input RPC: " NEW_RPC
  sed -i "s|JunctionRPC = \".*\"|JunctionRPC = \"$NEW_RPC\"|" ~/.tracks/config/sequencer.toml
  echo Updated RPC
  
  echo Restarting Service
  restart()
  echo Restarted Successfully

}

function stop_service(){
  sudo systemctl stop stationd
}

function restart(){
  sudo systemctl restart stationd
}

function logs(){
  sudo journalctl -u stationd -f -o cat
}

function txLogs(){
  screen -r tx_airchains_bot
}

function createEvmTxBot(){
  cd
  mkdir airchain_evm_tx_bot
  cd airchain_evm_tx_bot
  git clone https://github.com/LIONSHI01/airchain-evm-tx-bot.git .
  npm install
  touch .env
  
  # Input Env Config
  read -p "Please input VPS IP: " VPS_IP
  read -p "Please input EVM Wallet Private Key: " PRIVATE_KEY
  read -p "Please input EVM Address (From): " FROM_WALLET
  read -p "Please input To Wallet Address (To): " TO_WALLET

  sudo tee .env > /dev/null << EOF

  VPS_IP=$VPS_IP
  PRIVATE_KEY=$PRIVATE_KEY
  FROM=$FROM_WALLET
  TO=$TO_WALLET
  
EOF

  screen -S tx_airchains_bot
  npm start
}

function update_command(){
  wget -O airchains_error_handler.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/airchains/error-handler.sh && chmod +x airchains_error_handler.sh && ./airchains_error_handler.sh
}


function main_menu() {
  while true; do
      clear
      echo "Please choose the command to execute:"
      echo "1. Roll Back"
      echo "2. Restart Service"
      echo "3. View Logs"
      echo "4. Change RPC"
      echo "5. Stop Service"
      echo "6. Create EVM Tx Bot"
      echo "7. View EVM Tx Logs"
      echo "0. Update Command"
      read -p "Please input (0-7): " OPTION

      case $OPTION in
          1) roll_back ;;
          2) restart ;;
          3) logs ;;
          4) change_rpc ;;
          5) stop_service ;;
          6) createEvmTxBot ;;
          7) txLogs ;;
          0) update_command ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu