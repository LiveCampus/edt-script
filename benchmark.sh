#!/bin/bash

./e1.sh &

pid=$!
result_cpu=0
result_mem=0
result_diskr=0
result_diskw=0
while ps -p $pid > /dev/null; do
    cpu_usage=$(ps -p $pid -o %cpu | tail -n 1)
    if (( $(echo "$cpu_usage > $result_cpu" | bc -l) )); then
        result_cpu=$cpu_usage
    fi

    mem_usage=$(ps -p $pid -o %mem | tail -n 1)
    if (( $(echo "$mem_usage > $result_mem" | bc -l) )); then
        result_mem=$mem_usage
    fi

    disk_usage=$(sudo iotop -bn1 -p $pid | tail -n 4 | head -n 1)
    disk_r=$(echo $disk_usage | awk '{ print $5 }')
    if (( $(echo "$disk_r > $result_diskr" | bc -l) )); then
        result_diskr=$disk_r
    fi
    disk_w=$(echo $disk_usage | awk '{ print $12 }')
    if (( $(echo "$disk_w > $result_diskw" | bc -l) )); then
        result_diskw=$disk_w
    fi
done

echo "CPU usage: $result_cpu%"
echo "MEM usage: $result_mem%"
echo "DISK READ usage: $disk_r B/s"
echo "DISK WRITE usage: $disk_w B/s"
