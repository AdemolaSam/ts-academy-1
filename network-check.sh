#!/usr/bin/env bash
# network-check.sh <hostname-or-ip> [port]
# Resolves host, checks basic connectivity, shows interfaces, optionally checks a TCP port.
# Exit 0: host resolved successfully
# Exit 1: host could not be resolved (but input was valid)
# Exit 2: invalid input (missing host, bad port)

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/network-check.log"
mkdir -p "$LOG_DIR"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

usage() {
    echo "Usage: $0 <hostname-or-ip> [port]" >&2
}

HOST="${1:-}"
PORT="${2:-}"

if [[ -z "$HOST" ]]; then
    echo "Error: host argument is required" >&2
    usage
    log "FAILED: missing host argument"
    exit 2
fi

if [[ -n "$PORT" ]]; then
    if ! [[ "$PORT" =~ ^[0-9]+$ ]] || (( PORT < 1 || PORT > 65535 )); then
        echo "Error: port must be an integer between 1 and 65535, got '$PORT'" >&2
        log "FAILED: invalid port '$PORT' for host '$HOST'"
        exit 2
    fi
fi

echo "===== Network Check: $HOST ====="

# --- Resolution ---
RESOLVED=""
if command -v getent >/dev/null 2>&1; then
    RESOLVED=$(getent hosts "$HOST" 2>/dev/null | awk '{print $1}' | head -n1)
fi
if [[ -z "$RESOLVED" ]] && command -v python3 >/dev/null 2>&1; then
    RESOLVED=$(python3 -c "import socket,sys
try:
    print(socket.gethostbyname('$HOST'))
except Exception:
    sys.exit(1)" 2>/dev/null)
fi

if [[ -z "$RESOLVED" ]]; then
    echo "Resolution      : FAILED to resolve '$HOST'"
    log "RESOLVE_FAILED: host='$HOST'"
    RESOLVE_OK=1
else
    echo "Resolution      : $HOST -> $RESOLVED"
    log "RESOLVE_OK: host='$HOST' address='$RESOLVED'"
    RESOLVE_OK=0
fi

# --- Basic connectivity ---
echo
echo "----- Connectivity (ping) -----"
if ping -c 1 -W 2 "$HOST" >/dev/null 2>&1; then
    echo "Ping            : reachable"
    log "PING_OK: host='$HOST'"
else
    echo "Ping            : unreachable"
    log "PING_FAILED: host='$HOST'"
fi

# --- Interfaces ---
echo
echo "----- Network Interfaces -----"
if command -v ip >/dev/null 2>&1; then
    ip -brief addr show 2>/dev/null || ip addr show
elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig
else
    echo "No interface tool (ip/ifconfig) available"
fi

# --- Optional port check ---
if [[ -n "$PORT" ]]; then
    echo
    echo "----- Port Check: $PORT -----"
    if timeout 2 bash -c "cat < /dev/null > /dev/tcp/$HOST/$PORT" 2>/dev/null; then
        echo "Port $PORT         : open"
        log "PORT_OPEN: host='$HOST' port=$PORT"
    else
        echo "Port $PORT         : closed or unreachable"
        log "PORT_CLOSED: host='$HOST' port=$PORT"
    fi
fi

exit "$RESOLVE_OK"
