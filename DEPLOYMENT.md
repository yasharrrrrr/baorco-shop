# راهنمای استقرار (Deployment Guide)

## استقرار محیط Production

### 1. استقرار با Docker Compose

#### الف) دستورات اولیه

```bash
# کلون کردن پروژه
git clone https://github.com/yourusername/baorco-shop.git
cd baorco-shop

# تنظیم فایل .env
cp .env.example .env

# ویرایش .env برای تنظیمات Production
nano .env
```

#### ب) تغییرات مورد نیاز در .env:

```
DEBUG=False
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
SECRET_KEY=your-very-secure-random-key-here
DB_PASSWORD=your-very-secure-password
SECURE_SSL_REDIRECT=True
SESSION_COOKIE_SECURE=True
CSRF_COOKIE_SECURE=True
```

#### ج) اجرای Docker Compose

```bash
# ایجاد و شروع کانتینرها
docker-compose up -d

# بررسی وضعیت کانتینرها
docker-compose ps

# مشاهده لاگ‌ها
docker-compose logs -f api

# اجرای Migration
docker-compose exec api python manage.py migrate

# ایجاد Super User
docker-compose exec api python manage.py createsuperuser

# جمع‌آوری Static Files
docker-compose exec api python manage.py collectstatic --noinput
```

---

### 2. استقرار بر روی سرور Linux (Ubuntu 20.04+)

#### الف) نصب پیش‌نیازها

```bash
# بروزرسانی سیستم
sudo apt update
sudo apt upgrade -y

# نصب Python و وابستگی‌ها
sudo apt install -y python3.11 python3.11-venv python3.11-dev
sudo apt install -y postgresql postgresql-contrib
sudo apt install -y redis-server
sudo apt install -y nginx
sudo apt install -y supervisor
sudo apt install -y curl git

# نصب MSSQL ODBC Driver
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | \
  sudo tee /etc/apt/sources.list.d/mssql-release.list
sudo apt update
sudo ACCEPT_EULA=Y apt install -y msodbcsql17 unixodbc-dev
```

#### ب) راه‌اندازی پروژه

```bash
# ایجاد دایرکتوری
mkdir -p /var/www/baorco-shop
cd /var/www/baorco-shop

# کلون کردن پروژه
git clone https://github.com/yourusername/baorco-shop.git .

# ایجاد Virtual Environment
python3.11 -m venv venv
source venv/bin/activate

# نصب وابستگی‌ها
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
pip install gunicorn

# تنظیم .env
cp .env.example .env
nano .env
```

#### ج) تنظیم پایگاه داده

```bash
# اگر استفاده از MSSQL:
# تنظیمات MSSQL Server را در .env قرار دهید

# اگر استفاده از PostgreSQL:
sudo -u postgres psql
CREATE DATABASE baorco_shop;
CREATE USER baorco WITH PASSWORD 'your_password';
ALTER ROLE baorco SET client_encoding TO 'utf8';
ALTER ROLE baorco SET default_transaction_isolation TO 'read committed';
ALTER ROLE baorco SET default_transaction_deferrable TO on;
ALTER ROLE baorco SET timezone TO 'Asia/Tehran';
GRANT ALL PRIVILEGES ON DATABASE baorco_shop TO baorco;
\q
```

#### د) اجرای Migration

```bash
python manage.py migrate
python manage.py createsuperuser
python manage.py collectstatic --noinput
```

---

### 3. تنظیم Systemd Services

#### الف) Gunicorn Service

```bash
sudo nano /etc/systemd/system/baorco-gunicorn.service
```

محتوا:
```ini
[Unit]
Description=BAORCO Gunicorn Application Server
After=network.target
Wants=baorco-redis.service

[Service]
Type=notify
User=www-data
Group=www-data
WorkingDirectory=/var/www/baorco-shop
Environment="PATH=/var/www/baorco-shop/venv/bin"
ExecStart=/var/www/baorco-shop/venv/bin/gunicorn \
    --workers 4 \
    --worker-class uvicorn.workers.UvicornWorker \
    --bind unix:/var/www/baorco-shop/gunicorn.sock \
    --access-logfile /var/log/baorco/access.log \
    --error-logfile /var/log/baorco/error.log \
    --log-level info \
    core.wsgi:application

[Install]
WantedBy=multi-user.target
```

#### ب) Celery Worker Service

```bash
sudo nano /etc/systemd/system/baorco-celery.service
```

محتوا:
```ini
[Unit]
Description=BAORCO Celery Service
After=network.target baorco-redis.service

[Service]
Type=forking
User=www-data
Group=www-data
WorkingDirectory=/var/www/baorco-shop
Environment="PATH=/var/www/baorco-shop/venv/bin"
ExecStart=/var/www/baorco-shop/venv/bin/celery -A core worker \
    --loglevel=info \
    --logfile=/var/log/baorco/celery.log \
    --pidfile=/var/run/celery.pid \
    --detach

[Install]
WantedBy=multi-user.target
```

#### ج) Celery Beat Service

```bash
sudo nano /etc/systemd/system/baorco-celery-beat.service
```

