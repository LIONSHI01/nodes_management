#!/bin/bash

function roll_back(){
  sudo systemctl stop stationd
  cd $HOME/tracks
  go run cmd/main.go rollback
  go run cmd/main.go rollback
  go run cmd/main.go rollback
  sudo systemctl restart stationd
}

function logs(){
  sudo journalctl -u stationd -f -o cat
}

function restart(){
  sudo journalctl -u stationd -f -o cat
}

function main_menu() {
  while true; do
      clear
      echo "Please choose the command to execute:"
      echo "1. Roll Back"
      echo "2. Restart Service"
      echo "3. View Logs"
      read -p "Please input (1-2): " OPTION

      case $OPTION in
          1) roll_back ;;
          2) logs ;;
          3) restart ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu