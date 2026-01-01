#!/usr/bin/env bash
set -e

echo "🔧 Prepending pg_hba.conf rule for PgBouncer..."

HBA_FILE="$PGDATA/pg_hba.conf"
TMP_FILE="$PGDATA/pg_hba.conf.tmp"

cat > "$TMP_FILE" <<'EOF'
# Allow PgBouncer (Docker network) to authenticate as postgres
host    all     postgres    172.18.0.0/16    trust
host    all     momod       172.18.0.0/16    trust

EOF

# Append existing rules AFTER PgBouncer rule
cat "$HBA_FILE" >> "$TMP_FILE"

# Replace original file
mv "$TMP_FILE" "$HBA_FILE"
