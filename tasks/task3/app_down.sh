#!/bin/sh

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
TASK2_DIR=$(cd "$SCRIPT_DIR/../task2/" && pwd)

cd "$TASK2_DIR"
docker compose down --timeout 0

cd "$SCRIPT_DIR"
docker compose down --timeout 0
