#!/bin/bash

service_name="stationd"


function monitor_multi_string_errors() {
echo "Script started and it will restart $service_name if needed..."
# Restart the service if logs contains the following strings
error_strings=("Failed to get transaction by hash: not found" "Failed to Transact Verify pod" "Switchyard client connection error")
restart_delay=120  # Restart delay in seconds (2 minutes)

  while true; do
      # Get the last 5 lines of the service logs
      logs=$(journalctl -u "$service_name" --no-pager | tail -n 5)

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
}

function monitor_gas_used_error() {
  gas_string="with gas used"
  rollback_delay=180  # Rollback delay in seconds (3 minutes)

  echo "Script started and it will rollback $service_name if needed..."
  while true; do
    # Get the last 10 lines of service logs
    logs=$(systemctl status "$service_name" --no-pager | tail -n 10)

    # Check for both error and gas used strings
    if [[ "$logs" =~ $gas_string ]]; then
      echo "Found error and gas used in logs, stopping $service_name..."
      systemctl stop "$service_name"
      cd ~/tracks

      echo "Service $service_name stopped, starting rollback..."
      go run cmd/main.go rollback
      go run cmd/main.go rollback
      go run cmd/main.go rollback
      echo "Rollback completed, starting $service_name..."
      systemctl start "$service_name"
      echo "Service $service_name started"
    fi

    # Sleep for the rollback delay
    sleep "$rollback_delay"
  done
}

# Run both functions in the background
monitor_multi_string_errors &
monitor_gas_used_error &
 
# Wait for both background processes to finish
wait
