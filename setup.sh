#!/usr/bin/env bash
set -euo pipefail

RUN_DOCKER=true

if [ "${1:-}" = "--no-run" ]; then
  RUN_DOCKER=false
fi

echo "========================================="
echo " Database Stack Initial Setup"
echo "========================================="

# ------------------------------------------
# Ensure .env exists
# ------------------------------------------
if [ ! -f .env ]; then
  echo "❌ .env file not found."
  echo "➡️  Copy .env.example to .env and configure it first."
  exit 1
fi

# ------------------------------------------
# Load environment variables
# ------------------------------------------
set -a
source .env
set +a

# ------------------------------------------
# Validate required variables
# ------------------------------------------
REQUIRED_VARS=(
  MYSQL_DATA_PATH
  MARIADB_DATA_PATH
  POSTGRES_DATA_PATH
)

for VAR in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!VAR:-}" ]; then
    echo "❌ Environment variable $VAR is not set"
    exit 1
  fi
done

echo
echo "📁 Creating persistent data directories..."
mkdir -p "$MYSQL_DATA_PATH" "$MARIADB_DATA_PATH" "$POSTGRES_DATA_PATH"

echo
echo "🔐 Fixing ownership (may ask sudo password)..."

# MySQL & MariaDB (mysql user – UID 999)
sudo chown -R 999:999 \
  "$(dirname "$MYSQL_DATA_PATH")" \
  "$(dirname "$MARIADB_DATA_PATH")"

# PostgreSQL (postgres user – UID 999)
sudo chown -R 999:999 "$(dirname "$POSTGRES_DATA_PATH")"

echo
echo "🔐 Setting directory permissions..."

sudo chmod 750 "$MYSQL_DATA_PATH" "$MARIADB_DATA_PATH"
sudo chmod 700 "$POSTGRES_DATA_PATH"

echo
echo "🔧 Ensuring executable scripts..."

# Init scripts
[ -d "./mysql/init" ] && chmod +x ./mysql/init/*.sh 2>/dev/null || true
[ -d "./mariadb/init" ] && chmod +x ./mariadb/init/*.sh 2>/dev/null || true
[ -d "./postgres/init" ] && chmod +x ./postgres/init/*.sh 2>/dev/null || true

# PgBouncer
[ -f "./pgbouncer/entrypoint.sh" ] && chmod +x ./pgbouncer/entrypoint.sh

# Reset utility
[ -f "./reset-databases.sh" ] && chmod +x ./reset-databases.sh

# Post-init superadmin scripts
[ -f "./scripts/mysql-make-superadmin.sh" ] && chmod +x ./scripts/mysql-make-superadmin.sh
[ -f "./scripts/mariadb-make-superadmin.sh" ] && chmod +x ./scripts/mariadb-make-superadmin.sh

if [ "$RUN_DOCKER" = true ]; then
  echo
  echo "🐳 Building Docker images..."
  docker compose build

  echo "🚀 Starting containers..."
  docker compose up -d

  # kasih waktu ekstra (aman)
  sleep 5

  docker exec mysql_db bash /scripts/mysql-make-superadmin.sh
  docker exec mariadb_db bash /scripts/mariadb-make-superadmin.sh

  echo
  echo "✅ Setup complete. Stack is running and users are elevated."
else
  echo
  echo "ℹ️  Setup complete. Docker build/run skipped (--no-run)."
fi
