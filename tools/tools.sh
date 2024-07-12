#!/bin/bash

function install_docker(){
# 检查 Docker 是否已安装
  if ! command -v docker &> /dev/null
  then
      echo "未检测到 Docker，正在安装..."
      apt-get install ca-certificates curl gnupg lsb-release -y
      
      # 安装 Docker 最新版本
      apt-get install docker.io -y
  else
      echo "Docker 已安装。"
  fi
}

function vps_starter(){
  apt-get update && apt-get upgrade
  apt install screen
  apt install btop
  apt install ncdu
  install_docker
}

 


function main_menu() {
  while true; do
      clear
      echo "Please choose the command to execute:"
      echo "1. Install Basic Dependencies"
      read -p "Please input (1-2): " OPTION

      case $OPTION in
          1) vps_starter ;;
          *) echo "Invalid Choice." ;;
      esac
      echo "Press any key back to menu..."
      read -n 1
  done
}

main_menu