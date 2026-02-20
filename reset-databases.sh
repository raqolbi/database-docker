#!/bin/bash
set -e

usage() {
  cat <<'USAGE'
Usage:
  ./reset-databases.sh [all|mysql|mariadb|postgre|postgres] [...]

Examples:
  ./reset-databases.sh
  ./reset-databases.sh mysql
  ./reset-databases.sh mariadb postgre
  ./reset-databases.sh all
USAGE
}

# Force sudo to ask password
sudo -k

echo "========================================="
echo " Docker Database RESET Utility"
echo "========================================="

if [ ! -f .env ]; then
  echo "❌ .env not found. Run from project root."
  exit 1
fi

set -a
source .env
set +a

RESET_MYSQL=false
RESET_MARIADB=false
RESET_POSTGRES=false

if [ "$#" -eq 0 ]; then
  RESET_MYSQL=true
  RESET_MARIADB=true
  RESET_POSTGRES=true
else
  for target in "$@"; do
    case "$target" in
      all)
        RESET_MYSQL=true
        RESET_MARIADB=true
        RESET_POSTGRES=true
        ;;
      mysql)
        RESET_MYSQL=true
        ;;
      mariadb)
        RESET_MARIADB=true
        ;;
      postgre|postgres)
        RESET_POSTGRES=true
        ;;
      -h|--help|help)
        usage
        exit 0
        ;;
      *)
        echo "❌ Unknown target: $target"
        usage
        exit 1
        ;;
    esac
  done
fi

if [ "$RESET_MYSQL" = false ] && [ "$RESET_MARIADB" = false ] && [ "$RESET_POSTGRES" = false ]; then
  echo "❌ Nothing selected to reset"
  usage
  exit 1
fi

echo
echo "⚠️  THIS WILL DELETE DATABASE DATA"
echo

if [ "$RESET_MYSQL" = true ]; then
  echo "MySQL Data Path:     ${MYSQL_DATA_PATH}"
fi
if [ "$RESET_MARIADB" = true ]; then
  echo "MariaDB Data Path:   ${MARIADB_DATA_PATH}"
fi
if [ "$RESET_POSTGRES" = true ]; then
  echo "PostgreSQL Data:     ${POSTGRES_DATA_PATH}"
fi

echo
read -p "Type 'RESET' to continue: " CONFIRM
[ "$CONFIRM" = "RESET" ] || exit 0

SERVICES=()
if [ "$RESET_MYSQL" = true ]; then
  SERVICES+=("mysql")
fi
if [ "$RESET_MARIADB" = true ]; then
  SERVICES+=("mariadb")
fi
if [ "$RESET_POSTGRES" = true ]; then
  SERVICES+=("postgres" "pgbouncer")
fi

echo
echo "🛑 Stopping selected containers..."
docker compose stop "${SERVICES[@]}"

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

if [ "$RESET_MYSQL" = true ]; then
  reset_dir "$MYSQL_DATA_PATH"
fi
if [ "$RESET_MARIADB" = true ]; then
  reset_dir "$MARIADB_DATA_PATH"
fi
if [ "$RESET_POSTGRES" = true ]; then
  reset_dir "$POSTGRES_DATA_PATH"
fi

echo
echo "🔐 Fixing ownership..."

if [ "$RESET_MYSQL" = true ]; then
  sudo chown -R 999:999 "$(dirname "$MYSQL_DATA_PATH")"
fi
if [ "$RESET_MARIADB" = true ]; then
  sudo chown -R 999:999 "$(dirname "$MARIADB_DATA_PATH")"
fi
if [ "$RESET_POSTGRES" = true ]; then
  sudo chown -R 999:999 "$(dirname "$POSTGRES_DATA_PATH")"
fi

echo
echo "🔐 Setting directory permissions..."

if [ "$RESET_MYSQL" = true ]; then
  sudo chmod 750 "$MYSQL_DATA_PATH"
fi
if [ "$RESET_MARIADB" = true ]; then
  sudo chmod 750 "$MARIADB_DATA_PATH"
fi
if [ "$RESET_POSTGRES" = true ]; then
  sudo chmod 700 "$POSTGRES_DATA_PATH"
fi

echo
echo "🚀 Starting selected containers..."
docker compose up -d "${SERVICES[@]}"

echo
echo "✅ RESET COMPLETE"
if [ "$RESET_POSTGRES" = true ]; then
  echo "ℹ️ PostgreSQL init scripts WILL run again"
fi
