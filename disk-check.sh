#!/usr/bin/env bash
# disk-check.sh <threshold> [path]
# Exit 0: usage below threshold
# Exit 1: usage at/above threshold
# Exit 2: invalid input

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/disk-check.log"
mkdir -p "$LOG_DIR"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

usage() {
    echo "Usage: $0 <threshold 1-100> [path]" >&2
}

THRESHOLD="${1:-}"
CHECK_PATH="${2:-/}"

if [[ -z "$THRESHOLD" ]]; then
    echo "Error: threshold is required" >&2
    usage
    log "FAILED: missing threshold argument"
    exit 2
fi

if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]]; then
    echo "Error: threshold must be a positive integer, got '$THRESHOLD'" >&2
    log "FAILED: non-numeric threshold '$THRESHOLD'"
    exit 2
fi

if (( THRESHOLD < 1 || THRESHOLD > 100 )); then
    echo "Error: threshold must be between 1 and 100, got '$THRESHOLD'" >&2
    log "FAILED: threshold out of range '$THRESHOLD'"
    exit 2
fi

if [[ ! -e "$CHECK_PATH" ]]; then
    echo "Error: path '$CHECK_PATH' does not exist" >&2
    log "FAILED: path does not exist '$CHECK_PATH'"
    exit 2
fi

USAGE_PCT=$(df -P "$CHECK_PATH" 2>/dev/null | awk 'NR==2 { gsub("%","",$5); print $5 }')

if [[ -z "$USAGE_PCT" || ! "$USAGE_PCT" =~ ^[0-9]+$ ]]; then
    echo "Error: could not determine disk usage for '$CHECK_PATH'" >&2
    log "FAILED: could not parse df output for '$CHECK_PATH'"
    exit 2
fi

echo "Disk usage for $CHECK_PATH: ${USAGE_PCT}%"

if (( USAGE_PCT >= THRESHOLD )); then
    echo "WARNING: usage ${USAGE_PCT}% has reached/exceeded threshold ${THRESHOLD}%"
    log "WARNING: path=$CHECK_PATH usage=${USAGE_PCT}% threshold=${THRESHOLD}% -> exceeded"
    exit 1
else
    echo "OK: usage ${USAGE_PCT}% is below threshold ${THRESHOLD}%"
    log "OK: path=$CHECK_PATH usage=${USAGE_PCT}% threshold=${THRESHOLD}% -> within limit"
    exit 0
fi
