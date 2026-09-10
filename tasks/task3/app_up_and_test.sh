#!/bin/sh

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
TASK2_DIR=$(cd "$SCRIPT_DIR/../task2/" && pwd)
TASK2_REGRESS_SCRIPT_PATH="$TASK2_DIR/results/02_regress.sh"
TASK2_INIT_FIXTURES_SCRIPT_PATH="$TASK2_DIR/results/02_init_fixtures.sql"
TEST_DIR=$(cd "$SCRIPT_DIR/../../test/" && pwd)

RESULT_DOCKER_COMPOSE_PS_PATH="$SCRIPT_DIR/results/01_docker_compose_ps.txt"

cd "$TASK2_DIR"
docker compose up -d --build

docker compose ps > "$RESULT_DOCKER_COMPOSE_PS_PATH"

cd "$TEST_DIR"
chmod a+rx "$TASK2_REGRESS_SCRIPT_PATH"
docker build -t hotelio-tester .
docker run --rm \
    --network hotelio-net \
    -e DB_HOST=monolith-db \
    -e DB_PORT=5432 \
    -e DB_NAME=hotelio \
    -e DB_USER=hotelio \
    -e DB_PASSWORD=hotelio \
    -e API_URL=http://monolith:8080 \
    -v "${TASK2_REGRESS_SCRIPT_PATH}:/app/regress.sh" \
    -v "${TASK2_INIT_FIXTURES_SCRIPT_PATH}:/app/init-fixtures.sql" \
    hotelio-tester

cd "$SCRIPT_DIR"
docker compose up -d --build

docker compose ps >> "$RESULT_DOCKER_COMPOSE_PS_PATH"

docker compose logs -f
