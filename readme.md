### Download Script and Run it

# Allora_network

wget -O allora_network.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/allora/allora_install.sh && chmod +x allora_network.sh && ./allora_network.sh

# Airchains

wget -O airchains_error_handler.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/airchains/error-handler.sh && chmod +x airchains_error_handler.sh && ./airchains_error_handler.sh

# Airchains Evm Rollup

wget -O evm_install.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/airchains/evm_install.sh && chmod +x evm_install.sh && ./evm_install.sh

# Airchains Evm Error Handlers

### Failed to get transaction by hash: not found

wget -O not_found_tx_monitor.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/airchains/not_found_tx_monitor.sh && chmod +x not_found_tx_monitor.sh && nohup bash not_found_tx_monitor.sh &
