#!/bin/sh

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd "$SCRIPT_DIR"

docker compose up -d

sleep 5

cd ../../test/
docker build -t hotelio-tester .
docker run --rm \
    --network hotelio-net \
    -e DB_HOST=monolith-db \
    -e DB_PORT=5432 \
    -e DB_NAME=hotelio \
    -e DB_USER=hotelio \
    -e DB_PASSWORD=hotelio \
    -e API_URL=http://monolith:8080 \
    hotelio-tester
