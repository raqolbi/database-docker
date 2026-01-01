#!/bin/bash
set -e

# Force sudo to ask password
sudo -k

echo "========================================="
echo " Docker Database RESET Utility"
echo "========================================="

if [ ! -f .env ]; then
  echo "❌ .env not found. Run from project root."
  exit 1
fi

export $(grep -v '^#' .env | xargs)

echo
echo "⚠️  THIS WILL DELETE ALL DATABASE DATA"
echo
echo "MySQL Data Path:     ${MYSQL_DATA_PATH}"
echo "MariaDB Data Path:  ${MARIADB_DATA_PATH}"
echo "PostgreSQL Data:    ${POSTGRES_DATA_PATH}"
echo

read -p "Type 'RESET' to continue: " CONFIRM
[ "$CONFIRM" = "RESET" ] || exit 0

echo
echo "🛑 Stopping containers..."
docker compose down

reset_dir() {
  local dir="$1"

  if [ -d "$dir" ]; then
    echo "🔥 Removing $dir"
    sudo rm -rf "$dir"
    sudo mkdir -p "$dir"
  else
    echo "📁 Creating $dir"
    sudo mkdir -p "$dir"
  fi
}

reset_dir "$MYSQL_DATA_PATH"
reset_dir "$MARIADB_DATA_PATH"
reset_dir "$POSTGRES_DATA_PATH"

echo
echo "🔐 Fixing ownership..."

# --------------------------------------------------
# MySQL & MariaDB
# - Official images run as user `mysql`
# - UID is 999 in official images
# --------------------------------------------------
sudo chown -R 999:999 \
  "$(dirname "$MYSQL_DATA_PATH")" \
  "$(dirname "$MARIADB_DATA_PATH")"

# --------------------------------------------------
# PostgreSQL
# - Official image runs as user `postgres`
# - UID is 999 in official image
# --------------------------------------------------
sudo chown -R 999:999 "$(dirname "$POSTGRES_DATA_PATH")"

echo
echo "🔐 Setting directory permissions..."

# MySQL & MariaDB: owner full, group read, others none
sudo chmod 750 "$MYSQL_DATA_PATH" "$MARIADB_DATA_PATH"

# PostgreSQL: owner only
sudo chmod 700 "$POSTGRES_DATA_PATH"

echo
echo "🚀 Starting containers..."
docker compose up -d

echo
echo "✅ RESET COMPLETE"
echo "ℹ️ PostgreSQL init scripts WILL run again"
