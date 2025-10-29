# GAMILIT Platform - Production Deployment Guide

Complete guide for deploying the GAMILIT Platform to production environments.

## Table of Contents

- [Overview](#overview)
- [Pre-Deployment Checklist](#pre-deployment-checklist)
- [Infrastructure Requirements](#infrastructure-requirements)
- [Deployment Methods](#deployment-methods)
  - [Method 1: Docker Deployment](#method-1-docker-deployment-recommended)
  - [Method 2: Traditional Server Deployment](#method-2-traditional-server-deployment)
  - [Method 3: Cloud Platform Deployment](#method-3-cloud-platform-deployment)
- [Security Hardening](#security-hardening)
- [Monitoring and Logging](#monitoring-and-logging)
- [Backup and Recovery](#backup-and-recovery)
- [Scaling Considerations](#scaling-considerations)
- [Troubleshooting](#troubleshooting)

---

## Overview

This guide covers production-ready deployment of the GAMILIT Platform with focus on:
- Security best practices
- High availability
- Performance optimization
- Disaster recovery
- Monitoring and alerting

**Target Environments:**
- Production servers (VPS, dedicated)
- Cloud platforms (AWS, Azure, GCP, DigitalOcean)
- Kubernetes clusters
- Docker Swarm

---

## Pre-Deployment Checklist

### Security

- [ ] All secrets generated securely (JWT, database passwords)
- [ ] SSL/TLS certificates obtained and configured
- [ ] Firewall rules configured
- [ ] Security headers enabled
- [ ] CORS properly configured
- [ ] Rate limiting enabled
- [ ] SQL injection protection verified
- [ ] Input validation enabled
- [ ] Authentication system tested
- [ ] Password hashing verified (bcrypt)

### Configuration

- [ ] Environment variables set for production
- [ ] Database connection pooling configured
- [ ] Logging level set appropriately (info/warn)
- [ ] Error tracking configured (Sentry, etc.)
- [ ] Monitoring tools configured
- [ ] Backup strategy defined
- [ ] CI/CD pipeline tested
- [ ] Health check endpoints working

### Testing

- [ ] All unit tests passing
- [ ] Integration tests passing
- [ ] Security audit completed
- [ ] Load testing performed
- [ ] Penetration testing completed
- [ ] Database migrations tested
- [ ] Rollback procedure tested

### Documentation

- [ ] API documentation updated
- [ ] Deployment procedures documented
- [ ] Incident response plan created
- [ ] Runbook prepared
- [ ] Contact information updated

---

## Infrastructure Requirements

### Minimum Requirements

**Backend Server:**
- CPU: 2 cores
- RAM: 4 GB
- Storage: 20 GB SSD
- OS: Ubuntu 20.04+ / Debian 11+

**Database Server:**
- CPU: 2 cores
- RAM: 4 GB
- Storage: 50 GB SSD (with room for growth)
- PostgreSQL 14+

**Network:**
- Bandwidth: 100 Mbps
- SSL/TLS enabled
- DDoS protection recommended

### Recommended Requirements

**Backend Server:**
- CPU: 4+ cores
- RAM: 8 GB
- Storage: 50 GB SSD
- Load balancer ready

**Database Server:**
- CPU: 4+ cores
- RAM: 8 GB+
- Storage: 100 GB+ SSD with automatic scaling
- Read replicas for scaling

**Additional:**
- Redis for session storage
- CDN for static assets
- Backup storage (separate location)

---

## Deployment Methods

### Method 1: Docker Deployment (Recommended)

#### Prerequisites

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### Step 1: Prepare Environment

```bash
# Clone or upload deployment scripts
cd /opt/gamilit
git clone <repository-url> deployment-scripts

cd deployment-scripts

# Create production .env
cp .env.example .env.production
```

#### Step 2: Configure Production Environment

Edit `.env.production`:

```env
# Application
NODE_ENV=production
PORT=3006

# Database (use strong passwords!)
DB_HOST=postgres
DB_PORT=5432
DB_NAME=gamilit_platform
DB_USER=gamilit_user
DB_PASSWORD=<SECURE_PASSWORD_HERE>
DB_POOL_MIN=5
DB_POOL_MAX=20
DB_SSL=true

# Security (CRITICAL!)
JWT_SECRET=<SECURE_RANDOM_SECRET>
BCRYPT_ROUNDS=12

# CORS (set to your frontend domain)
CORS_ORIGIN=https://yourdomain.com

# Rate Limiting (adjust based on traffic)
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Logging
LOG_LEVEL=info
```

#### Step 3: Generate Secrets

```bash
# Generate JWT secret
openssl rand -base64 64

# Generate database password
openssl rand -base64 32

# Update .env.production with these values
```

#### Step 4: Modify docker-compose for Production

Create `docker-compose.production.yml`:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: gamilit-postgres
    restart: always
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - gamilit-network
    # Don't expose port externally in production
    expose:
      - "5432"

  backend:
    build:
      context: ../../gamilit-backend
      dockerfile: Dockerfile
      target: production
    container_name: gamilit-backend
    restart: always
    env_file:
      - .env.production
    depends_on:
      - postgres
    networks:
      - gamilit-network
    # Use reverse proxy, don't expose directly
    expose:
      - "3006"
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3006/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  nginx:
    image: nginx:alpine
    container_name: gamilit-nginx
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./config/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./config/nginx/ssl:/etc/nginx/ssl:ro
      - /etc/letsencrypt:/etc/letsencrypt:ro
    depends_on:
      - backend
    networks:
      - gamilit-network

volumes:
  postgres_data:
    driver: local

networks:
  gamilit-network:
    driver: bridge
```

#### Step 5: Configure Nginx Reverse Proxy

Create `config/nginx/nginx.conf`:

```nginx
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:3006;
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

    server {
        listen 80;
        server_name yourdomain.com;

        # Redirect to HTTPS
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name yourdomain.com;

        # SSL Configuration
        ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        # Security Headers
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;

        # API Proxy
        location /api {
            limit_req zone=api_limit burst=20 nodelay;

            proxy_pass http://backend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
        }

        # Health check (no rate limit)
        location /api/health {
            proxy_pass http://backend;
            access_log off;
        }
    }
}
```

#### Step 6: Setup SSL with Let's Encrypt

```bash
# Install certbot
sudo apt-get update
sudo apt-get install certbot

# Obtain certificate
sudo certbot certonly --standalone -d yourdomain.com

# Setup auto-renewal
sudo crontab -e
# Add: 0 0 1 * * certbot renew --quiet
```

#### Step 7: Deploy

```bash
# Build and start services
docker-compose -f docker-compose.production.yml up -d --build

# Check status
docker-compose -f docker-compose.production.yml ps

# View logs
docker-compose -f docker-compose.production.yml logs -f
```

#### Step 8: Initialize Database

```bash
# Run database setup
docker-compose -f docker-compose.production.yml exec backend npm run db:setup

# Apply migrations
docker-compose -f docker-compose.production.yml exec backend npm run db:migrate

# Load seed data (if needed)
docker-compose -f docker-compose.production.yml exec backend npm run db:seed
```

#### Step 9: Verify Deployment

```bash
# Check health
curl https://yourdomain.com/api/health

# Test API
curl https://yourdomain.com/api

# Check container health
docker-compose -f docker-compose.production.yml ps
```

---

### Method 2: Traditional Server Deployment

#### Prerequisites

```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PostgreSQL
sudo apt-get install postgresql postgresql-contrib

# Install Nginx
sudo apt-get install nginx

# Install PM2 (process manager)
sudo npm install -g pm2
```

#### Step 1: Setup Database

```bash
# Switch to postgres user
sudo -u postgres psql

# Create user and database
CREATE USER gamilit_user WITH PASSWORD 'secure_password_here';
CREATE DATABASE gamilit_platform OWNER gamilit_user;
GRANT ALL PRIVILEGES ON DATABASE gamilit_platform TO gamilit_user;

# Enable SSL
ALTER SYSTEM SET ssl = on;
SELECT pg_reload_conf();

\q
```

#### Step 2: Deploy Backend

```bash
# Create application directory
sudo mkdir -p /var/www/gamilit
sudo chown $USER:$USER /var/www/gamilit

# Clone/copy backend code
cd /var/www/gamilit
git clone <repository-url> backend
cd backend

# Install dependencies
npm ci --production

# Build
npm run build
```

#### Step 3: Configure Environment

```bash
# Create .env
nano .env

# Add production configuration (see earlier example)
```

#### Step 4: Setup PM2

Create `ecosystem.config.js`:

```javascript
module.exports = {
  apps: [{
    name: 'gamilit-backend',
    script: './dist/index.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3006
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    max_memory_restart: '1G',
    autorestart: true,
    max_restarts: 10,
    min_uptime: '10s'
  }]
};
```

Start with PM2:

```bash
# Start application
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup systemd
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u $USER --hp /home/$USER

# Check status
pm2 status
pm2 logs
```

#### Step 5: Configure Nginx

```bash
# Create Nginx configuration
sudo nano /etc/nginx/sites-available/gamilit

# Add configuration (see Nginx example above)

# Enable site
sudo ln -s /etc/nginx/sites-available/gamilit /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

#### Step 6: Setup Firewall

```bash
# Allow SSH
sudo ufw allow OpenSSH

# Allow HTTP and HTTPS
sudo ufw allow 'Nginx Full'

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

---

### Method 3: Cloud Platform Deployment

#### AWS Elastic Beanstalk

```bash
# Install EB CLI
pip install awsebcli

# Initialize
eb init -p node.js-18 gamilit-backend

# Create environment
eb create gamilit-production

# Deploy
eb deploy

# Check status
eb status
```

#### Google Cloud Run

```bash
# Build container
gcloud builds submit --tag gcr.io/PROJECT_ID/gamilit-backend

# Deploy
gcloud run deploy gamilit-backend \
  --image gcr.io/PROJECT_ID/gamilit-backend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

#### DigitalOcean App Platform

```yaml
# .do/app.yaml
name: gamilit-platform
services:
  - name: backend
    github:
      repo: your-org/gamilit-backend
      branch: main
    build_command: npm run build
    run_command: npm start
    envs:
      - key: NODE_ENV
        value: production
    instance_count: 2
    instance_size_slug: professional-xs

databases:
  - name: gamilit-db
    engine: PG
    version: "14"
```

---

## Security Hardening

### Application Security

```bash
# 1. Use Helmet.js for security headers
npm install helmet

# 2. Enable HTTPS only
# 3. Implement rate limiting
# 4. Use parameterized queries (prevent SQL injection)
# 5. Validate all inputs
# 6. Implement CSRF protection
# 7. Use secure session management
```

### Database Security

```sql
-- Revoke public access
REVOKE ALL ON DATABASE gamilit_platform FROM PUBLIC;

-- Grant only necessary permissions
GRANT CONNECT ON DATABASE gamilit_platform TO gamilit_user;
GRANT USAGE ON SCHEMA public TO gamilit_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO gamilit_user;

-- Enable SSL only connections
ALTER SYSTEM SET ssl = on;
ALTER SYSTEM SET ssl_min_protocol_version = 'TLSv1.2';
```

### Server Security

```bash
# 1. Keep system updated
sudo apt-get update && sudo apt-get upgrade -y

# 2. Disable root login
sudo nano /etc/ssh/sshd_config
# Set: PermitRootLogin no

# 3. Use SSH keys only
# Set: PasswordAuthentication no

# 4. Install fail2ban
sudo apt-get install fail2ban

# 5. Regular security audits
sudo apt-get install lynis
sudo lynis audit system
```

---

## Monitoring and Logging

### Setup Logging

```bash
# Install Winston for structured logging
npm install winston winston-daily-rotate-file

# Configure log rotation
sudo nano /etc/logrotate.d/gamilit
```

Example logrotate config:

```
/var/www/gamilit/backend/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
    sharedscripts
    postrotate
        pm2 reloadLogs
    endscript
}
```

### Setup Monitoring

**Prometheus + Grafana:**

```bash
# Install Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.40.0/prometheus-2.40.0.linux-amd64.tar.gz
tar xvf prometheus-2.40.0.linux-amd64.tar.gz
cd prometheus-2.40.0.linux-amd64
./prometheus --config.file=prometheus.yml

# Install Grafana
sudo apt-get install -y grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

**PM2 Monitoring:**

```bash
# Enable PM2 monitoring
pm2 install pm2-server-monit

# Web monitoring
pm2 monitor
```

### Health Checks

Setup automated health checks:

```bash
# Create health check script
nano /usr/local/bin/gamilit-healthcheck.sh
```

```bash
#!/bin/bash
HEALTH_URL="https://yourdomain.com/api/health"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $HEALTH_URL)

if [ $RESPONSE != "200" ]; then
    echo "Health check failed! Status: $RESPONSE"
    # Send alert (email, Slack, PagerDuty, etc.)
    # pm2 restart gamilit-backend
fi
```

```bash
# Make executable
chmod +x /usr/local/bin/gamilit-healthcheck.sh

# Add to crontab (every 5 minutes)
*/5 * * * * /usr/local/bin/gamilit-healthcheck.sh
```

---

## Backup and Recovery

### Database Backup

```bash
# Create backup script
nano /usr/local/bin/gamilit-backup.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/gamilit"
DATE=$(date +%Y%m%d_%H%M%S)
FILENAME="gamilit_platform_${DATE}.sql.gz"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
pg_dump -U gamilit_user -h localhost gamilit_platform | gzip > $BACKUP_DIR/$FILENAME

# Keep only last 30 days
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete

# Upload to S3 (optional)
# aws s3 cp $BACKUP_DIR/$FILENAME s3://your-bucket/backups/
```

```bash
# Make executable
chmod +x /usr/local/bin/gamilit-backup.sh

# Schedule daily at 2 AM
crontab -e
0 2 * * * /usr/local/bin/gamilit-backup.sh
```

### Recovery

```bash
# Restore from backup
gunzip -c /var/backups/gamilit/backup.sql.gz | psql -U gamilit_user -d gamilit_platform
```

---

## Scaling Considerations

### Horizontal Scaling

```bash
# Use PM2 cluster mode
pm2 start app.js -i max

# Use load balancer (Nginx, HAProxy)
# Setup multiple backend instances
# Use session storage (Redis)
```

### Database Scaling

```sql
-- Setup read replicas
-- Implement connection pooling (PgBouncer)
-- Use database caching (Redis)
-- Optimize queries and indexes
```

### Caching Strategy

```bash
# Install Redis
sudo apt-get install redis-server

# Configure Redis for session storage
npm install connect-redis express-session
```

---

## Troubleshooting

### Common Issues

**Issue: Out of memory**
```bash
# Check memory usage
pm2 monit

# Increase Node.js memory
node --max-old-space-size=4096 app.js
```

**Issue: Database connection pool exhausted**
```bash
# Increase pool size in .env
DB_POOL_MAX=50

# Check active connections
SELECT count(*) FROM pg_stat_activity;
```

**Issue: Slow API responses**
```bash
# Enable query logging
# Analyze slow queries
# Add database indexes
# Implement caching
```

---

## Rollback Procedure

```bash
# 1. Stop current version
pm2 stop gamilit-backend

# 2. Restore previous version
cd /var/www/gamilit/backend
git checkout <previous-version-tag>
npm ci --production
npm run build

# 3. Restore database if needed
gunzip -c backup.sql.gz | psql -U gamilit_user -d gamilit_platform

# 4. Restart application
pm2 restart gamilit-backend

# 5. Verify
curl https://yourdomain.com/api/health
```

---

## Post-Deployment

1. **Monitor for 24-48 hours**
   - Watch error logs
   - Monitor performance metrics
   - Check health endpoints

2. **Performance Testing**
   - Run load tests
   - Monitor response times
   - Check database performance

3. **Security Audit**
   - Run security scans
   - Check for vulnerabilities
   - Verify SSL/TLS configuration

4. **Documentation**
   - Update deployment notes
   - Document any issues encountered
   - Update runbook

---

## Support and Maintenance

**Regular Maintenance Tasks:**
- Daily: Monitor logs and metrics
- Weekly: Review security alerts
- Monthly: Update dependencies
- Quarterly: Security audit
- Yearly: Disaster recovery drill

**Contact Information:**
- DevOps Team: devops@yourdomain.com
- On-call: Use PagerDuty/OpsGenie
- Documentation: https://docs.yourdomain.com

---

## Conclusion

This deployment guide provides comprehensive instructions for production deployment. Always test in staging environment before production deployment.

**Remember:**
- Security first
- Monitor everything
- Have backup and rollback plans ready
- Document all changes
- Test disaster recovery procedures

Good luck with your deployment! 🚀
