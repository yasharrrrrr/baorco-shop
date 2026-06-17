#!/bin/bash

# BAORCO Online Shop - Installation Script
# This script automates the setup process

set -e

echo "======================================"
echo "BAORCO Online Shop - Setup Script"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Python version
echo -e "${YELLOW}[1/10] Checking Python version...${NC}"
python_version=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+')
echo "Python version: $python_version"

# Create virtual environment
echo -e "${YELLOW}[2/10] Creating virtual environment...${NC}"
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo -e "${GREEN}Virtual environment created${NC}"
else
    echo -e "${YELLOW}Virtual environment already exists${NC}"
fi

# Activate virtual environment
echo -e "${YELLOW}[3/10] Activating virtual environment...${NC}"
source venv/bin/activate

# Upgrade pip
echo -e "${YELLOW}[4/10] Upgrading pip...${NC}"
pip install --upgrade pip setuptools wheel

# Install dependencies
echo -e "${YELLOW}[5/10] Installing dependencies...${NC}"
pip install -r requirements.txt

# Create .env file
echo -e "${YELLOW}[6/10] Setting up environment variables...${NC}"
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo -e "${GREEN}.env file created from .env.example${NC}"
    echo -e "${YELLOW}Please edit .env with your configuration${NC}"
else
    echo -e "${YELLOW}.env file already exists${NC}"
fi

# Create necessary directories
echo -e "${YELLOW}[7/10] Creating necessary directories...${NC}"
mkdir -p logs
mkdir -p media
mkdir -p staticfiles
mkdir -p backups
echo -e "${GREEN}Directories created${NC}"

# Run migrations
echo -e "${YELLOW}[8/10] Running database migrations...${NC}"
python manage.py migrate

# Create superuser
echo -e "${YELLOW}[9/10] Creating superuser...${NC}"
python manage.py createsuperuser

# Collect static files
echo -e "${YELLOW}[10/10] Collecting static files...${NC}"
python manage.py collectstatic --noinput

# Initialize SMS templates
echo -e "${YELLOW}Initializing SMS templates...${NC}"
python manage.py init_sms_templates

# Initialize accounting accounts
echo -e "${YELLOW}Initializing accounting accounts...${NC}"
python manage.py init_accounts

echo ""
echo -e "${GREEN}======================================"
echo "Installation Complete!"
echo "======================================${NC}"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your configuration"
echo "2. Run: python manage.py runserver"
echo "3. Access: http://localhost:8000/"
echo "4. Admin: http://localhost:8000/admin/"
echo ""
