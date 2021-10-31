#!/bin/bash
# check memory usage and print warning
mem_total=$(free -m | sed -n '2p' | awk '{print $2}')
mem_used=$(free -m | sed -n '2p' | awk '{print $3}')
mem_free=$(free -m | sed -n '2p' | awk '{print $4}')

used_rate=$(echo "scale=2; $mem_used/$mem_total*100" | bc | awk '{printf "%.0f",$1}')
free_rate=$(echo "scale=2; $mem_free/$mem_total*100" | bc | awk '{printf "%.0f",$1}')

curr_time=$(date +"%Y-%m-%d %H:%M:%S %A")

echo ""

echo -e "Memory usage rate: $used_rate%"
echo -e "Memory free  rate: $free_rate%"

if [ $used_rate -gt 1 ]
then
echo -e "\033[31mWarning: usage of memory use is $used_rate%\033[0m"
fi

