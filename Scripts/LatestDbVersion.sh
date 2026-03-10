#!/bin/bash
# Gets the latest database version for the given purpose

purpose="${1:-Sim_best}"

last_line=$(dbTool print-version --purpose "$purpose" | tail -1)

vmaj=$(echo "$last_line" | awk '{print $5}')
vmin=$(echo "$last_line" | awk '{print $6}')
echo "v${vmaj}_${vmin}"
