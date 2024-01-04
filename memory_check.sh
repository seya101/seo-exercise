#!/bin/bash

# Initialize default values
CRITICAL_THRESHOLD=""
WARNING_THRESHOLD=""
EMAIL=""

# Function to display script usage
usage() {
    echo "Usage: $0 -c <critical_threshold> -w <warning_threshold> -e <email>"
    exit 1
}

# Parsing options
while getopts "c:w:e:" opt; do
    case $opt in
        c) CRITICAL_THRESHOLD=$OPTARG ;;
        w) WARNING_THRESHOLD=$OPTARG ;;
        e) EMAIL=$OPTARG ;;
        *) usage ;;
    esac
done

# Check if parameters are missing
if [ -z "$CRITICAL_THRESHOLD" ] || [ -z "$WARNING_THRESHOLD" ] || [ -z "$EMAIL" ]; then
    usage
fi

# Check if critical threshold is greater than warning threshold
if [ "$CRITICAL_THRESHOLD" -le "$WARNING_THRESHOLD" ]; then
    echo "Critical threshold must be greater than warning threshold."
    usage
fi

# Get total memory
TOTAL_MEMORY=$(free | awk '/Mem:/ {print $2}')
MEMORY_USAGE=$(free | awk '/Mem:/ {printf "%.2f", $3/$2 * 100}')

# Check memory thresholds
if (( $(echo "$MEMORY_USAGE >= $CRITICAL_THRESHOLD" | bc -l) )); then
    echo "Memory usage critical: $MEMORY_USAGE%"
    if [ ! -z "$EMAIL" ]; then
        # Send an email with top 10 processes consuming memory
        SUBJECT=$(date +"%Y%m%d %H:%M memory check - critical")
        BODY=$(ps aux --sort -rss | head -n 11)
        echo "$BODY" | mail -s "$SUBJECT" "$EMAIL"
        echo "Email sent to $EMAIL"
    fi
    exit 2
elif (( $(echo "$MEMORY_USAGE >= $WARNING_THRESHOLD" | bc -l) )); then
    echo "Memory usage warning: $MEMORY_USAGE%"
    exit 1
else
    echo "Memory usage normal: $MEMORY_USAGE%"
    exit 0
fi
