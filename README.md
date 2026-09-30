# Assignment 1 — Linux Diagnostic Toolkit

A small Bash-based diagnostic toolkit: system info, disk usage checks, and
basic network checks.

## Files

- `system-info.sh` — prints hostname, user, date/time, OS, kernel, uptime, CPU, memory, cwd
- `disk-check.sh <threshold> [path]` — checks disk usage against a threshold (default path `/`)
- `network-check.sh <host> [port]` — resolves a host, pings it, lists interfaces, optionally checks a TCP port
- `grade.sh` — grading script
- `logs/` — timestamped log output from each script run

## Installation / Setup

To setup this script run the commands below:

```bash
git clone https://github.com/AdemolaSam/ts-academy-1.git 
cd ts-academy-1
chmod +x *.sh
```

## Usage

```bash
./system-info.sh

./disk-check.sh 80          # checks / against 80%
./disk-check.sh 90 /home    # checks /home against 90%

./network-check.sh google.com
./network-check.sh google.com 443
```

## Exit codes

| Script            | 0            | 1                  | 2               |
|-------------------|--------------|--------------------|-----------------|
| disk-check.sh     | below threshold | -               | invalid input   |
| disk-check.sh     | -            | at/above threshold | -               |
| network-check.sh  | host resolved | host unresolved   | invalid input   |

## Testing

```bash
./grade.sh
```

## Assumptions

- `df -P` output format is used to parse disk usage (portable across most Linux distros).
- Host resolution tries `getent hosts` first, falling back to Python's `socket.gethostbyname`.
- TCP port checks use bash's built-in `/dev/tcp` pseudo-device rather than requiring `nc` to be installed.
- Network checks that time out (e.g. no ping allowed by network policy) do not fail the script — only failed *resolution* is treated as an error, since ping/ICMP is often blocked independently of whether a host is reachable over TCP.
