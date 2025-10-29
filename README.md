# GAMILIT Platform - Deployment Scripts

Comprehensive collection of deployment, installation, database, and CI/CD scripts for the GAMILIT Platform.

## Table of Contents

- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Script Reference](#script-reference)
  - [Setup Scripts](#setup-scripts)
  - [Database Scripts](#database-scripts)
  - [Testing Scripts](#testing-scripts)
  - [Docker Configuration](#docker-configuration)
  - [CI/CD Workflows](#cicd-workflows)
- [Deployment Guide](#deployment-guide)
- [Environment Configuration](#environment-configuration)
- [Troubleshooting](#troubleshooting)

## Overview

This repository contains all deployment and infrastructure automation scripts for the GAMILIT Platform, organized by function and purpose. All scripts have been migrated from the legacy "glit" naming to the new "gamilit" namespace.

**Migration Status:** All references to `glit_*`, `glit-*`, and `GLIT*` have been updated to `gamilit_*`, `gamilit-*`, and `GAMILIT*` respectively.

## Directory Structure

```
gamilit-deployment-scripts/
├── README.md                    # This file
├── .env.example                 # Environment variables template
│
├── scripts/                     # All automation scripts
│   ├── setup/                   # Initial setup and installation
│   ├── database/                # Database management
│   ├── deployment/              # Deployment automation (TBD)
│   ├── testing/                 # Testing and validation
│   ├── monitoring/              # Monitoring scripts (TBD)
│   └── maintenance/             # Maintenance tasks (TBD)
│
├── docker/                      # Docker configurations
│   ├── docker-compose.yml       # Multi-container orchestration
│   ├── backend/                 # Backend container config
│   │   └── Dockerfile
│   └── frontend/                # Frontend container config
│       └── Dockerfile
│
├── ci-cd/                       # CI/CD pipelines
│   └── github/                  # GitHub Actions workflows
│       └── ci.yml
│
├── config/                      # Service configurations
│   ├── nginx/                   # Nginx configs
│   │   └── nginx.conf
│   └── pm2/                     # PM2 configs (TBD)
│
└── docs/                        # Documentation
    ├── DEPLOYMENT.md            # Complete deployment guide
    └── QUICKSTART.md            # Quick start guide
```

## Prerequisites

### Required
- **Node.js** >= 18.x
- **npm** >= 9.x
- **PostgreSQL** >= 14.x

### Optional
- **Docker** >= 20.x (for containerized deployment)
- **Docker Compose** >= 2.x
- **Git** >= 2.x

### System Tools
- `bash` >= 4.x
- `openssl` (for generating secrets)
- `psql` (PostgreSQL client)

## Quick Start

### 1. Clone and Setup

```bash
# Navigate to deployment scripts
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts

# Copy environment template
cp .env.example .env

# Edit environment variables
nano .env
```

### 2. Configure Environment

Generate secure secrets:

```bash
# Generate JWT secret
openssl rand -base64 32

# Update .env with generated secret
```

### 3. Run Setup

```bash
# Full setup (installs dependencies, sets up database)
./scripts/setup/setup.sh

# Or skip specific steps
./scripts/setup/setup.sh --skip-deps    # Skip npm install
./scripts/setup/setup.sh --skip-db      # Skip database setup
```

### 4. Start Development

```bash
# Option A: Using dev-start script
./scripts/setup/dev-start.sh

# Option B: Using Docker Compose
docker-compose -f docker/docker-compose.yml up
```

## Script Reference

### Setup Scripts

Located in `scripts/setup/`

#### `setup.sh`
**Purpose:** Complete platform setup including prerequisites check, dependency installation, and database initialization.

**Usage:**
```bash
./scripts/setup/setup.sh [OPTIONS]

Options:
  --skip-deps       Skip dependency installation
  --skip-db         Skip database setup
  --help            Show help message
```

**What it does:**
- Checks system prerequisites (Node.js, PostgreSQL, Docker)
- Installs backend dependencies
- Creates environment files from templates
- Generates JWT secrets
- Runs database setup

**When to use:**
- Initial project setup
- Setting up new development environment
- After fresh clone

---

#### `dev-start.sh`
**Purpose:** Start the platform in development mode with hot-reload.

**Usage:**
```bash
./scripts/setup/dev-start.sh
```

**What it does:**
- Loads environment variables
- Starts PostgreSQL (if not running)
- Starts backend in development mode
- Provides health check URL

**When to use:**
- Daily development workflow
- After code changes
- Testing local changes

---

### Database Scripts

Located in `scripts/database/`

#### `db-setup.sh`
**Purpose:** Complete database setup including user creation, database creation, and schema initialization.

**Usage:**
```bash
./scripts/database/db-setup.sh
```

**What it does:**
- Creates `gamilit_user` PostgreSQL user
- Creates `gamilit_platform` database
- Applies DDL schema
- Sets proper permissions
- Validates setup

**When to use:**
- Initial database setup
- Reset database to clean state
- After schema changes

---

#### `db-validate.sh`
**Purpose:** Comprehensive database validation and health check.

**Usage:**
```bash
./scripts/database/db-validate.sh
```

**What it does:**
- Checks database connectivity
- Validates schema structure
- Counts tables and records
- Tests CRUD operations
- Validates foreign keys and constraints

**When to use:**
- After database setup
- Before deployment
- Troubleshooting database issues

---

#### `01_manual_db_setup.sh`
**Purpose:** Manual step-by-step database setup.

**Usage:**
```bash
./scripts/database/01_manual_db_setup.sh
```

**When to use:**
- When automated setup fails
- Custom database configuration needed
- Debugging setup issues

---

#### `02_execute_ddl.sh`
**Purpose:** Execute DDL (Data Definition Language) scripts to create schema.

**Usage:**
```bash
./scripts/database/02_execute_ddl.sh
```

**When to use:**
- Applying schema changes
- Initial schema creation
- Schema updates

---

#### `execute_all_seeds.sh`
**Purpose:** Execute all seed data scripts to populate database with initial data.

**Usage:**
```bash
./scripts/database/execute_all_seeds.sh
```

**What it does:**
- Loads reference data (game mechanics, modules)
- Creates initial users (optional)
- Populates lookup tables

**When to use:**
- After fresh database setup
- Resetting to default data
- Development environment initialization

---

#### `apply_enum_fix.sh`
**Purpose:** Apply fixes for PostgreSQL enum type issues.

**Usage:**
```bash
./scripts/database/apply_enum_fix.sh
```

**When to use:**
- Enum type conflicts
- Migration from old schema
- Enum value updates

---

#### `deploy_jwt_hash_fix.sh`
**Purpose:** Deploy fixes for JWT token hashing issues.

**Usage:**
```bash
./scripts/database/deploy_jwt_hash_fix.sh
```

**When to use:**
- Updating password hashing algorithm
- Security patches for authentication
- JWT token migration

---

#### `create_all_mechanics.sh`
**Purpose:** Create all game mechanics in the database.

**Usage:**
```bash
./scripts/database/create_all_mechanics.sh
```

**When to use:**
- Initial game mechanics setup
- Adding new mechanics
- Bulk mechanics creation

---

#### `create_remaining_mechanics.sh`
**Purpose:** Create only missing game mechanics.

**Usage:**
```bash
./scripts/database/create_remaining_mechanics.sh
```

**When to use:**
- Incremental mechanics updates
- Adding specific mechanics
- Development testing

---

### Testing Scripts

Located in `scripts/testing/`

#### `test.sh`
**Purpose:** Run complete test suite for backend.

**Usage:**
```bash
./scripts/testing/test.sh [OPTIONS]

Options:
  --unit            Run only unit tests
  --integration     Run only integration tests
  --coverage        Generate coverage report
```

**What it does:**
- Runs Jest test suite
- Generates coverage reports
- Validates API endpoints
- Tests database operations

**When to use:**
- Before commits
- Before deployment
- After code changes
- CI/CD pipeline

---

#### `health-check.sh`
**Purpose:** Comprehensive system health check.

**Usage:**
```bash
./scripts/testing/health-check.sh
```

**What it does:**
- Tests backend API health endpoint
- Checks database connectivity
- Validates environment variables
- Tests critical endpoints
- Reports system status

**When to use:**
- After deployment
- Monitoring system health
- Troubleshooting issues
- Smoke testing

---

#### `security-audit-sql-injection.sh`
**Purpose:** Audit codebase for SQL injection vulnerabilities.

**Usage:**
```bash
./scripts/testing/security-audit-sql-injection.sh
```

**What it does:**
- Scans for raw SQL queries
- Identifies potential injection points
- Reports unsafe patterns
- Suggests fixes

**When to use:**
- Security audits
- Before production deployment
- After database query changes

---

#### `validate-sql-injection-fix.sh`
**Purpose:** Validate that SQL injection fixes are properly implemented.

**Usage:**
```bash
./scripts/testing/validate-sql-injection-fix.sh
```

**When to use:**
- After applying security fixes
- Verification of parameterized queries
- Security compliance checks

---

### Docker Configuration

Located in `docker/`

#### `docker-compose.yml`
**Purpose:** Multi-container Docker orchestration for complete stack.

**Usage:**
```bash
# Start all services
docker-compose -f docker/docker-compose.yml up

# Start in background
docker-compose -f docker/docker-compose.yml up -d

# Stop services
docker-compose -f docker/docker-compose.yml down

# View logs
docker-compose -f docker/docker-compose.yml logs -f
```

**Services:**
- `gamilit-postgres`: PostgreSQL 16 database
- `gamilit-backend`: Node.js backend API

**Networks:**
- `gamilit-network`: Bridge network for inter-service communication

**Volumes:**
- `postgres_data`: Persistent database storage
- `backend_node_modules`: Node.js dependencies cache

---

#### `backend/Dockerfile`
**Purpose:** Backend container image definition.

**Stages:**
- `development`: Hot-reload enabled
- `production`: Optimized production build

---

#### `frontend/Dockerfile`
**Purpose:** Frontend container image definition.

**Build:**
- Vite-based React application
- Nginx for serving static files

---

### CI/CD Workflows

Located in `ci-cd/github/`

#### `ci.yml`
**Purpose:** GitHub Actions continuous integration workflow.

**Triggers:**
- Push to main branch
- Pull requests
- Manual workflow dispatch

**Jobs:**
1. **Lint**: Code style checks
2. **Test**: Run test suite
3. **Build**: Build application
4. **Security**: Security scans

---

## Deployment Guide

### Development Deployment

```bash
# 1. Setup environment
./scripts/setup/setup.sh

# 2. Start development server
./scripts/setup/dev-start.sh

# 3. Run tests
./scripts/testing/test.sh

# 4. Health check
./scripts/testing/health-check.sh
```

### Docker Deployment

```bash
# 1. Configure environment
cp .env.example .env
nano .env

# 2. Build and start containers
docker-compose -f docker/docker-compose.yml up --build -d

# 3. Check logs
docker-compose -f docker/docker-compose.yml logs -f

# 4. Health check
curl http://localhost:3006/api/health
```

### Production Deployment

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for complete production deployment guide.

## Environment Configuration

### Critical Variables

```bash
# Database
DB_NAME=gamilit_platform
DB_USER=gamilit_user
DB_PASSWORD=<secure-password>

# Security
JWT_SECRET=<generated-secret>
BCRYPT_ROUNDS=10

# API
PORT=3006
NODE_ENV=production
```

### Generating Secrets

```bash
# JWT Secret
openssl rand -base64 32

# Strong password
openssl rand -base64 24
```

## Execution Order

For a fresh deployment, execute scripts in this order:

1. **Setup phase**
   ```bash
   ./scripts/setup/setup.sh
   ```

2. **Database initialization**
   ```bash
   ./scripts/database/db-setup.sh
   ./scripts/database/execute_all_seeds.sh
   ```

3. **Validation**
   ```bash
   ./scripts/database/db-validate.sh
   ./scripts/testing/health-check.sh
   ```

4. **Start application**
   ```bash
   ./scripts/setup/dev-start.sh
   # or
   docker-compose -f docker/docker-compose.yml up
   ```

5. **Testing**
   ```bash
   ./scripts/testing/test.sh
   ./scripts/testing/security-audit-sql-injection.sh
   ```

## Troubleshooting

### Database Connection Issues

```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Verify database exists
psql -U gamilit_user -d gamilit_platform -c "\dt"

# Run validation
./scripts/database/db-validate.sh
```

### Permission Issues

```bash
# Make scripts executable
chmod +x scripts/**/*.sh

# Fix PostgreSQL permissions
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE gamilit_platform TO gamilit_user;"
```

### Docker Issues

```bash
# Clean restart
docker-compose -f docker/docker-compose.yml down -v
docker-compose -f docker/docker-compose.yml up --build

# Check container logs
docker logs gamilit-backend
docker logs gamilit-postgres
```

### Environment Variables

```bash
# Verify .env is loaded
cat .env | grep -v "^#" | grep -v "^$"

# Test environment
node -e "require('dotenv').config(); console.log(process.env.DB_NAME)"
```

## Additional Documentation

- **[DEPLOYMENT.md](docs/DEPLOYMENT.md)**: Complete production deployment guide
- **[QUICKSTART.md](docs/QUICKSTART.md)**: Quick start guide for developers
- **Configuration Guide**: See `.env.example` for all available options

## Scripts Summary

### By Category

**Setup (2 scripts):**
- setup.sh - Complete platform setup
- dev-start.sh - Development server start

**Database (9 scripts):**
- db-setup.sh - Full database setup
- db-validate.sh - Database validation
- 01_manual_db_setup.sh - Manual setup
- 02_execute_ddl.sh - Execute DDL
- execute_all_seeds.sh - Load seed data
- apply_enum_fix.sh - Enum type fixes
- deploy_jwt_hash_fix.sh - JWT hash fixes
- create_all_mechanics.sh - Create all mechanics
- create_remaining_mechanics.sh - Create missing mechanics

**Testing (4 scripts):**
- test.sh - Run test suite
- health-check.sh - System health check
- security-audit-sql-injection.sh - Security audit
- validate-sql-injection-fix.sh - Validate security fixes

**Docker (3 files):**
- docker-compose.yml - Container orchestration
- backend/Dockerfile - Backend image
- frontend/Dockerfile - Frontend image

**CI/CD (1 file):**
- ci-cd/github/ci.yml - GitHub Actions workflow

**Total: 19 scripts/configuration files**

## Support

For issues or questions:
1. Check [Troubleshooting](#troubleshooting) section
2. Review script output for error messages
3. Check logs: `docker-compose logs` or application logs
4. Verify environment configuration

## License

Copyright (c) 2024 GAMILIT Platform
