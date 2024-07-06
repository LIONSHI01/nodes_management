#!/bin/bash

function install_node(){
    git clone https://github.com/allora-network/allora-chain.git
    cd allora-chain
    docker compose pull
    docker compose up -d
    echo "=========================="
    echo "Node Installation complete"
    echo "=========================="
}


function inspect_logs(){
    cd allora-chain
    docker compose logs -f
}

function main_menu() {
  while true; do
      clear
      echo "Please choose the command to execute:"
      echo "1. Install Node"
      echo "2. View Logs"
      read -p "Please input (1-2): " OPTION

      case $OPTION in
          1) install_node ;;
          2) inspect_logs ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu