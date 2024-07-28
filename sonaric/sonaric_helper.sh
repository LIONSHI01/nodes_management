#!/bin/bash

 

function update_script(){
  wget -O sonaric_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/sonaric/sonaric_helper.sh && chmod +x sonaric_helper.sh && ./sonaric_helper.sh
}

 

function backupKey(){
  VPS_IP=$(hostname -I | awk '{print $1}')
  echo "http://$VPS_IP:9999"

  python3 -m http.server 9999
  
}


function prepareBackupKey(){
  sonaric identity-export -o mysonaric.identity
}


function node_info(){
  sonaric node-info
}


function install(){
  wget https://raw.githubusercontent.com/muzammilvmx/Light-Nodes/main/SonaricNetwork/main.sh && chmod +x main.sh && ./main.sh
}

function main_menu() {
  while true; do
      clear
      echo "Please choose the command to execute:"
      echo "1. Install"
      echo "2. Info"
      echo "3. Generate Key File"
      echo "4. Backup key"
      echo "0. Update Command"
      read -p "Please input (0-4): " OPTION

      case $OPTION in
          1) install ;;
          2) node_info ;;
          3) prepareBackupKey ;;
          4) backupKey ;;
          0) update_script ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu