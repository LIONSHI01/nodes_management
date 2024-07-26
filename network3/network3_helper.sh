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
  


  mkdir network3
  cd network3


  # Write docker-compose.yml
  tee .docker-compose.yml > /dev/null <<EOF
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
  wget -O networ3_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/network3/networ3_helper.sh && chmod +x networ3_helper.sh && ./networ3_helper.sh
}

function main_menu() {
  while true; do
      clear
      echo "Please choose the command to execute:"
      echo "1. Install"
      echo "2. View Logs"
      echo "3. Restart Node"
      echo "4. Delete Node"
      echo "0. Update Command"
      read -p "Please input (0-4): " OPTION

      case $OPTION in
          1) install ;;
          2) view_logs ;;
          3) restart_service ;;
          4) delete_service ;;
          0) update_script ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu