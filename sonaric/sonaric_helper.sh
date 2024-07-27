#!/bin/bash

 

# function update_script(){
#   wget -O network3_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/network3/network3_helper.sh && chmod +x network3_helper.sh && ./network3_helper.sh
# }

function private_key(){
  cat $HOME/network3/wireguard/utun.key
}

function connect_node_link(){
  VPS_IP=$(hostname -I | awk '{print $1}')
  echo http://account.network3.ai:8080/main?o=$VPS_IP:8080
}


function node_info(){
  sonaric node-info
}


function main_menu() {
  while true; do
      clear
      echo "Please choose the command to execute:"
      echo "1. info"
      echo "0. Update Command"
      read -p "Please input (0-4): " OPTION

      case $OPTION in
          1) node_info ;;
          0) update_script ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu