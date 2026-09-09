#!/bin/sh

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd "$SCRIPT_DIR"

docker compose down --volumes --remove-orphans --timeout 10

docker compose up -d --build

sleep 10

PROTO_FILE_PATH="$(realpath ../../booking-service/proto/booking.proto)"
RESULT_DOCKER_COMPOSE_PS_PATH="$(realpath results/01_docker_compose_ps.txt)"
REGRESS_SCRIPT_PATH="$(realpath results/02_regress.sh)"
INIT_FIXTURES_SCRIPT_PATH="$(realpath results/02_init_fixtures.sql)"
RESULT_LOG_PATH="$(realpath results/03_test_log.txt)"
RESULT_HOTELIO_DB_PATH="$(realpath results/04_booking_table_from_hotelio_db.txt)"
RESULT_BOOKING_DB_PATH="$(realpath results/05_booking_table_from_booking_db.txt)"
RESULT_BOOKINGS_VIA_REST_PATH="$(realpath results/06_bookings_via_rest.json)"
RESULT_BOOKINGS_VIA_GRPC_PATH="$(realpath results/07_bookings_via_grpc.json)"
RESULT_BOOKING_HISTORY_DB_PATH="$(realpath results/08_booking_history_table.txt)"

# docker ps

docker compose ps > "${RESULT_DOCKER_COMPOSE_PS_PATH}"

# test log

chmod a+rx "$REGRESS_SCRIPT_PATH"

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
    -v "${REGRESS_SCRIPT_PATH}:/app/regress.sh" \
    -v "${INIT_FIXTURES_SCRIPT_PATH}:/app/init-fixtures.sql" \
    hotelio-tester | tee "${RESULT_LOG_PATH}"

#sleep 10

# select booking

docker exec hotelio-db \
    psql -A -P pager=off -U hotelio -d hotelio -c 'SELECT * FROM booking;' | tee "${RESULT_HOTELIO_DB_PATH}"

docker exec -it booking-db \
    psql -A -P pager=off -U booking -d booking -c 'SELECT * FROM booking;' | tee "${RESULT_BOOKING_DB_PATH}"

# rest

curl -sS 'http://localhost:8084/api/bookings?userId=test-user-2' | jq . | tee "${RESULT_BOOKINGS_VIA_REST_PATH}"

# grpc

docker run --rm --network hotelio-net \
    -v "$(dirname "${PROTO_FILE_PATH}")":/proto:ro \
    fullstorydev/grpcurl:latest \
    -import-path /proto \
    -proto booking.proto \
    -plaintext \
    -d '{"user_id":"test-user-2"}' \
    booking-service:9090 booking.BookingService/ListBookings | tee "${RESULT_BOOKINGS_VIA_GRPC_PATH}"

# select history

docker exec -it booking-history-db \
    psql -A -P pager=off -U history -d history -c 'SELECT * FROM booking_history;' | tee "${RESULT_BOOKING_HISTORY_DB_PATH}"
