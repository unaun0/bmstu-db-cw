#!/bin/bash

# Настройки

PG_USER=""
PG_VERSION=""
PG_BASE=""
PG_BIN=""
PG_DATA=""

echo "🛑 Останавливаю PostgreSQL..."

"$PG_BIN/pg_ctl" -D "$PG_DATA" stop

sleep 2

echo "📡 Проверка статуса:"
"$PG_BIN/pg_ctl" -D "$PG_DATA" status
