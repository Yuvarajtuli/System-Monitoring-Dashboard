#!/bin/bash
JSON_FILE="data/system_jobs.json"

# Check if the JSON file exists, if not create it
if [ ! -f "$JSON_FILE" ]; then
  touch "$JSON_FILE"
  echo "[]" > "$JSON_FILE" # Initialize JSON file with an empty array
fi

# Function to log the system status
log_system_status() {
  TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
  
  # Capture top processes by CPU usage
  CPU_USAGE=$(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 11 | awk 'NR>1 {print "{\"pid\":" $1 ", \"ppid\":" $2 ", \"cmd\":\"" $3 "\", \"mem\":" $4 ", \"cpu\":" $5 "}"}')
  
  # Capture top processes by memory usage
  MEM_USAGE=$(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 11 | awk 'NR>1 {print "{\"pid\":" $1 ", \"ppid\":" $2 ", \"cmd\":\"" $3 "\", \"mem\":" $4 ", \"cpu\":" $5 "}"}')
  
  # Capture overall system memory usage
  MEM_TOTAL=$(free -h | awk '/Mem:/ {print "{\"total\":\"" $2 "\", \"used\":\"" $3 "\", \"free\":\"" $4 "\", \"shared\":\"" $5 "\", \"buff/cache\":\"" $6 "\", \"available\":\"" $7 "\"}"}')
  
  # Capture overall system CPU usage
  CPU_TOTAL=$(top -bn1 | grep "Cpu(s)" | awk '{print "{\"us\":" $2 ", \"sy\":" $4 ", \"ni\":" $6 ", \"id\":" $8 ", \"wa\":" $10 ", \"hi\":" $12 ", \"si\":" $14 ", \"st\":" $16 "}"}')
  
  # Capture disk usage
  DISK_USAGE=$(df -h | awk 'NR>1 {print "{\"filesystem\":\"" $1 "\", \"size\":\"" $2 "\", \"used\":\"" $3 "\", \"avail\":\"" $4 "\", \"use%\":\"" $5 "\", \"mounted_on\":\"" $6 "\"}"}')

  # Combine all captured data into a single JSON object
STATUS=$(jq -n \
  --arg timestamp "$TIMESTAMP" \
  --arg cpu_usage "$CPU_USAGE" \
  --arg mem_usage "$MEM_USAGE" \
  --arg mem_total "$MEM_TOTAL" \
  --arg cpu_total "$CPU_TOTAL" \
  --arg disk_usage "$DISK_USAGE" \
  '{ 
    timestamp: $timestamp,
    cpu_usage: $cpu_usage,
    mem_usage: $mem_usage,
    mem_total: $mem_total,
    cpu_total: $cpu_total,
    disk_usage: $disk_usage
  }')

  # Check if the generated JSON is valid
  echo "$STATUS" | jq '.' >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "$STATUS" | jq '.' > "$JSON_FILE"
  else
    echo "Error: Invalid JSON generated"
  fi
}

log_system_status
