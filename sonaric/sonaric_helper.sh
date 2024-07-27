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


function main_menu() {
  while true; do
      clear
      echo "Please choose the command to execute:"
      echo "1. Info"
      echo "3. Prepare Backup Key"
      echo "2. Backup key"
      echo "0. Update Command"
      read -p "Please input (0-4): " OPTION

      case $OPTION in
          1) node_info ;;
          2) prepareBackupKey ;;
          3) backupKey ;;
          0) update_script ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu