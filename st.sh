#!/usr/bin/env bash
set -euo pipefail

gunicorn --bind 127.0.0.1:5000 --timeout 180 some_app:app &
APP_PID=$!

trap 'kill "$APP_PID" 2>/dev/null || true' EXIT

echo "Ожидание запуска сервера..."

for attempt in {1..180}; do
    if ! kill -0 "$APP_PID" 2>/dev/null; then
        echo "Сервер завершился с ошибкой."
        exit 1
    fi

    if curl --fail --silent --max-time 2 \
        http://127.0.0.1:5000/ > /dev/null; then
        echo "Сервер готов. Запускаем клиент."
        python3 client.py
        exit 0
    fi

    sleep 1
done

echo app code $APP_CODE
exit $APP_CODE