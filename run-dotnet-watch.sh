#!/usr/bin/env bash
set -eu

PORT=5054

# Try graceful shutdown first
echo "=== Checking if port ${PORT} is in use ==="
if ss -ltnp 2>/dev/null | grep -q ":${PORT} "; then
    echo "Port ${PORT} is in use, attempting graceful shutdown..."
    pkill -TERM -f "dotnet watch" 2>/dev/null || true
    pkill -TERM -f "dotnet run" 2>/dev/null || true
    pkill -TERM -f "dotnet" 2>/dev/null || true
    dotnet clean 2>/dev/null || true
    sleep 2
fi

# Wait for port to be released (bounded wait)
echo "=== Waiting for port ${PORT} to be released ==="
for i in {1..50}; do
    if ! ss -ltn 2>/dev/null | grep -q ":${PORT} "; then
        echo "Port ${PORT} released."
        break
    fi
    sleep 0.25
done

echo "=== Hard cleaning port ${PORT} if still busy ==="
# Hard kill only if still stuck
if ss -ltn 2>/dev/null | grep -q ":${PORT} "; then
    echo "Port ${PORT} still busy, forcing release..."
    fuser -k ${PORT}/tcp 2>/dev/null || true
    sleep 2
fi

# Check for TIME_WAIT sockets (use ss -tan to see all TCP states, not just LISTEN)
echo "=== Checking for lingering TIME_WAIT sockets ==="
if ss -tan state time-wait 2>/dev/null | grep -q ":${PORT} "; then
    echo "TIME_WAIT sockets found on port ${PORT}, waiting briefly..."
    sleep 2
fi

echo "=== Starting running dotnet application"
exec dotnet run \
    --no-launch-profile \
    --non-interactive 