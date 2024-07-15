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

function main_menu() {
  while true; do
      clear
      echo "Please choose the command to execute:"
      echo "1. View Logs"
      echo "2. View Block Sync Status"
      echo "0. Update Command"
      read -p "Please input (0-8): " OPTION

      case $OPTION in
          1) view_logs ;;
          2) view_block_sync ;;
          3) restart_service ;;
          0) update_command ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu