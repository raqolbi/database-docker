#!/usr/bin/env bash
set -e

echo "🚀 Starting PgBouncer as non-root user..."

# --------------------------------------------------
# PgBouncer does NOT use userlist.txt anymore
# Authentication is delegated to PostgreSQL via auth_query
# --------------------------------------------------

exec su-exec pgbouncer \
  /usr/bin/pgbouncer /etc/pgbouncer/pgbouncer.ini
