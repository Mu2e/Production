#!/bin/bash
# creates fcl appending DbService database configuration
# Usage: ./Production/Scripts/addDatabase.sh <input fcl path> <output fcl path> [db purpose] [db version]

input_path=${1}
output_path=${2}

if [ -z "$3" ]; then
    purpose="Sim_best"
    echo "No purpose provided, using default: $purpose"
else
    purpose="$3"
fi
if [ -z "$4" ]; then
    dbversion=$(Production/Scripts/LatestDbVersion.sh "$purpose")
    echo "No version provided, using latest: $dbversion"
else
    dbversion="$4"
fi

cat "$input_path" > "$output_path"
cat >> "$output_path" <<EOF
services.DbService.purpose: $purpose
services.DbService.version: $dbversion
services.DbService.verbose: 2
EOF
