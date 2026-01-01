# Changelog

All notable changes to this project will be documented in this file.

This project follows a practical **Semantic Versioning** approach.

---

## [1.0.0] – 2026-01-01

### 🎉 Initial Stable Release

First production-ready release of the **Docker Database Stack**.

This version establishes a stable, repeatable, and maintainable foundation for running **MySQL**, **MariaDB**, **PostgreSQL**, and **PgBouncer** together using Docker Compose.

---

### ✨ Added

#### Core Services
- MySQL **8.4 (LTS)** with persistent host storage
- MariaDB **11.4 (LTS)** with persistent host storage
- PostgreSQL **17** with strict data directory permissions
- PgBouncer connection pooler using a custom Alpine-based image

#### User & Privilege Management
- Dedicated application user `momod` across all databases
- Automatic PostgreSQL application user creation via init scripts
- MySQL & MariaDB user elevation to **SUPER ADMIN** using post-start scripts
- PgBouncer authentication via PostgreSQL (`scram-sha-256`)
- PgBouncer userlist auto-generated from `.env`

#### Configuration & Structure
- Centralized configuration via a single `.env` file
- `.env.example` provided as canonical reference
- Clear separation between:
  - initialization scripts
  - post-start scripts
  - operational helper scripts
- Deterministic directory ownership strategy:
  - MySQL / MariaDB → `mysql` user (UID 999)
  - PostgreSQL → `postgres` user (UID 999)

---

### 🛠 Operational Tooling

- `setup.sh`
  - Creates required data directories
  - Fixes ownership and permissions
  - Builds Docker images
  - Starts all services
  - Executes post-start privilege scripts

- `reset-databases.sh`
  - Fully destructive reset with confirmation prompt
  - Recreates clean data directories
  - Restores correct ownership and permissions
  - Forces PostgreSQL init scripts to run again

---

### 🔐 Security & Stability

- Strict filesystem permissions for PostgreSQL (`700`)
- Safe permissions for MySQL & MariaDB (`750`)
- No hardcoded database names (multi-database ready)
- PgBouncer configured with **transaction pooling** by default
- Clear separation between:
  - administrative access
  - application access
  - connection pooling layer

---

### 📄 Documentation

- Comprehensive `README.md` including:
  - setup & reset workflows
  - environment variable reference
  - connection examples
  - security considerations
  - versioning guidance
- Fully documented directory structure
- Explicit production caveats and recommendations

---

### ⚠️ Known Limitations

- Password changes require a full database reset
- Superuser privileges are intentionally granted (development / self-host focus)
- TLS termination is not included by default and should be handled externally

---

### 🏷 Versioning

- This release is tagged as **v1.0.0**
- Future releases will follow semantic versioning:
  - **MAJOR** – breaking changes
  - **MINOR** – backward-compatible features
  - **PATCH** – fixes and refinements
