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

## 🚀 Quick Start (Interactive — no manual `.env` required)

**Prerequisites:** Docker, Docker Compose, and `sudo` access on the VM.

```bash
git clone <repo-url> database-docker
cd database-docker
chmod +x setup.sh
./setup.sh
```

That is all you need for a first-time install. The script will:

1. Ask which database engine(s) to install
2. **Create `.env` automatically** (passwords, ports, data paths, timezone)
3. Create data directories and fix permissions
4. Create the Docker network
5. Build and start containers
6. Print **remote connection info** for other VMs

You do **not** need to run `cp .env.example .env` or edit any file before the first run.

On subsequent runs, if `.env` already exists you will be asked: **overwrite or keep?** (default: keep).

### One-liner examples

```bash
# Interactive wizard + PostgreSQL only (+ PgBouncer)
./setup.sh --postgres

# Interactive wizard + MySQL + MariaDB
./setup.sh --mysql --mariadb

# Prepare directories only, skip Docker (still creates .env if missing)
./setup.sh --postgres --no-run
```

Press **Enter** at any prompt to accept the default value shown in brackets.

---

## ✨ Features

- MySQL 8.4 (LTS)
- MariaDB 11.4 (LTS)
- PostgreSQL 18.4
- PgBouncer (Alpine-based custom image)
- **Fully interactive first-time setup** — `.env` generated automatically
- Multi-engine selection via CLI flags or interactive menu
- Automatic PgBouncer inclusion when `--postgres` is used
- Custom host ports exposed for remote VM access
- Persistent bind-mounted storage
- Per-service timezone configuration
- Auto-generated secure passwords (optional)
- Dedicated application user (default: `momod`, configurable)
- MySQL & MariaDB elevated to SUPER ADMIN after startup
- PostgreSQL application user auto-created on first initialization
- PgBouncer authentication via PostgreSQL (SCRAM-SHA-256)
- Selective reset per database engine

---

## 🌐 Remote Access (Multi-VM Setup)

Typical deployment: **1 VM runs Docker + databases**, other VMs connect over the network.

Host ports are configured during the interactive wizard (or in `.env`):

| Service   | Default port | Env variable          |
|-----------|-------------|------------------------|
| MySQL     | 3306        | `MYSQL_HOST_PORT`      |
| MariaDB   | 3307        | `MARIADB_HOST_PORT`    |
| PostgreSQL| 5432        | `POSTGRES_HOST_PORT`   |
| PgBouncer | 6432        | `PGBOUNCER_PORT`       |

After setup, connect from another VM:

```
mysql  -h <DB_VM_IP> -P 3306 -u momod -p
psql   -h <DB_VM_IP> -p 6432 -U momod    # PgBouncer — recommended for apps
```

Open firewall on the **database VM** (restrict to app VM IPs in production):

```bash
sudo ufw allow from <APP_VM_IP> to any port 6432 proto tcp
```

---

## 🆕 Engine Selection

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

Default base path (set during interactive setup): `/var/lib/database-docker`

```
/var/lib/database-docker/
├── mysql/data
├── mariadb/data
└── postgre/data
```

Paths are stored in `.env`. To change later, edit `.env` and re-run `./setup.sh --no-run`.

---

## ⚙️ Configuration (`.env`)

On first run, `setup.sh` **creates `.env` for you**. If `.env` already exists, the script asks whether to **overwrite** it (previous file is backed up as `.env.bak.<timestamp>`). Choose **No** to keep the current config and continue setup.

You only need to create or copy it manually if you prefer a fully non-interactive workflow:

```bash
cp .env.example .env   # optional — only if you skip the wizard
nano .env
./setup.sh --postgres
```

Reference of all supported variables:

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

Replace `<DB_VM_IP>` with the IP shown at the end of `setup.sh`, or use `127.0.0.1` for local access.

MySQL:

```
mysql -h <DB_VM_IP> -P 3306 -u momod -p
```

MariaDB:

```
mysql -h <DB_VM_IP> -P 3307 -u momod -p
```

PostgreSQL (direct):

```
psql -h <DB_VM_IP> -p 5432 -U momod
```

PostgreSQL (via PgBouncer — recommended for applications):

```
psql -h <DB_VM_IP> -p 6432 -U momod
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

v1.0.4

---

## 📄 License

MIT License
