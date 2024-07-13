#!/bin/bash

function update_command(){
  wget -O airchains_error_handler.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/airchains/error-handler.sh && chmod +x airchains_error_handler.sh && ./airchains_error_handler.sh
}


function main_menu() {
  while true; do
      clear
      echo "Please choose the command to execute:"
      echo "1. View Logs"
      echo "2. View Block Height"
      echo "0. Update Command"
      read -p "Please input (0-8): " OPTION

      case $OPTION in
          1) view_logs ;;
          2) view_block_height ;;
          0) update_command ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu