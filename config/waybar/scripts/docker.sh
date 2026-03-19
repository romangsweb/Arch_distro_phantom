#!/usr/bin/env bash
# Docker container count for Waybar
COUNT=$(docker ps -q 2>/dev/null | wc -l)
TOTAL=$(docker ps -aq 2>/dev/null | wc -l)
if [[ "$COUNT" -gt 0 ]]; then
    echo "{\"text\": \"  $COUNT\", \"tooltip\": \"Running: $COUNT / Total: $TOTAL\", \"class\": \"active\"}"
else
    echo "{\"text\": \"  0\", \"tooltip\": \"No containers running\", \"class\": \"idle\"}"
fi
