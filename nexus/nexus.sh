#!/bin/bash

function install_dependencies(){
  sudo apt update && sudo apt upgrade -y
  sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev  -y
}

function install_rust(){
  sudo curl https://sh.rustup.rs -sSf | sh
  source $HOME/.cargo/env
  export PATH="$HOME/.cargo/bin:$PATH"
  rustup update
  rustc --version
}

function install_screen(){
  apt install screen
}

function create_nexus_screen(){
  screen -S nexus
  curl https://cli.nexus.xyz/install.sh | sh
}

function open_nexus_screen(){
  screen -r nexus
}

function update_script(){
  wget -O nexus.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/refs/heads/main/nexus/nexus.sh && chmod +x nexus.sh && ./nexus.sh
}

 

function install_node(){
  install_dependencies
  install_rust
  install_screen
  create_nexus_screen
}


function check_prover_id(){
  curl https://cli.nexus.xyz/install.sh | sh
}

function main_menu() {
  while true; do
      clear
      echo "Please choose the command to execute:"
      echo "1. Install Node"
      echo "2. Check Prover Id"
      echo "3. Open Nexus Screen"
      read -p "Please input (1-2): " OPTION

      case $OPTION in
          1) install_node ;;
          2) check_prover_id ;;
          3) open_nexus_screen ;;
          9) update_script ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu