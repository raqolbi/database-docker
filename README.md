# Docker Database Stack

**MySQL · MariaDB · PostgreSQL · PgBouncer**

A **production-ready Docker Compose stack** for running **MySQL**, **MariaDB**, **PostgreSQL**, and **PgBouncer**
side-by-side with **persistent storage**, **centralized configuration**, and **clean operational workflows**.

This repository is designed for **local development**, **self-hosted servers**, **staging**, and
**long-running environments** where stability, clarity, and repeatability matter.

---

## ✨ Features

- **MySQL 8.4 (LTS)**
- **MariaDB 11.4 (LTS)**
- **PostgreSQL 18.1**
- **PgBouncer** (custom Alpine-based image)
- Single `.env` file for all configuration
- Persistent host-based storage (bind mounts)
- Custom host ports (no conflicts)
- Per-service timezone support
- Dedicated application user (`momod`)
- MySQL & MariaDB user elevated to SUPER ADMIN after startup
- PostgreSQL app user auto-created on first initialization
- PgBouncer authentication via PostgreSQL (SCRAM-SHA-256)
- One-command setup & reset workflow

---

## 📂 Project Structure (Current)

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

```
/mnt/data/Coding/Database/
├── mysql/data
├── mariadb/data
└── postgre/data
```

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

## 🚀 Usage

### Initial setup

```
./setup.sh
```

### Setup only (no docker run)

```
./setup.sh --no-run
```

### Reset databases

```
# Reset all (default)
./reset-databases.sh

# Reset only MySQL
./reset-databases.sh mysql

# Reset only MariaDB + PostgreSQL
./reset-databases.sh mariadb postgre
```

---

## 🔌 Connections

```
mysql -h 127.0.0.1 -P 3306 -u momod -p
mysql -h 127.0.0.1 -P 3307 -u momod -p
psql -h 127.0.0.1 -p 5432 -U momod
psql -h 127.0.0.1 -p 6432 -U momod
```

---

## 📦 Version

v1.0.2

---

## 📄 License

MIT License
