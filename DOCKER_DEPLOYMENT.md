# 🐳 Docker Deployment Guide for Ubuntu Server

## Prerequisites

Ensure you have the following installed on your Ubuntu server:
- Docker
- Docker Compose
- Git (optional)

### Install Docker on Ubuntu

```bash
# Update system
sudo apt update
sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add current user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

---

## Deployment Steps

### Step 1: Upload Project to Server

```bash
# Option A: Using Git
git clone https://your-repo.git /opt/baorco-shop
cd /opt/baorco-shop

# Option B: Using SCP
scp -r baorco_shop/ user@server:/opt/baorco-shop

# Option C: Upload ZIP and extract
unzip baorco_shop.zip -d /opt/
cd /opt/baorco-shop
```

### Step 2: Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit configuration
nano .env
```

**Essential .env variables for Docker:**

```
# Django
SECRET_KEY=your-very-secure-secret-key-change-this
DEBUG=False
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com,your-server-ip

# MSSQL Database (Docker service)
DB_NAME=BAORCO_Shop
DB_USER=sa
DB_PASSWORD=YourSecurePassword123!
DB_HOST=mssql
DB_PORT=1433

# SMS Configuration
SMS_API_KEY=2qAmtPjmMp7YZ6tkLNzW1nZ4AAj5nRpaA7mZacUbD85xAB4G
SMS_TEMPLATE_ID_OTP=769673
SMS_TEMPLATE_ID_ORDER=800879

# Email
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password

# CORS
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

# Security
SECURE_SSL_REDIRECT=True
SESSION_COOKIE_SECURE=True
CSRF_COOKIE_SECURE=True
```

### Step 3: Set File Permissions

```bash
# Make entrypoint script executable
chmod +x entrypoint.sh

# Set proper permissions
sudo chown -R 1000:1000 /opt/baorco-shop
```

### Step 4: Start Services with Docker Compose

```bash
# Build images
docker-compose build

# Start services in background
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f api

# Wait for services to start (approximately 30 seconds)
```

### Step 5: Verify Installation

```bash
# Check if API is running
curl http://localhost:8000/api/

# View logs if there are issues
docker-compose logs api
docker-compose logs mssql
docker-compose logs redis

# Execute Django shell in container
docker-compose exec api python manage.py shell
```

### Step 6: Access Services

After starting, access:
- 🌐 **API Documentation**: http://your-server-ip:8000/api/docs/
- 🔧 **Admin Panel**: http://your-server-ip:8000/admin/
- 📊 **API Root**: http://your-server-ip:8000/api/

**Default Admin Credentials** (created automatically):
- Username: `admin`
- Password: `admin123`
- **⚠️ Change these immediately after first login!**

---

## SSL/HTTPS Setup (Recommended for Production)

### Option 1: Using Let's Encrypt with Certbot

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get certificate
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# Update nginx.conf with SSL paths
# Edit nginx.conf and update:
# ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
# ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

# Restart services
docker-compose restart nginx
```

### Option 2: Using Self-Signed Certificate (for testing)

```bash
# Generate self-signed certificate
mkdir -p /opt/baorco-shop/nginx/ssl
cd /opt/baorco-shop/nginx/ssl

openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes

# Update docker-compose.yml to mount certificates
# Update nginx.conf paths to point to /etc/nginx/ssl/
```

---

## Database Backup

### Backup MSSQL

```bash
# Backup database
docker-compose exec mssql /opt/mssql-tools/bin/sqlcmd \
    -S localhost \
    -U sa \
    -P 'your-password' \
    -Q "BACKUP DATABASE BAORCO_Shop TO DISK = '/var/opt/mssql/backup/BAORCO_Shop.bak'"

# Retrieve backup from container
docker-compose cp mssql:/var/opt/mssql/backup/BAORCO_Shop.bak ./backups/

# Restore database
docker-compose exec mssql /opt/mssql-tools/bin/sqlcmd \
    -S localhost \
    -U sa \
    -P 'your-password' \
    -Q "RESTORE DATABASE BAORCO_Shop FROM DISK = '/var/opt/mssql/backup/BAORCO_Shop.bak'"
```

### Backup Everything

```bash
#!/bin/bash
BACKUP_DIR="/opt/baorco-shop/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

# Database backup
docker-compose exec -T mssql /opt/mssql-tools/bin/sqlcmd \
    -S localhost -U sa -P 'password' \
    -Q "BACKUP DATABASE BAORCO_Shop TO DISK = '/var/opt/mssql/backup/db.bak'"

docker-compose cp mssql:/var/opt/mssql/backup/db.bak $BACKUP_DIR/

