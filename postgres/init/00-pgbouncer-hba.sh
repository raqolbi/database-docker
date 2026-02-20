#!/usr/bin/env bash
set -e

echo "🔧 Prepending pg_hba.conf rule for PgBouncer..."

HBA_FILE="$PGDATA/pg_hba.conf"
TMP_FILE="$PGDATA/pg_hba.conf.tmp"
APP_USER="${POSTGRES_USER_APP:-momod}"

cat > "$TMP_FILE" <<EOF
# Allow PgBouncer (Docker network) to authenticate as postgres
host    all     postgres    samenet    trust
host    all     ${APP_USER}    samenet    trust

EOF

# Append existing rules AFTER PgBouncer rule
cat "$HBA_FILE" >> "$TMP_FILE"

# Replace original file
mv "$TMP_FILE" "$HBA_FILE"
