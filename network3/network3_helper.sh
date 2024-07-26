#!/bin/bash


function install(){
  if ! command -v docker &> /dev/null
  then
      echo "未检测到 Docker，正在安装..."
      apt-get install ca-certificates curl gnupg lsb-release -y
      
      # 安装 Docker 最新版本
      apt-get install docker.io -y
  else
      echo "Docker 已安装。"
  fi
  
  install_docker_compose

  if [ ! -d "network3" ]; then
    mkdir network3
  fi

  cd network3


  # Write docker-compose.yml
  tee docker-compose.yml > /dev/null <<EOF
version: '3.3'
services:  
  network3-01:    
    image: aron666/network3-ai    
    container_name: network3-01    
    ports:      
      - 8080:8080/tcp    
    volumes:
      # 請把 "/path/to" 改成你本機的路徑
      - /root/network3/wireguard:/usr/local/etc/wireguard    
    healthcheck:      
      test: curl -fs http://localhost:8080/ || exit 1      
      interval: 30s      
      timeout: 5s      
      retries: 5      
      start_period: 30s    
    privileged: true    
    devices:      
      - /dev/net/tun    
    cap_add:      
      - NET_ADMIN    
    restart: always

  autoheal:    
    restart: always    
    image: willfarrell/autoheal    
    container_name: autoheal    
    environment:      
      - AUTOHEAL_CONTAINER_LABEL=all    
    volumes:      
      - /var/run/docker.sock:/var/run/docker.sock
EOF

  docker-compose up -d

  view_connection_link

}

function view_connection_link(){
  echo '====== Link to connect node: ======'
  connect_node_link
  echo '==================================='

}

function view_logs(){
  docker logs network3-01
}

function restart_service(){
  cd ~/network3
  docker-compose restart 
}

function delete_service(){
  docker stop network3-01
  docker rm network3-01
  docker rmi aron666/network3-ai
  cd ~
  rm -r ~/network3/
}

function update_script(){
  wget -O network3_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/network3/network3_helper.sh && chmod +x network3_helper.sh && ./network3_helper.sh
}

function private_key(){
  cat $HOME/network3/wireguard/utun.key
}

function connect_node_link(){
  VPS_IP=$(hostname -I | awk '{print $1}')
  echo http://account.network3.ai:8080/main?o=$VPS_IP:8080
}

function install_docker_compose(){
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
}

function main_menu() {
  while true; do
      clear
      echo "Please choose the command to execute:"
      echo "1. Install"
      echo "2. View Logs"
      echo "3. Restart Node"
      echo "4. Node Privatekey"
      echo "5. Delete Node"
      echo "0. Update Command"
      read -p "Please input (0-4): " OPTION

      case $OPTION in
          1) install ;;
          2) view_logs ;;
          3) restart_service ;;
          4) private_key ;;
          5) delete_service ;;
          0) update_script ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu