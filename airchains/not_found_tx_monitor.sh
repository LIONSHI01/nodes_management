#!/bin/bash

service_name="stationd"
not_found_tx_string="Failed to get transaction by hash: not found"
restart_delay=180  # Restart delay in seconds (3 minutes)

echo "Script started and it will restart $service_name if needed..."

while true; do
    # Get the last 10 lines of service logs
  logs=$(systemctl status "$service_name" --no-pager | tail -n 1)

    # Check for both error and gas used strings
  if [[ "$logs" =~ $not_found_tx_string ]]; then
    echo "Found error and gas used in logs, stopping $service_name..."
    systemctl restart "$service_name"
    echo "Service $service_name started"

  fi

  # Sleep for the restart delay
  sleep "$restart_delay"