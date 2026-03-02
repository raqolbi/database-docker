# Docker Database Stack

**MySQL · MariaDB · PostgreSQL · PgBouncer**

A production-ready Docker Compose stack for running **MySQL**, **MariaDB**, and **PostgreSQL** flexibly — individually, in combination, or all together — with **PgBouncer automatically enabled when PostgreSQL is selected**.

Designed for:

- Local development
- Self-hosted servers
- Staging environments
- Long-running production systems

Focused on stability, modularity, and repeatable operational workflows.

---

## ✨ Features

- MySQL 8.4 (LTS)
- MariaDB 11.4 (LTS)
- PostgreSQL 18.1
- PgBouncer (Alpine-based custom image)
- Multi-engine selection via CLI flags
- Automatic PgBouncer inclusion when `--postgres` is used
- Single centralized `.env` configuration
- Persistent bind-mounted storage
- Custom host ports (no conflicts)
- Per-service timezone configuration
- Dedicated application user (`momod`)
- MySQL & MariaDB elevated to SUPER ADMIN after startup
- PostgreSQL application user auto-created on first initialization
- PgBouncer authentication via PostgreSQL (SCRAM-SHA-256)
- Selective reset per database engine

---

## 🆕 Engine Selection (v1.1+)

The setup script supports dynamic engine selection.

### Default (All Engines)

```
./setup.sh
```

Starts:

- MySQL
- MariaDB
- PostgreSQL
- PgBouncer (because PostgreSQL is enabled)

---

### PostgreSQL Only (automatically includes PgBouncer)

```
./setup.sh --postgres
```

Starts:

- PostgreSQL
- PgBouncer

---

### MySQL Only

```
./setup.sh --mysql
```

---

### PostgreSQL + MySQL

```
./setup.sh --postgres --mysql
```

---

### Skip Docker Run

```
./setup.sh --postgres --no-run
```

Runs provisioning only (directories, permissions, executable setup) without building or starting containers.

---

## 📂 Project Structure

```
database-docker/
├── .env
├── .env.example
├── docker-compose.yml
├── setup.sh
├── reset-databases.sh
├── README.md
│
├── mysql/
│   └── init/
│
├── mariadb/
│   └── init/
│
├── postgres/
│   └── init/
│       ├── 00-pgbouncer-hba.sh
│       └── 01-create-momod.sh
│
├── pgbouncer/
│   ├── Dockerfile
│   ├── entrypoint.sh
│   └── pgbouncer.ini
│
└── scripts/
    ├── mysql-make-superadmin.sh
    └── mariadb-make-superadmin.sh
```

---

## 🧱 Persistent Storage Layout

Example:

```
/mnt/data/Coding/Database/
├── mysql/data
├── mariadb/data
└── postgre/data
```

Paths are controlled via the `.env` file.

---

## ⚙️ Configuration (.env)

```
# ===============================
# MYSQL
# ===============================
MYSQL_HOST_PORT=3306
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_USER=momod
MYSQL_PASSWORD=momodpassword
MYSQL_TZ=Asia/Jakarta
MYSQL_DATA_PATH=/mnt/data/Coding/Database/mysql/data

# ===============================
# MARIADB
# ===============================
MARIADB_HOST_PORT=3307
MARIADB_ROOT_PASSWORD=rootpassword
MARIADB_USER=momod
MARIADB_PASSWORD=momodpassword
MARIADB_TZ=Asia/Jakarta
MARIADB_DATA_PATH=/mnt/data/Coding/Database/mariadb/data

# ===============================
# POSTGRESQL
# ===============================
POSTGRES_HOST_PORT=5432
POSTGRES_USER_APP=momod
POSTGRES_PASSWORD_APP=momodpassword
POSTGRES_ROOT_PASSWORD=rootpassword
POSTGRES_TZ=UTC
POSTGRES_DATA_PATH=/mnt/data/Coding/Database/postgre/data

# ===============================
# PGBOUNCER
# ===============================
PGBOUNCER_PORT=6432
PGBOUNCER_POOL_MODE=transaction
PGBOUNCER_MAX_CLIENT_CONN=200
PGBOUNCER_DEFAULT_POOL_SIZE=20
PGBOUNCER_AUTH_USER=postgres
PGBOUNCER_AUTH_PASSWORD=rootpassword
PGBOUNCER_APP_USER=momod
PGBOUNCER_APP_PASSWORD=momodpassword
```

---

## 🔄 Reset Databases

Reset supports engine selection.

### Reset All (default)

```
./reset-databases.sh
```

### Reset Specific Engines

```
./reset-databases.sh mysql
./reset-databases.sh mariadb postgre
```

Engines not specified will not be affected.

---

## 🔌 Connection Examples

MySQL:

```
mysql -h 127.0.0.1 -P 3306 -u momod -p
```

MariaDB:

```
mysql -h 127.0.0.1 -P 3307 -u momod -p
```

PostgreSQL (direct):

```
psql -h 127.0.0.1 -p 5432 -U momod
```

PostgreSQL (via PgBouncer):

```
psql -h 127.0.0.1 -p 6432 -U momod
```

---

## 🏗 Architecture (When PostgreSQL Enabled)

```
Application
   ↓
PgBouncer (6432)
   ↓
PostgreSQL (5432 internal)
```

For production workloads, applications should connect to PgBouncer for improved stability and connection efficiency.

---

## 📦 Version

v1.0.3

---

## 📄 License

MIT License
