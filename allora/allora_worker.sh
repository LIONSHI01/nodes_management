#!/bin/bash

function install_node(){
    # Collect Config Info
    read -p "Please input WORKER NAME: " WORKER_NAME
    read -p "Please input TOPIC ID: " TOPIC_ID

    apt install pip
    pip install allocmd --upgrade
    allocmd generate worker --name $WORKER_NAME --topic $TOPIC_ID --env dev
    cd $WORKER_NAME/worker

    echo "=========================="
    echo "Node Installation complete"
    echo "=========================="
}


function inspect_logs(){
    cd allora-chain
    docker compose logs -f
}

function check_block_status(){
    curl -s http://localhost:26657/status | jq .
}

function uninstall_node(){
    cd
    rm -r allora-chain
    echo "=========================="
    echo "Uninstallation complete"
    echo "=========================="
}

function main_menu() {
  while true; do
      clear
      echo "Please choose the command to execute:"
      echo "1. Install Node"
      echo "2. View Logs"
      echo "3. Block Sync Staus"
      echo "4. Uninstall Node"
      read -p "Please input (1-4): " OPTION

      case $OPTION in
          1) install_node ;;
          2) inspect_logs ;;
          3) check_block_status ;;
          4) uninstall_node ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu