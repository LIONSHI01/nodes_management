### Download Script and Run it

# VPS Initiator

wget -O vps_starter.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/tools/tools.sh && chmod +x vps_starter.sh && ./vps_starter.sh

# Allora_network

wget -O allora_network.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/allora/allora_install.sh && chmod +x allora_network.sh && ./allora_network.sh

# Airchains

### Errors Handler

wget -O airchains_error_handler.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/airchains/error-handler.sh && chmod +x airchains_error_handler.sh && ./airchains_error_handler.sh

# Airchains Evm Rollup Installation

wget -O evm_install.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/airchains/evm_install.sh && chmod +x evm_install.sh && ./evm_install.sh

# Airchains Evm Error Handlers

### Failed to get transaction by hash: not found

wget -O not_found_tx_monitor.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/airchains/not_found_tx_monitor.sh && chmod +x not_found_tx_monitor.sh && nohup bash not_found_tx_monitor.sh &

### Airchains RPC Helper

wget -O rpc_helper_airchain.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/airchains/airchain_rpc_helper.sh && chmod +x rpc_helper_airchain.sh && ./rpc_helper_airchain.sh

# Chasm Node

wget -O chasm_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/chasm/chasm_helper.sh && chmod +x chasm_helper.sh && ./chasm_helper.sh

# Network3

wget -O network3_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/network3/network3_helper.sh && chmod +x network3_helper.sh && ./network3_helper.sh

# Sonaric

wget -O sonaric_helper.sh https://raw.githubusercontent.com/LIONSHI01/nodes_management/main/sonaric/sonaric_helper.sh && chmod +x sonaric_helper.sh && ./sonaric_helper.sh
