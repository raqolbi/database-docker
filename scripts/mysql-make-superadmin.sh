#!/usr/bin/env bash
set -e

# --------------------------------------------------
# Print message ONCE (no newline)
# --------------------------------------------------
printf "⏳ Waiting for MySQL to accept connections"

# --------------------------------------------------
# Wait function (silent)
# --------------------------------------------------
wait_mysql() {
  until mysqladmin ping \
    -h 127.0.0.1 \
    -P 3306 \
    -u root \
    -p"$MYSQL_ROOT_PASSWORD" \
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
wait_mysql &
WAIT_PID=$!
dot_wait "$WAIT_PID"
wait "$WAIT_PID"

echo
echo "✅ MySQL is ready. Granting super admin privileges..."

# --------------------------------------------------
# Grant super admin privileges (silent)
# --------------------------------------------------
mysql \
  -h 127.0.0.1 \
  -P 3306 \
  -u root \
  -p"$MYSQL_ROOT_PASSWORD" \
  --silent \
  --skip-column-names \
  > /dev/null 2>&1 <<-EOSQL

CREATE USER IF NOT EXISTS 'momod'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'momod'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

EOSQL

echo "✅ User 'momod' is now MySQL super admin"
