#!/usr/bin/env bash
# system-info.sh
# Displays hostname, user, date/time, OS, kernel, uptime, CPU, memory, cwd.
# All values are read from the running system at call time.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/system-info.log"
mkdir -p "$LOG_DIR"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log "system-info.sh: run started"

echo "===== System Information ====="
echo "Hostname        : $(hostname)"
echo "Current User    : $(whoami)"
echo "Date/Time       : $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "Operating System: $(uname -s)"

if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    echo "Distribution    : ${PRETTY_NAME:-unknown}"
fi

echo "Kernel Version  : $(uname -r)"
echo "Uptime          : $(uptime -p 2>/dev/null || uptime)"
echo

echo "----- CPU Information -----"
if command -v lscpu >/dev/null 2>&1; then
    lscpu | grep -E 'Model name|^CPU\(s\)|Thread\(s\) per core|Core\(s\) per socket'
else
    grep -m1 'model name' /proc/cpuinfo 2>/dev/null || echo "CPU model information unavailable"
    grep -c '^processor' /proc/cpuinfo 2>/dev/null | xargs -I{} echo "Logical CPUs: {}"
fi
echo

echo "----- Memory Information -----"
free -h 2>/dev/null || echo "Memory information unavailable"
echo

echo "Current Directory: $(pwd)"

log "system-info.sh: run completed successfully"
exit 0