# Media files backup
cp -r media $BACKUP_DIR/

# Keep only last 7 days
find /opt/baorco-shop/backups -type d -mtime +7 -exec rm -rf {} \;

echo "Backup completed: $BACKUP_DIR"
```

---

## Common Docker Commands

```bash
# View all running containers
docker-compose ps

# View logs
docker-compose logs -f                    # All logs
docker-compose logs -f api               # Specific service
docker-compose logs -f --tail=100        # Last 100 lines

# Execute command in container
docker-compose exec api python manage.py createsuperuser
docker-compose exec api python manage.py migrate
docker-compose exec api bash             # Access shell

# Stop all services
docker-compose stop

# Start all services
docker-compose start

# Restart services
docker-compose restart

# Remove containers (keeps volumes)
docker-compose down

# Remove everything including volumes
docker-compose down -v

# View resource usage
docker stats

# Update images
docker-compose pull
docker-compose up -d
```

---

## Monitoring & Logs

### View Application Logs

```bash
# Real-time logs
docker-compose logs -f api

# Last 50 lines
docker-compose logs --tail=50 api

# Logs with timestamps
docker-compose logs --timestamps api

# View specific time period
docker-compose logs --since 10m api
```

### Health Check

```bash
# Check API health
curl http://localhost:8000/health

# Check database
docker-compose exec api python manage.py dbshell

# Check Redis
docker-compose exec redis redis-cli ping
```

---

## Troubleshooting

### Issue: Port Already in Use

```bash
# Find what's using port 8000
lsof -i :8000

# Kill process
kill -9 <PID>

# Or change port in docker-compose.yml
# Change "8000:8000" to "8080:8000"
```

### Issue: Database Connection Failed

```bash
# Check MSSQL is running
docker-compose ps mssql

# Check logs
docker-compose logs mssql

# Verify credentials in .env
cat .env | grep DB_

# Test connection
docker-compose exec api python manage.py dbshell
```

### Issue: Static Files Not Loading

```bash
# Recollect static files
docker-compose exec api python manage.py collectstatic --noinput

# Restart nginx
docker-compose restart nginx
```

### Issue: Out of Memory

```bash
# Check system resources
free -h

# Check container resources
docker stats

# Reduce containers or increase server RAM
# Edit docker-compose.yml to reduce worker count
```

---

## Scale the Application

### Increase Gunicorn Workers

Edit `docker-compose.yml`:
```yaml
api:
  command: >
    gunicorn core.wsgi:application
    --workers 8          # Increase from 4 to 8
    --threads 2
    --worker-class sync
```

### Add Load Balancer

```bash
# Use nginx upstream to balance load
# Update nginx.conf with multiple api servers
```

---

## Maintenance Tasks

### Regular Backups

```bash
# Create daily backup cron job
crontab -e

# Add this line (runs daily at 2 AM)
0 2 * * * /opt/baorco-shop/scripts/backup.sh
```

### Update Dependencies

```bash
# Update Docker images
docker-compose pull

# Rebuild and restart
docker-compose up -d --build
```

### Database Maintenance

```bash
# Optimize database
docker-compose exec api python manage.py analyze_db

# Clear old sessions
docker-compose exec api python manage.py clearsessions

# Clear old cache
docker-compose exec api python manage.py clear_cache
```

---

## Production Checklist

- [ ] Change SECRET_KEY to random secure string
- [ ] Set DEBUG=False
- [ ] Configure ALLOWED_HOSTS
- [ ] Set up SSL/HTTPS
- [ ] Configure email service
- [ ] Test SMS functionality
- [ ] Set up regular backups
- [ ] Configure monitoring/alerts
- [ ] Set up log rotation
- [ ] Test database recovery
- [ ] Load test the application
- [ ] Set up uptime monitoring
- [ ] Configure firewall rules
- [ ] Set up auto-restart policies

---

## Support & Troubleshooting

If you encounter issues:

1. Check logs: `docker-compose logs -f`
2. Verify configuration: `cat .env`
3. Test connectivity: `curl http://localhost:8000/api/`
4. Check Docker daemon: `docker ps`
5. Rebuild if necessary: `docker-compose build --no-cache`

---

## Quick Reference

```bash
# Quick deployment summary
cd /opt/baorco-shop
cp .env.example .env
nano .env                          # Edit configuration
chmod +x entrypoint.sh
docker-compose build
docker-compose up -d
docker-compose logs -f api        # Monitor startup
# Visit http://your-server:8000/api/docs/
```

---

**Your BAORCO Online Shop is now running on Docker! 🚀**
