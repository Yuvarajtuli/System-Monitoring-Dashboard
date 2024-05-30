#!/bin/bash
# Get the current date and time
current_date_time=$(date +"%Y-%m-%d %H:%M:%S")

# Get CPU usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

# Get Memory usage
memory_usage=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }')

# Get total memory in kilobytes
total_memory=$(free -k | awk '/^Mem:/{print $2}')

# Get used memory in kilobytes
used_memory=$(free -k | awk '/^Mem:/{print $3}')

# Get free memory in kilobytes
free_memory=$(free -k | awk '/^Mem:/{print $4}')


# Get Disk usage
disk_usage=$(df -h | awk '$NF=="/"{printf "%s", $5}')

# Get Network usage (received and transmitted bytes)
network_usage=$(ip -s link show eth0 | awk '/RX:/{rx=$2" "$3} /TX:/{tx=$2" "$3} END{print "RX bytes",rx,"TX bytes",tx}')

# Output the results in JSON format
metrics="{
    \"cpu_usage\": $cpu_usage, 
    \"memory_usage\": $memory_usage, 
    \"total_memory\": $total_memory, 
    \"used_memory\": $used_memory, 
    \"free_memory\": $free_memory, 
    \"disk_usage\": \"$disk_usage\", 
    \"network_usage\": \"$network_usage\" , 
    \"Current Date and Time\": \"$current_date_time\"
    }"

# Save the metrics to a JSON file
echo $metrics > data/metrics.json
