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
  echo "Updated RPC"
  
  restart

}

function check_rpc(){
  grep 'JunctionRPC = ' ~/.tracks/config/sequencer.toml
}

function stop_service(){
  sudo systemctl stop stationd
}

function restart(){
  echo "Restarting Service"
  
  sudo systemctl restart stationd

  echo "Restarted Successfully"
}

function logs(){
  sudo journalctl -u stationd -f -o cat
}

function tx_logs(){
  screen -r tx_airchains_bot
}

function fix_insufficient_gas(){
  sudo systemctl stop stationd

  # Modify Gas
  sed -i 's/gasFees := fmt.Sprintf("%damf", gas)/gasFees := fmt.Sprintf("%damf", 2*gas)/' "$HOME/tracks/junction/verifyPod.go"
  sed -i 's/gasFees := fmt.Sprintf("%damf", gas)/gasFees := fmt.Sprintf("%damf", 2*gas)/' "$HOME/tracks/junction/validateVRF.go"
  sed -i 's/gasFees := fmt.Sprintf("%damf", gas)/gasFees := fmt.Sprintf("%damf", 3*gas)/' "$HOME/tracks/junction/submitPod.go"
  
  sudo systemctl restart stationd && sudo journalctl -u stationd -f -o cat
}

function create_evm_tx_Bot(){
  cd $HOME/evm-station/ && /bin/bash ./scripts/local-keys.sh
  cat $HOME/.tracks/junction-accounts/keys/wallet.wallet.json

  cd
  mkdir airchain_evm_tx_bot
  cd airchain_evm_tx_bot
  git clone https://github.com/LIONSHI01/airchain-evm-tx-bot.git .
  npm install
  touch .env
  
  # Input Env Config
  read -p "Please input EVM Wallet Private Key: " PRIVATE_KEY
  read -p "Please input EVM Address (From): " FROM_WALLET
  read -p "Please input To Wallet Address (To): " TO_WALLET
  LOCAL_IP=$(hostname -I | awk '{print $1}')

  sudo tee .env > /dev/null << EOF

  VPS_IP=$LOCAL_IP
  PRIVATE_KEY=$PRIVATE_KEY
  FROM=$FROM_WALLET
  TO=$TO_WALLET
  
EOF

  screen -S tx_airchains_bot
}

function set_up_error_monitor(){
  git clone https://github.com/LIONSHI01/nodes_management.git
  chmod +x ~/nodes_management/airchains/errors_monitor.sh
  nohup bash ~/nodes_management/airchains/errors_monitor.sh &
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
      echo "5. Check RPC"
      echo "6. Stop Service"
      echo "7. Create EVM Tx Bot"
      echo "8. View EVM Tx Logs"
      echo "9. Fix Insufficient Gas"
      echo "10. Set up Error Monitor"
      echo "0. Update Command"
      read -p "Please input (0-8): " OPTION

      case $OPTION in
          1) roll_back ;;
          2) restart ;;
          3) logs ;;
          4) change_rpc ;;
          5) check_rpc ;;
          6) stop_service ;;
          7) create_evm_tx_Bot ;;
          8) tx_logs ;;
          9) fix_insufficient_gas ;;
          10) set_up_error_monitor ;;
          0) update_command ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu