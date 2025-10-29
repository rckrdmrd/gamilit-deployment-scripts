# GAMILIT Platform - Quick Start Guide

Get up and running with the GAMILIT Platform in under 10 minutes!

## Prerequisites Check

Before starting, ensure you have:

```bash
# Check Node.js (need >= 18.x)
node -v

# Check npm
npm -v

# Check PostgreSQL
psql --version

# Check Docker (optional)
docker --version
docker-compose --version
```

## Option 1: Automated Setup (Recommended)

### Step 1: Navigate to Deployment Scripts

```bash
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts
```

### Step 2: Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Generate JWT secret
openssl rand -base64 32

# Edit .env and paste the JWT secret
nano .env
```

**Required changes in .env:**
- `JWT_SECRET` - paste the generated secret
- `DB_PASSWORD` - set a secure password (optional, has default)

### Step 3: Run Setup

```bash
# This will:
# - Check prerequisites
# - Install dependencies
# - Create database
# - Apply schema
./scripts/setup/setup.sh
```

### Step 4: Start Development Server

```bash
./scripts/setup/dev-start.sh
```

### Step 5: Verify

```bash
# Check health
curl http://localhost:3006/api/health

# Should return: {"status":"healthy","database":"connected"}
```

Done! Your backend is running at `http://localhost:3006`

---

## Option 2: Docker Setup (Simplest)

### Step 1: Configure Environment

```bash
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts

# Copy and edit environment
cp .env.example .env
nano .env  # Set JWT_SECRET and DB_PASSWORD
```

### Step 2: Start with Docker

```bash
# Build and start all services
docker-compose -f docker/docker-compose.yml up --build

# Or run in background
docker-compose -f docker/docker-compose.yml up -d
```

### Step 3: Verify

```bash
# Check container status
docker-compose -f docker/docker-compose.yml ps

# Check health
curl http://localhost:3006/api/health

# View logs
docker-compose -f docker/docker-compose.yml logs -f
```

### Stop Services

```bash
docker-compose -f docker/docker-compose.yml down
```

---

## Option 3: Manual Setup (Advanced)

### Step 1: Install Dependencies

```bash
# Backend dependencies
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-backend
npm install
```

### Step 2: Setup Database

```bash
# Switch to postgres user
sudo -u postgres psql

# In PostgreSQL:
CREATE USER gamilit_user WITH PASSWORD 'your_secure_password';
CREATE DATABASE gamilit_platform OWNER gamilit_user;
GRANT ALL PRIVILEGES ON DATABASE gamilit_platform TO gamilit_user;
\q
```

### Step 3: Configure Environment

```bash
# Backend .env
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-backend
cp .env.example .env

# Edit with your settings
nano .env
```

### Step 4: Apply Database Schema

```bash
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts
./scripts/database/02_execute_ddl.sh
./scripts/database/execute_all_seeds.sh
```

### Step 5: Start Backend

```bash
cd /home/isem/workspace/workspace-gamilit/projects/gamilit-backend
npm run dev
```

---

## Common Commands

### Development

```bash
# Start development server
./scripts/setup/dev-start.sh

# Run tests
./scripts/testing/test.sh

# Check health
./scripts/testing/health-check.sh

# Validate database
./scripts/database/db-validate.sh
```

### Docker

```bash
# Start services
docker-compose -f docker/docker-compose.yml up

# Stop services
docker-compose -f docker/docker-compose.yml down

# View logs
docker-compose -f docker/docker-compose.yml logs -f [service-name]

# Rebuild images
docker-compose -f docker/docker-compose.yml up --build
```

### Database

```bash
# Setup database
./scripts/database/db-setup.sh

# Load seed data
./scripts/database/execute_all_seeds.sh

# Validate setup
./scripts/database/db-validate.sh

# Create game mechanics
./scripts/database/create_all_mechanics.sh
```

---

## API Endpoints

Once running, try these endpoints:

