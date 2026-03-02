#!/usr/bin/env bash
set -euo pipefail

RUN_DOCKER=true

# ------------------------------------------
# Engine selection flags
# ------------------------------------------
USE_POSTGRES=false
USE_MYSQL=false
USE_MARIADB=false

if [ "$#" -eq 0 ]; then
  USE_POSTGRES=true
  USE_MYSQL=true
  USE_MARIADB=true
else
  for arg in "$@"; do
    case $arg in
      --no-run)
        RUN_DOCKER=false
        ;;
      --postgres)
        USE_POSTGRES=true
        ;;
      --mysql)
        USE_MYSQL=true
        ;;
      --mariadb)
        USE_MARIADB=true
        ;;
      *)
        echo "❌ Unknown option: $arg"
        exit 1
        ;;
    esac
  done
fi

echo "========================================="
echo " Database Stack Initial Setup"
echo "========================================="

# ------------------------------------------
# Ensure .env exists
# ------------------------------------------
if [ ! -f .env ]; then
  echo "❌ .env file not found."
  echo "➡️  Copy .env.example to .env first."
  exit 1
fi

set -a
source .env
set +a

# ------------------------------------------
# Validate required variables dynamically
# ------------------------------------------
REQUIRED_VARS=()

[ "$USE_MYSQL" = true ] && REQUIRED_VARS+=(MYSQL_DATA_PATH)
[ "$USE_MARIADB" = true ] && REQUIRED_VARS+=(MARIADB_DATA_PATH)
[ "$USE_POSTGRES" = true ] && REQUIRED_VARS+=(POSTGRES_DATA_PATH)

for VAR in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!VAR:-}" ]; then
    echo "❌ Environment variable $VAR is not set"
    exit 1
  fi
done

# ------------------------------------------
# Create directories
# ------------------------------------------
echo
echo "📁 Creating persistent data directories..."

[ "$USE_MYSQL" = true ] && mkdir -p "$MYSQL_DATA_PATH"
[ "$USE_MARIADB" = true ] && mkdir -p "$MARIADB_DATA_PATH"
[ "$USE_POSTGRES" = true ] && mkdir -p "$POSTGRES_DATA_PATH"

# ------------------------------------------
# Fix ownership
# ------------------------------------------
echo
echo "🔐 Fixing ownership..."

if [ "$USE_MYSQL" = true ]; then
  sudo chown -R 999:999 "$(dirname "$MYSQL_DATA_PATH")"
  sudo chmod 750 "$MYSQL_DATA_PATH"
fi

if [ "$USE_MARIADB" = true ]; then
  sudo chown -R 999:999 "$(dirname "$MARIADB_DATA_PATH")"
  sudo chmod 750 "$MARIADB_DATA_PATH"
fi

if [ "$USE_POSTGRES" = true ]; then
  sudo chown -R 999:999 "$(dirname "$POSTGRES_DATA_PATH")"
  sudo chmod 700 "$POSTGRES_DATA_PATH"
fi

# ------------------------------------------
# Ensure executable scripts
# ------------------------------------------
echo
echo "🔧 Ensuring executable scripts..."

[ -d "./mysql/init" ] && chmod +x ./mysql/init/*.sh 2>/dev/null || true
[ -d "./mariadb/init" ] && chmod +x ./mariadb/init/*.sh 2>/dev/null || true
[ -d "./postgres/init" ] && chmod +x ./postgres/init/*.sh 2>/dev/null || true
[ -f "./pgbouncer/entrypoint.sh" ] && chmod +x ./pgbouncer/entrypoint.sh
[ -f "./reset-databases.sh" ] && chmod +x ./reset-databases.sh
[ -f "./scripts/mysql-make-superadmin.sh" ] && chmod +x ./scripts/mysql-make-superadmin.sh
[ -f "./scripts/mariadb-make-superadmin.sh" ] && chmod +x ./scripts/mariadb-make-superadmin.sh

# ------------------------------------------
# Docker
# ------------------------------------------
if [ "$RUN_DOCKER" = true ]; then
  echo
  echo "🐳 Building selected services..."

  SERVICES=()

  if [ "$USE_MYSQL" = true ]; then
    SERVICES+=(mysql)
  fi

  if [ "$USE_MARIADB" = true ]; then
    SERVICES+=(mariadb)
  fi

  if [ "$USE_POSTGRES" = true ]; then
    SERVICES+=(postgres pgbouncer) # auto include pgbouncer
  fi

  docker compose build "${SERVICES[@]}"
  docker compose up -d "${SERVICES[@]}"

  sleep 5

  # Post start scripts
  if [ "$USE_MYSQL" = true ]; then
    docker exec mysql_db bash /scripts/mysql-make-superadmin.sh || true
  fi

  if [ "$USE_MARIADB" = true ]; then
    docker exec mariadb_db bash /scripts/mariadb-make-superadmin.sh || true
  fi

  echo
  echo "✅ Setup complete."
else
  echo
  echo "ℹ️  Setup complete. Docker skipped (--no-run)."
fi