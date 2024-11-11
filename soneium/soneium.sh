#!/bin/bash


function update_script(){
  wget -O soneium.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/refs/heads/main/soneium/soneium.sh && chmod +x soneium.sh && ./soneium.sh
}




function install_dependencies(){
  sudo apt install ufw
  sudo ufw allow 9545
}


function install(){
  install_dependencies

  VPS_IP=$(hostname -I | awk '{print $1}')
  read -p "Enter Private Key : " PRIVATE_KEY

  # Pull repo
  git clone https://github.com/Soneium/soneium-node.git
  cd soneium-node/minato

  # Add Jwt file
  echo "$PRIVATE_KEY" > jwt.txt


  # Update .env values
  cp sample.env .env
  sed -i "s|L1_URL=.*|L1_URL=https://ethereum-sepolia-rpc.publicnode.com|" .env
  sed -i "s|L1_BEACON=.*|L1_BEACON=https://ethereum-sepolia-beacon-api.publicnode.com|" .env 
  sed -i "s|P2P_ADVERTISE_IP=.*|P2P_ADVERTISE_IP=$VPS_IP|" .env

  # Replace IP in docker-compose.yml
  sed -i "s|--nat=extip:<your_node_public_ip>|--nat=extip:$VPS_IP|" docker-compose.yml

  # Start Node
  docker-compose up -d

}

function view_logs(){
  cd soneium-node/minato
  docker-compose logs -f op-node-minato
}

function restart_node(){
  cd soneium-node/minato
  docker-compose down
  docker-compose up -d
}

function stop_node(){
  cd soneium-node/minato
  docker-compose down
}



function main_menu() {
  while true; do
      clear
      echo "Please choose the command to execute:"
      echo "1. Install"
      echo "2. View Logs"
      echo "3. Restart Node"
      echo "4. Stop Node"
      echo "0. Update Command"
      read -p "Please input (0-4): " OPTION

      case $OPTION in
          1) install ;;
          2) view_logs ;;
          3) restart_node ;;
          4) stop_node ;;
          0) update_script ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu