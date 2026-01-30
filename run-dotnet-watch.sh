#!/usr/bin/env bash
set -eu

PORT=5054

echo "=== Ensuring clean shutdown ==="

# Gracefully stop dotnet-related servers (Roslyn / MSBuild)
dotnet build-server shutdown 2>/dev/null || true

# Try graceful shutdown first
if ss -ltnp 2>/dev/null | grep -q ":${PORT} "; then
    echo "Port ${PORT} is in use, attempting graceful shutdown..."
    pkill -TERM -f "dotnet watch" 2>/dev/null || true
    pkill -TERM -f "dotnet run" 2>/dev/null || true
    pkill -TERM -f "dotnet" 2>/dev/null || true
fi

# Wait for port to be released (bounded wait)
echo "=== Waiting for port ${PORT} to be released ==="
for i in {1..50}; do
    if ! ss -ltn 2>/dev/null | grep -q ":${PORT} "; then
        echo "Port ${PORT} released."
        break
    fi
    sleep 0.2
done

echo "=== Hard cleaning port ${PORT} if still busy ==="
# Hard kill only if still stuck
if ss -ltn 2>/dev/null | grep -q ":${PORT} "; then
    echo "Port ${PORT} still busy, forcing release..."
    fuser -k ${PORT}/tcp 2>/dev/null || true
    sleep 1
fi

# Additional cleanup for TIME_WAIT sockets
echo "=== Checking for lingering TIME_WAIT sockets ==="
if ss -ltn 2>/dev/null | grep -q ":${PORT}.*TIME-WAIT"; then
    echo "Waiting for TIME_WAIT sockets to clear..."
    sleep 2
fi

echo "=== Starting to build ==="
dotnet clean
dotnet build

echo "=== Starting dotnet watch ==="
exec dotnet watch run \
    --no-launch-profile \
    --non-interactive \