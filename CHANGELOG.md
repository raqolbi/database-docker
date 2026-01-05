# Changelog

All notable changes to this project will be documented in this file.

This project follows a practical **Semantic Versioning** approach.

---

## [1.0.1] – 2026-01-05

### 🔄 PostgreSQL Upgrade Release

This release upgrades the PostgreSQL service to the latest **major version 18**, aligning the stack with upstream architectural changes and future-proofing the database layer.

---

### ⬆️ Changed

#### PostgreSQL

- Upgraded PostgreSQL from **17 → 18**
- Updated data directory strategy to comply with PostgreSQL 18+ requirements:
  - Data is now stored under **major-version-specific subdirectories**
  - Base mount point moved to `/var/lib/postgresql`
- Volume layout is now compatible with:
  - `pg_ctlcluster`
  - `pg_upgrade --link`
  - Future major version upgrades without mount boundary issues

---

### ⚠️ Breaking Change Notice

- Existing PostgreSQL data volumes created with versions **≤ 17** are **not compatible** with PostgreSQL 18 without a proper upgrade process.
- Directly reusing old volumes will result in a **startup failure by design** (fail-fast behavior to prevent data corruption).

**Required actions:**

- Development / fresh environments:
  - Remove existing PostgreSQL volumes and reinitialize the database
- Production environments:
  - Perform an explicit `pg_upgrade` using both PostgreSQL 17 and 18 binaries

---

### 🛠 Operational Notes

- `reset-databases.sh` fully supports PostgreSQL 18 initialization
- Directory ownership and permission enforcement remain unchanged:
  - PostgreSQL data directories are owned by `postgres` (UID 999)
  - Strict permissions (`700`) are preserved

---

### 🏷 Versioning

- This release is tagged as **v1.0.1**
- Classified as a **PATCH release** due to controlled, intentional upgrade behavior
- Future PostgreSQL major upgrades will continue to follow documented upgrade paths

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
