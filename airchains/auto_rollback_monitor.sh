service_name="stationd"
gas_string="with gas used"
restart_delay=180  # Restart delay in seconds (3 minutes)

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

  # Sleep for the restart delay
  sleep "$restart_delay"
done

