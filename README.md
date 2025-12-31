# Docker Database Stack (MySQL · MariaDB · PostgreSQL)

A unified, production-ready **Docker Compose** stack for running **MySQL**, **MariaDB**, and **PostgreSQL** side-by-side with **persistent storage**, **environment-based configuration**, **per-service timezones**, and **multi-database support**.

This repository is designed for **local development**, **self-hosted servers**, **staging**, and **long-running database servers** where reliability, clarity, and repeatability are required.

---

## ✨ Features

- **MySQL 8.4 (LTS)**
- **MariaDB 11.4 (LTS)**
- **PostgreSQL 17**
- Single `.env` file for all configuration
- Persistent data storage on host filesystem
- Custom host ports (no default port conflicts)
- Per-database timezone configuration
- Root / superuser access for all engines
- Dedicated application user (`momod`)
- PostgreSQL app user auto-created from `.env`
- Multi-database ready (not bound to a single database name)
- Clean, minimal, and production-oriented Docker Compose setup

---

## 📂 Project Structure

```text
database-docker/
├── .env
├── docker-compose.yml
├── README.md
└── postgres/
    └── init/
        └── 01-create-app-user.sh
```

---

## 🧱 Persistent Storage Layout

All database data is stored on the host machine:

```text
/mnt/data/Coding/Database/
├── mysql/data
├── mariadb/data
└── postgre/data
```

Create the directories before starting:

```bash
sudo mkdir -p /mnt/data/Coding/Database/{mysql,mariadb,postgre}/data
sudo chown -R $USER:$USER /mnt/data/Coding/Database
```

---

## ⚙️ Configuration (.env)

All configuration is handled via the `.env` file.

### Example `.env`

```env
# ===============================
# MYSQL (8.4 LTS)
# ===============================
MYSQL_HOST_PORT=3307
MYSQL_ROOT_PASSWORD=change_me
MYSQL_USER=momod
MYSQL_PASSWORD=change_me
MYSQL_TZ=Asia/Jakarta
MYSQL_DATA_PATH=/mnt/data/Coding/Database/mysql/data

# ===============================
# MARIADB (11.4 LTS)
# ===============================
MARIADB_HOST_PORT=3308
MARIADB_ROOT_PASSWORD=change_me
MARIADB_USER=momod
MARIADB_PASSWORD=change_me
MARIADB_TZ=Asia/Jakarta
MARIADB_DATA_PATH=/mnt/data/Coding/Database/mariadb/data

# ===============================
# POSTGRESQL (17)
# root-equivalent user = postgres
# ===============================
POSTGRES_HOST_PORT=5432
POSTGRES_ROOT_PASSWORD=change_me
POSTGRES_USER_APP=momod
POSTGRES_PASSWORD_APP=change_me
POSTGRES_TZ=UTC
POSTGRES_DATA_PATH=/mnt/data/Coding/Database/postgre/data
```

### Important Notes

- No database name is predefined  
  → You are free to create **multiple databases** per engine.
- Environment variables are used for **initial bootstrap only**.
- Changing `.env` passwords **does not update existing databases**.
- Always add `.env` to `.gitignore`.

---

## 🚀 Getting Started

Start all database services:

```bash
docker compose up -d
```

Check running containers:

```bash
docker ps
```

Stop all services:

```bash
docker compose down
```

---

## 🧑‍💻 PostgreSQL App User Automation (from `.env`)

PostgreSQL Docker images support **only one user via environment variables** at initialization.

To create an additional application user (`momod`) **using values from `.env`**, this project uses an **init shell script** placed in:

```text
/docker-entrypoint-initdb.d
```

### How it works

1. PostgreSQL initializes a new data directory
2. The `postgres` superuser is created
3. All `.sh` and `.sql` files in `/docker-entrypoint-initdb.d` are executed
4. `01-create-app-user.sh` reads environment variables and creates `momod`
5. Scripts run **only once** (when the data directory is empty)

This is the **official and recommended approach** for PostgreSQL Docker images.

---

## 🔌 Connection Examples

### MySQL

```bash
mysql -h 127.0.0.1 -P 3307 -u momod -p
```

### MariaDB

```bash
mysql -h 127.0.0.1 -P 3308 -u momod -p
```

### PostgreSQL (root-equivalent)

```bash
psql -h 127.0.0.1 -p 5432 -U postgres
```

### PostgreSQL (application user)

```bash
psql -h 127.0.0.1 -p 5432 -U momod
```

---

## 🕒 Timezone Strategy

| Database   | Timezone     |
| ---------- | ------------ |
| MySQL      | Asia/Jakarta |
| MariaDB    | Asia/Jakarta |
| PostgreSQL | UTC          |

### Recommendation

- Use **UTC** for production databases
- Convert timezones at the application layer
- Avoid mixing local timezones across services in production

---

## 🔐 Security Notes

This setup exposes database ports on the host machine.

For production environments, consider:

- Changing all default passwords
- Restricting access using firewall rules
- Binding services to internal IPs only
- Using VPN or SSH tunneling for remote access
- Applying least-privilege database permissions
- Avoid using root / `postgres` users in applications

---

## 🧪 Recommended Use Cases

- Local development
- Multi-database testing
- Long-running self-hosted database server
- CI/CD pipelines
- Docker and database learning labs

---

## 📄 License

MIT License  
Free to use, modify, and distribute.

---

## 📌 Notes

- Docker Compose v2 is required
- Tested on Linux-based hosts
- Windows/macOS users should adjust volume paths accordingly
