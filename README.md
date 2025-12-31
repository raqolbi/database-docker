# Docker Database Stack (MySQL · MariaDB · PostgreSQL)

A unified and production-ready **Docker Compose** setup to run **MySQL**, **MariaDB**, and **PostgreSQL** simultaneously with **persistent storage**, **environment-based configuration**, and **customizable ports**.

This repository is suitable for **local development**, **self-hosted servers**, **staging**, and **learning environments** where multiple databases are required side-by-side.

---

## ✨ Features

- MySQL 8.x
- MariaDB 10.11 (LTS)
- PostgreSQL 16
- Single `.env` file for all configurations
- Persistent data storage on host filesystem
- Custom host ports (no default port conflicts)
- Root / superuser support
- Dedicated application user (`momod`)
- Local and remote access enabled
- Clean and minimal Docker Compose setup

---

## 📂 Project Structure

```text
database-docker/
├── .env
├── docker-compose.yml
└── README.md
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

## ⚙️ Configuration

All configuration is handled via the `.env` file:

- Database credentials
- Host ports
- Database names
- Storage paths
- Timezone

Example:

```env
MYSQL_HOST_PORT=3307
MARIADB_HOST_PORT=3308
POSTGRES_HOST_PORT=5433
```

> ⚠️ **Important**  
> Always change default passwords before using this setup in production.

---

## 🚀 Getting Started

Start all databases:

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

## 🔌 Connection Examples

### MySQL
```bash
mysql -h 127.0.0.1 -P 3307 -u momod -p
```

### MariaDB
```bash
mysql -h 127.0.0.1 -P 3308 -u momod -p
```

### PostgreSQL
```bash
psql -h 127.0.0.1 -p 5433 -U momod appdb
```

---

## 🔐 Security Notes

This setup exposes database ports on the host machine.

For production environments, consider:
- Changing all default passwords
- Binding services to internal IPs only
- Using firewall rules (UFW / iptables)
- Accessing databases via VPN or SSH tunnel
- Applying database-level access restrictions

---

## 🧪 Recommended Use Cases

- Local development
- Multi-database testing
- Self-hosted database server
- CI/CD pipelines
- Docker and database learning labs

---

## 📄 License

MIT License  
You are free to use, modify, and distribute this project.

---

## 📌 Notes

- Docker Compose v2 is required
- Tested on Linux-based hosts
- Windows/macOS users should adjust volume paths accordingly
