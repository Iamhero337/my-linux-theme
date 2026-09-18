#!/usr/bin/env bash

# State file in RAM to avoid sleep delays
PREV_FILE="/dev/shm/sys_fetcher_prev"
NOW=$(date +%s%N)

# 1. Read current CPU and network counters
read -r _ u2 n2 s2 i2 io2 ir2 so2 st2 g2 gn2 <<< "$(grep '^cpu ' /proc/stat)"
read rx2 tx2 <<< "$(awk -v IGNORECASE=1 '/^ *[ew]/{rx+=$2; tx+=$10} END{print rx, tx}' /proc/net/dev)"

if [ -f "$PREV_FILE" ]; then
    read -r PREV_TIME u1 n1 s1 i1 io1 ir1 so1 st1 rx1 tx1 < "$PREV_FILE"
    DT_NS=$((NOW - PREV_TIME))
else
    DT_NS=0
fi

# Save current counters for next tick
echo "$NOW $u2 $n2 $s2 $i2 $io2 $ir2 $so2 $st2 $rx2 $tx2" > "$PREV_FILE"

# --- CPU Calculation ---
if [ -n "$u1" ] && [ "$DT_NS" -gt 300000000 ]; then
    IDLE1=$i1; TOTAL1=$((u1 + n1 + s1 + i1 + io1 + ir1 + so1 + st1))
    IDLE2=$i2; TOTAL2=$((u2 + n2 + s2 + i2 + io2 + ir2 + so2 + st2))
    DIFF_IDLE=$((IDLE2 - IDLE1))
    DIFF_TOTAL=$((TOTAL2 - TOTAL1))
    if [ "$DIFF_TOTAL" -eq 0 ]; then CPU_USAGE=0; else CPU_USAGE=$(( 100 * (DIFF_TOTAL - DIFF_IDLE) / DIFF_TOTAL )); fi
    
    # Network Bytes per second
    DT_SEC=$(awk "BEGIN {print $DT_NS / 1000000000}")
    RX_RATE=$(awk "BEGIN {printf \"%d\", ($rx2 - $rx1) / $DT_SEC}")
    TX_RATE=$(awk "BEGIN {printf \"%d\", ($tx2 - $tx1) / $DT_SEC}")
else
    CPU_USAGE=0
    RX_RATE=0
    TX_RATE=0
fi

# --- RAM Calculation ---
while IFS=":" read -r key val; do
    case "$key" in
        MemTotal) TOTAL_MEM=$(echo "$val" | awk '{print $1}') ;;
        MemAvailable) AVAIL_MEM=$(echo "$val" | awk '{print $1}') ;;
    esac
done < /proc/meminfo
USED_MEM=$((TOTAL_MEM - AVAIL_MEM))
RAM_PCT=$(( 100 * USED_MEM / TOTAL_MEM ))
RAM_GB=$(awk "BEGIN {printf \"%.1f\", $USED_MEM / 1024 / 1024}")

# --- Temperature Calculation ---
TEMP_RAW=""
for hwmon in /sys/class/hwmon/hwmon*; do
    if [ -f "$hwmon/name" ]; then
        hwmon_name=$(cat "$hwmon/name" 2>/dev/null)
        if [[ "$hwmon_name" =~ ^(coretemp|k10temp|zenpower|cpu_thermal|bcm2835_thermal)$ ]]; then
            if [ -f "$hwmon/temp1_input" ]; then
                TEMP_RAW=$(cat "$hwmon/temp1_input" 2>/dev/null)
                break
            fi
        fi
    fi
done

if [ -z "$TEMP_RAW" ]; then
    TEMP_RAW=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 45000)
fi

if [ "$TEMP_RAW" -gt 1000 ]; then
    TEMP=$((TEMP_RAW / 1000))
else
    TEMP=$TEMP_RAW
fi

# --- GPU Metrics (Cached to avoid waking GPU on every tick) ---
GPU_CACHE="/dev/shm/gpu_fetch_cache"
if [ -f "$GPU_CACHE" ] && [ $(( $(date +%s) - $(stat -c %Y "$GPU_CACHE" 2>/dev/null || echo 0) )) -lt 6 ]; then
    read -r GPU_TEMP GPU_USAGE < "$GPU_CACHE"
else
    GPU_RAW=$(nvidia-smi --query-gpu=temperature.gpu,utilization.gpu --format=csv,noheader,nounits 2>/dev/null || echo "0, 0")
    IFS=',' read -r GPU_TEMP GPU_USAGE <<< "$GPU_RAW"
    GPU_TEMP="${GPU_TEMP//[[:space:]]/}"
    GPU_USAGE="${GPU_USAGE//[[:space:]]/}"
    echo "$GPU_TEMP $GPU_USAGE" > "$GPU_CACHE"
fi

# Output: CPU|RAM_PCT|RAM_GB|TEMP|RX_RATE|TX_RATE|GPU_TEMP|GPU_USAGE
echo "$CPU_USAGE|$RAM_PCT|$RAM_GB|$TEMP|$RX_RATE|$TX_RATE|$GPU_TEMP|$GPU_USAGE"
