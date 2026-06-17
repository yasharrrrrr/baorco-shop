@echo off
REM BAORCO Online Shop - Windows Installation Script

echo ======================================
echo BAORCO Online Shop - Setup Script
echo ======================================
echo.

REM Check Python version
echo [1/10] Checking Python version...
python --version
if errorlevel 1 (
    echo Python is not installed or not in PATH
    pause
    exit /b 1
)

REM Create virtual environment
echo [2/10] Creating virtual environment...
if not exist "venv" (
    python -m venv venv
    echo Virtual environment created
) else (
    echo Virtual environment already exists
)

REM Activate virtual environment
echo [3/10] Activating virtual environment...
call venv\Scripts\activate.bat

REM Upgrade pip
echo [4/10] Upgrading pip...
python -m pip install --upgrade pip setuptools wheel

REM Install dependencies
echo [5/10] Installing dependencies...
pip install -r requirements.txt

REM Create .env file
echo [6/10] Setting up environment variables...
if not exist ".env" (
    copy .env.example .env
    echo .env file created from .env.example
    echo Please edit .env with your configuration
) else (
    echo .env file already exists
)

REM Create necessary directories
echo [7/10] Creating necessary directories...
if not exist "logs" mkdir logs
if not exist "media" mkdir media
if not exist "staticfiles" mkdir staticfiles
if not exist "backups" mkdir backups
echo Directories created

REM Run migrations
echo [8/10] Running database migrations...
python manage.py migrate

REM Create superuser
echo [9/10] Creating superuser...
python manage.py createsuperuser

REM Collect static files
echo [10/10] Collecting static files...
python manage.py collectstatic --noinput

REM Initialize SMS templates
echo Initializing SMS templates...
python manage.py init_sms_templates

REM Initialize accounting accounts
echo Initializing accounting accounts...
python manage.py init_accounts

echo.
echo ======================================
echo Installation Complete!
echo ======================================
echo.
echo Next steps:
echo 1. Edit .env file with your configuration
echo 2. Run: python manage.py runserver
echo 3. Access: http://localhost:8000/
echo 4. Admin: http://localhost:8000/admin/
echo.
pause
