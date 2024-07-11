#!/bin/bash

service_name="stationd"
error_strings=("Failed to get transaction by hash: not found" "Failed to Transact Verify pod" "Switchyard client connection error")
restart_delay=120  # Restart delay in seconds (3 minutes)

echo "Script started and it will restart $service_name if needed..."

while true; do
    # Get the last 5 line of the service logs
    logs=$(journalctl -u "$service_name" -n 1 --no-pager | tail -n 5)

    # Check for each error string in the logs
    for error_string in "${error_strings[@]}"; do
        if [[ "$logs" == *"$error_string"* ]]; then
            echo "Found error string '$error_string' in logs, restarting $service_name..."
            systemctl restart "$service_name"
            echo "Service $service_name restarted"
            break
        fi
    done

    # Sleep for the restart delay
    sleep "$restart_delay"
done
