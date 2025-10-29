# GAMILIT Platform - Database Configuration

**Generated:** 2025-10-29 02:35:00

## Database Credentials

```bash
DB_HOST=localhost
DB_PORT=5432
DB_NAME=gamilit_platform
DB_USER=gamilit_user
DB_PASSWORD=mhXk+upgHBLuNNnRqWEzNo4i9RUvIhrj
```

## Connection String

```bash
# PostgreSQL Connection String
postgresql://gamilit_user:mhXk+upgHBLuNNnRqWEzNo4i9RUvIhrj@localhost:5432/gamilit_platform

# PSQL Command
PGPASSWORD='mhXk+upgHBLuNNnRqWEzNo4i9RUvIhrj' psql -h localhost -p 5432 -U gamilit_user -d gamilit_platform
```

## Environment Variables (.env)

```bash
DB_HOST=localhost
DB_PORT=5432
DB_NAME=gamilit_platform
DB_USER=gamilit_user
DB_PASSWORD=mhXk+upgHBLuNNnRqWEzNo4i9RUvIhrj
DB_POOL_MIN=2
DB_POOL_MAX=10
DB_SSL=false
```

## Security Notes

- **IMPORTANT:** This file contains sensitive credentials
- Add `config.md` to your `.gitignore` immediately
- Use environment variables in production
- Rotate password periodically
- Never commit this file to version control
