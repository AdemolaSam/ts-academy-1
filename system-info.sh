#!/bin/bash
# Displays the following:
# hostname, current user, date/time, operating system, kernel version, uptime, CPU information, memory information
# and current working directory.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/system-info.log"
mkdir -p "$LOG_DIR"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log "system-info.sh: run started"


echo ".................................................."
echo "               SYSTEM INFORMATION                 "
echo ".................................................."

# Hostname, current user, date/time, OS, kernel version, uptime,

echo "Hostname: $(hostname)"
echo "Current user: $(whoami)"
echo "Date and time: $(date +'%d-%m-%y/%H:%M:%S %Z')"
echo "OS: $(uname)"
source /etc/os-release
echo "Distribution: $PRETTY_NAME"
echo "OS version: $VERSION"
echo "Kernel version: $(uname -v)"
echo "Uptime: $(uptime -p)"


# CPU INFORMATION

echo "========================= CPU =============================="
echo "$(lscpu | grep -E "Model name|Architecture|core|thread|CPU")"

# MEMORY

echo "========================= Memory ==========================="
echo "$(free -h)"

# CURRENT WORKING DIRECTORY

echo "=============== Current Working Directory =================="
echo "Current directory: $(pwd)"

log "system-info.sh: run completed successfully"
