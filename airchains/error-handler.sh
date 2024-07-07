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
  cd
  vim /root/.tracks/config/sequencer.toml
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
      read -p "Please input (1-2): " OPTION

      case $OPTION in
          1) roll_back ;;
          2) restart ;;
          3) logs ;;
          4) change_rpc ;;
          5) stop_service ;;
          0) update_command ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu