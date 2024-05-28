#!/bin/bash

# wait-for-it.sh
# Usage: wait-for-it.sh host:port [-s] [-t timeout] [-- command args]
# 
# Waits for the given host:port to become available before executing command.

# Extract host and port from the first argument
hostport=${1}
shift
host=$(echo ${hostport} | awk -F: '{print $1}')
port=$(echo ${hostport} | awk -F: '{print $2}')

# Default timeout is 120 seconds
timeout=120

# Default retry interval is 5 seconds
retry_interval=5

# Default maximum retries
max_retries=5

# Parse optional arguments
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -s)
        silent="-q"
        shift
        ;;
        -t)
        timeout="$2"
        shift
        shift
        ;;
        --)
        shift
        break
        ;;
        *)
        # Unknown option
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
done

# Wait until the timeout is reached or the port is open
retries=0
while [ $retries -lt $max_retries ]
do
    echo "Waiting for TimescaleDB to be ready... (Attempt $((retries+1)) of $max_retries)"
    if nc ${silent} -z ${host} ${port}; then
        echo "TimescaleDB is ready!"
        break
    else
        sleep $retry_interval
        retries=$((retries+1))
    fi
done

if [ $retries -eq $max_retries ]; then
    echo "Timed out waiting for TimescaleDB to become ready"
    exit 1
fi

# Execute the remaining command if provided
if [ $# -gt 0 ]; then
    exec "$@"
fi
