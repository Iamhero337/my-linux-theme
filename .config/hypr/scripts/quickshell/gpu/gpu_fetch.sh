#!/usr/bin/env bash
MODE=$(sudo envycontrol -q 2>/dev/null || echo "hybrid")
MODE="${MODE//[[:space:]]/}"

PROFILE=$(powerprofilesctl get 2>/dev/null || echo "balanced")
PROFILE="${PROFILE//[[:space:]]/}"

GPU_INFO=$(nvidia-smi --query-gpu=name,memory.total,memory.used,temperature.gpu,utilization.gpu,power.draw,driver_version --format=csv,noheader,nounits 2>/dev/null || echo "NVIDIA RTX 3050, 6144, 0, 50, 0, 0, 580.0")

echo "$MODE|$PROFILE|$GPU_INFO"
