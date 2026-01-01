#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 \
  --username "postgres" \
  --dbname "postgres" <<-EOSQL

DO \$\$
BEGIN
  IF NOT EXISTS (
    SELECT FROM pg_roles WHERE rolname = '${POSTGRES_USER_APP}'
  ) THEN
    CREATE ROLE ${POSTGRES_USER_APP}
      LOGIN
      PASSWORD '${POSTGRES_PASSWORD_APP}'
      CREATEDB
      CREATEROLE;
  END IF;
END
\$\$;

EOSQL
