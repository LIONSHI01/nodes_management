#!/bin/bash


function update_script(){
  wget -O soneium.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/refs/heads/main/soneium/soneium.sh && chmod +x soneium.sh && ./soneium.sh
}




function install_dependencies(){
  sudo apt install ufw
  sudo ufw allow 9546
  sudo ufw allow 9547
}


function install(){
  install_dependencies

  read -p "Enter Sepolia RPC : " SEPOLIA_RPC

  # Pull repo
  git clone https://github.com/Uniswap/unichain-node.git
  cd unichain-node


  # Update .env.sepolia values
  sed -i "s|OP_NODE_L1_BEACON=.*|OP_NODE_L1_BEACON=https://ethereum-sepolia-beacon-api.publicnode.com|" .env.sepolia


  # Update docker-compose.yml
  update_docker_compose_file


  
  # Start Node
  docker-compose up -d

}

function update_docker_compose_file(){
  rm docker-compose.yml
  tee docker-compose.yml > /dev/null <<EOF

  volumes:
  shared:

services:
  execution-client:
    image: us-docker.pkg.dev/oplabs-tools-artifacts/images/op-geth:v1.101408.0
    env_file:
      - .env
      - .env.sepolia
    ports:
      - 30303:30303/udp
      - 30303:30303/tcp
      - 8547:8545/tcp
      - 8548:8546/tcp
    volumes:
      - ${HOST_DATA_DIR}:/data
      - shared:/shared
      - ./chainconfig:/chainconfig
      - ./op-geth-entrypoint.sh:/entrypoint.sh
    healthcheck:
      start_interval: 5s
      start_period: 240s
      test: wget --no-verbose --tries=1 --spider http://localhost:8547 || exit 1
    restart: always
    entrypoint: /entrypoint.sh

  op-node:
    image: us-docker.pkg.dev/oplabs-tools-artifacts/images/op-node:v1.9.1
    env_file:
      - .env
      - .env.sepolia
    ports:
      - 9222:9222/udp
      - 9222:9222/tcp
      - 9546:9545/tcp
    volumes:
      - ${HOST_NODE_DATA_DIR}:/data
      - shared:/shared
      - ./chainconfig:/chainconfig
    healthcheck:
      start_interval: 5s
      start_period: 240s
      test: wget --no-verbose --tries=1 --spider http://localhost:9547 || exit 1
    depends_on:
      execution-client:
        condition: service_healthy
    restart: always


EOF
}

function view_logs(){
  cd unichain-node
  docker-compose logs -f
}

function restart_node(){
  cd cd unichain-node
  docker-compose down
  docker-compose up -d
}

function stop_node(){
  cd cd unichain-node
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