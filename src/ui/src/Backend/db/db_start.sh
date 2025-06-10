#!/bin/bash

# === Настройки ===

PG_USER=""
PG_VERSION=""
PG_BASE=""
PG_BIN=""
PG_DATA=""
PG_CONF=""
PG_LOG=""

# === Порт из аргумента или по умолчанию ===

PORT=${1:-5432}

echo "📡 Проверка текущего порта PostgreSQL..."

CURRENT_PORT=$(grep -E '^\s*port\s*=' "$PG_CONF" | sed -E 's/.*=\s*([0-9]+).*/\1/')
if [ "$CURRENT_PORT" != "$PORT" ]; then
    echo "🔧 Обновляю порт в конфигурации: $CURRENT_PORT → $PORT"
    sed -i '' -E "s/^#?\s*port\s*=.*/port = $PORT/" "$PG_CONF"
    PORT_CHANGED=true
else
    echo "✅ Порт уже установлен: $PORT"
    PORT_CHANGED=false
fi

"$PG_BIN/pg_ctl" -D "$PG_DATA" status > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "⚠️ PostgreSQL уже запущен."
    if [ "$PORT_CHANGED" = true ]; then
        echo "🔁 Перезапускаю сервер для применения нового порта..."
        "$PG_BIN/pg_ctl" -D "$PG_DATA" restart -l "$PG_LOG"
    fi
else
    echo "🚀 Запускаю PostgreSQL..."
    "$PG_BIN/pg_ctl" -D "$PG_DATA" -l "$PG_LOG" start
fi

sleep 2

echo "🔍 Проверка статуса:"
"$PG_BIN/pg_ctl" -D "$PG_DATA" status

