#!/usr/bin/env bash
set -e

# --------------------------------------------------
# Print message ONCE (no newline)
# --------------------------------------------------
printf "⏳ Waiting for MariaDB to accept connections"

# --------------------------------------------------
# Wait function (silent, MariaDB-specific)
# --------------------------------------------------
wait_mariadb() {
  until mariadb-admin ping \
    -h 127.0.0.1 \
    -P 3306 \
    -u root \
    -p"$MARIADB_ROOT_PASSWORD" \
    --silent \
    > /dev/null 2>&1
  do
    sleep 2
  done
}

# --------------------------------------------------
# Dot spinner (ONLY dots change)
# --------------------------------------------------
dot_wait() {
  local pid=$1
  local dots=0

  tput civis 2>/dev/null || true

  while kill -0 "$pid" 2>/dev/null; do
    dots=$((dots + 1))

    if [ "$dots" -gt 3 ]; then
      # Remove previous dots
      printf "\b\b\b   \b\b\b"
      dots=1
    fi

    printf "."
    sleep 0.5
  done

  # Clean dots
  printf "\b\b\b   \b\b\b"
  tput cnorm 2>/dev/null || true
}

# --------------------------------------------------
# Run wait + spinner
# --------------------------------------------------
wait_mariadb &
WAIT_PID=$!
dot_wait "$WAIT_PID"
wait "$WAIT_PID"

echo
echo "✅ MariaDB is ready. Granting super admin privileges..."

# --------------------------------------------------
# Grant super admin privileges (silent)
# --------------------------------------------------
mariadb \
  -h 127.0.0.1 \
  -P 3306 \
  -u root \
  -p"$MARIADB_ROOT_PASSWORD" \
  --silent \
  > /dev/null 2>&1 <<-EOSQL

CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MARIADB_USER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

EOSQL

echo "✅ MariaDB user '${MARIADB_USER}' is now SUPER ADMIN"
