#!/bin/bash


function install(){
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  
  # Open port
  sudo ufw allow 3001
  sudo ufw allow 3001/tcp

  # Get Webhook url
  ip=$(curl -s4 ifconfig.me/ip)
  WEBHOOK_URL=http://$ip:3001/


  # Fill in Vars in .env
  read -p "Input SCOUT_UID : " SCOUT_UID
  read -p "Input WEBHOOK_API_KEY : " WEBHOOK_API_KEY
  read -p "Input GROQ_API_KEY : " GROQ_API_KEY
  read -p "Input OPENROUTER_API_KEY : " OPENROUTER_API_KEY


  # Write .env
  cd ~
  mkdir scout
  cd scout
  tee .env > /dev/null <<EOF
  PORT=3001
  LOGGER_LEVEL=debug

  # Chasm
  ORCHESTRATOR_URL=https://orchestrator.chasm.net
  SCOUT_NAME=myscout
  SCOUT_UID=$SCOUT_UID
  WEBHOOK_API_KEY=$WEBHOOK_API_KEY
  # Scout Webhook Url, update based on your server's IP and Port
  # e.g. http://123.123.123.123:3001/
  WEBHOOK_URL=$WEBHOOK_URL

  # Chosen Provider (groq, openai)
  PROVIDERS=groq
  MODEL=gemma2-9b-it
  GROQ_API_KEY=$GROQ_API_KEY

  # Optional
  OPENROUTER_API_KEY=$OPENROUTER_API_KEY
  OPENAI_API_KEY=$OPENAI_API_KEY
EOF

# Start Scout 
  docker pull johnsonchasm/chasm-scout
  docker run -d --restart=always --env-file ./.env -p 3001:3001 --name scout johnsonchasm/chasm-scout

# Test Service
  curl localhost:3001

# Test LLM

source ./.env
curl -X POST \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $WEBHOOK_API_KEY" \
     -d '{"body":"{\"model\":\"gemma2-9b-it\",\"messages\":[{\"role\":\"system\",\"content\":\"You are a helpful assistant.\"}]}"}' \
     $WEBHOOK_URL

}

function view_logs(){
  docker logs scout -f --tail 100
}

function restart_service(){
  cd ~/scout
  docker stop scout
  docker rm scout
  docker run -d --restart=always --env-file ./.env -p 3001:3001 --name scout johnsonchasm/chasm-scout
}

function delete_service(){
  docker stop scout
  docker rm scout
  docker rmi johnsonchasm/chasm-scout
  cd ~
  rm -r ~/scout/
}

function update_script(){
  wget -O chasm_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/chasm/chasm_helper.sh && chmod +x chasm_helper.sh && ./chasm_helper.sh
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