محتوا:
```ini
[Unit]
Description=BAORCO Celery Beat Scheduler
After=network.target baorco-redis.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/baorco-shop
Environment="PATH=/var/www/baorco-shop/venv/bin"
ExecStart=/var/www/baorco-shop/venv/bin/celery -A core beat \
    --loglevel=info \
    --logfile=/var/log/baorco/celery-beat.log

[Install]
WantedBy=multi-user.target
```

#### د) فعال‌سازی Services

```bash
# ایجاد لاگ دایرکتوری
sudo mkdir -p /var/log/baorco
sudo chown www-data:www-data /var/log/baorco

# فعال‌سازی و شروع Services
sudo systemctl daemon-reload
sudo systemctl enable baorco-gunicorn.service
sudo systemctl enable baorco-celery.service
sudo systemctl enable baorco-celery-beat.service

sudo systemctl start baorco-gunicorn.service
sudo systemctl start baorco-celery.service
sudo systemctl start baorco-celery-beat.service

# بررسی وضعیت
sudo systemctl status baorco-gunicorn.service
sudo systemctl status baorco-celery.service
sudo systemctl status baorco-celery-beat.service
```

---

### 4. تنظیم Nginx Reverse Proxy

```bash
sudo nano /etc/nginx/sites-available/baorco-shop
```

محتوا:
```nginx
upstream baorco_app {
    server unix:/var/www/baorco-shop/gunicorn.sock fail_timeout=0;
}

server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;
    
    # SSL Certificate
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    
    # SSL Configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    client_max_body_size 100M;
    
    location / {
        proxy_pass http://baorco_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
    }
    
    location /static/ {
        alias /var/www/baorco-shop/staticfiles/;
        expires 30d;
    }
    
    location /media/ {
        alias /var/www/baorco-shop/media/;
        expires 7d;
    }
    
    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

#### فعال‌سازی Nginx Configuration

```bash
sudo ln -s /etc/nginx/sites-available/baorco-shop /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

### 5. SSL Certificate با Let's Encrypt

```bash
# نصب Certbot
sudo apt install -y certbot python3-certbot-nginx

# دریافت Certificate
sudo certbot certonly --nginx -d yourdomain.com -d www.yourdomain.com

# تجدید خودکار (هر 90 روز)
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```

---

### 6. Backup و Recovery

#### الف) Backup Database

```bash
# MSSQL Backup
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'password' \
    -Q "BACKUP DATABASE BAORCO_Shop TO DISK = '/var/backups/BAORCO_Shop.bak'"

# PostgreSQL Backup
pg_dump -U baorco baorco_shop > /var/backups/baorco_shop_$(date +%Y%m%d).sql
```

#### ب) Backup Media Files

```bash
tar -czf /var/backups/media_$(date +%Y%m%d).tar.gz /var/www/baorco-shop/media/
```

#### ج) Backup Script

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/baorco"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Database Backup
pg_dump -U baorco baorco_shop > $BACKUP_DIR/db_$DATE.sql
gzip $BACKUP_DIR/db_$DATE.sql

# Media Backup
tar -czf $BACKUP_DIR/media_$DATE.tar.gz \
    /var/www/baorco-shop/media/

# Keep last 7 days
find $BACKUP_DIR -mtime +7 -delete
```

---

### 7. Monitoring و Logging

#### الف) Logrotate Configuration

```bash
sudo nano /etc/logrotate.d/baorco
```

محتوا:
```
/var/log/baorco/*.log {
    daily
    rotate 30
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
    sharedscripts
    postrotate
        systemctl reload nginx
    endscript
}
```

#### ب) Monitoring with Systemd

```bash
# بررسی وضعیت Services
systemctl status baorco-*

# مشاهده لاگ‌ها
journalctl -u baorco-gunicorn.service -f
journalctl -u baorco-celery.service -f
```

---

### 8. Health Check

```bash
# بررسی API
curl -I https://yourdomain.com/api/docs/

# بررسی Database Connection
curl https://yourdomain.com/api/products/

# بررسی Services
ps aux | grep gunicorn
ps aux | grep celery
redis-cli ping
```

---

## Troubleshooting

### خطای Permission Denied
```bash
sudo chown -R www-data:www-data /var/www/baorco-shop
sudo chmod -R 755 /var/www/baorco-shop
```

### خطای Database Connection
```bash
# بررسی MSSQL Service
sudo systemctl status mssql-server

# بررسی PostgreSQL
sudo systemctl status postgresql
```

### خطای Redis
```bash
# بررسی Redis
redis-cli ping

# اگر NOAUTH خطا:
redis-cli CONFIG SET requirepass ""
```

---

## Performance Optimization

### 1. Caching

```python
# در settings.py
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
    }
}
```

### 2. Database Indexing

```bash
# مطمئن شوید تمام indexes اعمال شده‌اند
python manage.py migrate
```

### 3. Gunicorn Workers

```bash
# بر اساس CPU cores: (2 x CPU cores) + 1
workers = 4 * 2 + 1  # برای 4 CPU cores = 9 workers
```

---

## نتیجه‌گیری

پروژه اکنون برای Production آماده است!

برای هر سوالی یا مشکل، لطفاً با تیم توسعه تماس بگیرید.
