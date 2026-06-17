#!/bin/bash
set -e

echo "Starting BAORCO Online Shop..."

# Wait for database
echo "Waiting for database..."
python manage.py dbshell <<EOF
SELECT 1;
EOF

echo "Running migrations..."
python manage.py migrate

echo "Creating superuser if doesn't exist..."
python manage.py shell << END
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print("Superuser created: admin / admin123")
else:
    print("Superuser already exists")
END

echo "Initializing SMS templates..."
python manage.py init_sms_templates

echo "Initializing accounting accounts..."
python manage.py init_accounts

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting Gunicorn server..."
exec gunicorn core.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers 4 \
    --timeout 120 \
    --access-logfile - \
    --error-logfile - \
    --log-level info
