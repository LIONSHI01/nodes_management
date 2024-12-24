#!/bin/bash
# Log files
LOG_FILE="miner.log"
NODE_DIR="/root/initverse"
WALLET_ADDRESS_PATH="/root/initverse/wallet.txt" 

WALLET_ADDRESS_RECORD=$(cat "$WALLET_ADDRESS_PATH")
echo $WALLET_ADDRESS_RECORD

# Graceful exit function
cleanup() {
   echo "正在关闭挖矿程序..." | tee -a "$LOG_FILE"
   killall iniminer-linux-x64
   exit 0
}
# Capture the exit signal
trap cleanup SIGINT SIGTERM
# System resource monitoring function
check_resources() {
   CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
   MEM_FREE=$(free -m | awk 'NR==2{print $4}')
   echo "CPU使用率: $CPU_USAGE% | 可用内存: ${MEM_FREE}MB" | tee -a "$LOG_FILE"
   # If the memory is less than 500MB, log a warning
   if [ "$MEM_FREE" -lt 500 ]; then
       echo "警告: 内存不足" | tee -a "$LOG_FILE"
   fi
}
while true; do
   date "+%Y-%m-%d %H:%M:%S 开始挖矿..." | tee -a "$LOG_FILE"
   check_resources
   ./iniminer-linux-x64 --pool stratum+tcp://$WALLET_ADDRESS_RECORD.Worker001@pool-core-testnet.inichain.com:32672 --cpu-devices 1
   EXIT_CODE=$?
   date "+%Y-%m-%d %H:%M:%S 挖矿程序退出，状态码: $EXIT_CODE" | tee -a "$LOG_FILE"
   echo "5秒后重启程序..." | tee -a "$LOG_FILE"
   sleep 5
done