```bash
# Health check
curl http://localhost:3006/api/health

# API info
curl http://localhost:3006/api

# List users (requires auth)
curl http://localhost:3006/api/users

# Login example
curl -X POST http://localhost:3006/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

---

## Troubleshooting

### Port Already in Use

```bash
# Find process using port 3006
lsof -i :3006

# Kill process
kill -9 <PID>
```

### Database Connection Failed

```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Start PostgreSQL
sudo systemctl start postgresql

# Verify credentials
psql -U gamilit_user -d gamilit_platform -h localhost
```

### Permission Denied on Scripts

```bash
# Make scripts executable
chmod +x /home/isem/workspace/workspace-gamilit/projects/gamilit-deployment-scripts/scripts/**/*.sh
```

### Docker Issues

```bash
# Clean everything
docker-compose -f docker/docker-compose.yml down -v

# Remove dangling images
docker system prune -a

# Rebuild from scratch
docker-compose -f docker/docker-compose.yml up --build --force-recreate
```

### Environment Variables Not Loading

```bash
# Verify .env exists
ls -la .env

# Check .env content (hide passwords)
cat .env | grep -v PASSWORD

# Load manually
export $(cat .env | grep -v '^#' | xargs)
```

---

## Next Steps

After quick start, explore:

1. **Read Documentation**
   - [README.md](../README.md) - Complete script reference
   - [DEPLOYMENT.md](DEPLOYMENT.md) - Production deployment

2. **Explore API**
   - Test endpoints with Postman or curl
   - Review API documentation
   - Try authenticated requests

3. **Run Tests**
   ```bash
   ./scripts/testing/test.sh
   ./scripts/testing/security-audit-sql-injection.sh
   ```

4. **Setup Frontend**
   - Navigate to frontend project
   - Follow frontend setup guide
   - Connect to backend API

5. **Development Workflow**
   - Make code changes
   - Run tests before commit
   - Use health-check for debugging

---

## Essential Environment Variables

Minimum required variables:

```env
# Database
DB_NAME=gamilit_platform
DB_USER=gamilit_user
DB_PASSWORD=your_secure_password_here

# Backend
PORT=3006
NODE_ENV=development

# Security (REQUIRED!)
JWT_SECRET=your_jwt_secret_here_use_openssl_rand
```

Generate secure values:

```bash
# JWT Secret
openssl rand -base64 32

# Database Password
openssl rand -base64 24
```

---

## Development Tips

1. **Always run health check after changes**
   ```bash
   ./scripts/testing/health-check.sh
   ```

2. **Use Docker for isolated environment**
   - Prevents conflicts with system PostgreSQL
   - Easy cleanup and reset

3. **Keep tests green**
   ```bash
   npm test -- --watch
   ```

4. **Monitor logs in separate terminal**
   ```bash
   # Terminal 1: Run server
   npm run dev

   # Terminal 2: Watch logs
   tail -f logs/app.log
   ```

5. **Reset database when needed**
   ```bash
   ./scripts/database/db-setup.sh
   ./scripts/database/execute_all_seeds.sh
   ```

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────┐
│ GAMILIT Platform Quick Reference                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Setup:        ./scripts/setup/setup.sh                 │
│ Start:        ./scripts/setup/dev-start.sh             │
│ Test:         ./scripts/testing/test.sh                │
│ Health:       ./scripts/testing/health-check.sh        │
│                                                         │
│ Docker Up:    docker-compose -f docker/... up          │
│ Docker Down:  docker-compose -f docker/... down        │
│                                                         │
│ DB Setup:     ./scripts/database/db-setup.sh           │
│ DB Validate:  ./scripts/database/db-validate.sh        │
│ DB Seeds:     ./scripts/database/execute_all_seeds.sh  │
│                                                         │
│ Backend:      http://localhost:3006                    │
│ Health:       http://localhost:3006/api/health         │
│ API Docs:     http://localhost:3006/api                │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Getting Help

1. Check script output for error messages
2. Review logs in backend directory
3. Run health-check script for diagnostics
4. Check [Troubleshooting](#troubleshooting) section
5. Review full [README.md](../README.md)

Happy coding! 🚀
