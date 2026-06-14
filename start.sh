#!/bin/bash
set -e

echo "Waiting for postgres..."
for i in $(seq 1 30); do
  if getent hosts postgres > /dev/null 2>&1 && nc -z postgres 5432 2>/dev/null; then
    PG_IP=$(getent hosts postgres | awk '{print $1}')
    echo "Postgres ready at $PG_IP (${i}s)"
    # Ensure /etc/hosts has the mapping for Erlang's resolver
    if ! grep -q "postgres" /etc/hosts 2>/dev/null; then
      echo "$PG_IP  postgres" >> /etc/hosts
    fi
    break
  fi
  sleep 1
done

echo "Starting Striatum..."
exec /app/bin/striatum start
