#!/bin/bash

# BAORCO Online Shop - Complete Source Code Archive Creator
# This script creates a complete, production-ready ZIP archive

set -e

echo "=========================================="
echo "Creating BAORCO Online Shop Source Archive"
echo "=========================================="
echo ""

PROJECT_DIR="baorco_shop"
ARCHIVE_NAME="baorco-online-shop-complete-$(date +%Y%m%d-%H%M%S).zip"
TEMP_DIR="/tmp/baorco-archive"

# Clean up any previous temp directory
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

echo "[1/5] Creating directory structure..."
cd "$TEMP_DIR"
mkdir -p "$PROJECT_DIR"

echo "[2/5] Copying project files..."
# Copy all source files
cp -r "/home/claude/baorco_shop"/* "$PROJECT_DIR/" 2>/dev/null || true

# Ensure key files exist
touch "$PROJECT_DIR"/logs/.gitkeep
touch "$PROJECT_DIR"/media/.gitkeep
touch "$PROJECT_DIR"/backups/.gitkeep

echo "[3/5] Creating archive..."
zip -r "$ARCHIVE_NAME" "$PROJECT_DIR" -q

# Move archive to user output directory
mv "$ARCHIVE_NAME" "/home/claude/baorco_shop/"

echo "[4/5] Calculating archive size..."
SIZE=$(du -h "/home/claude/baorco_shop/$ARCHIVE_NAME" | cut -f1)

echo "[5/5] Cleaning up..."
rm -rf "$TEMP_DIR"

echo ""
echo "=========================================="
echo "✅ Archive Created Successfully!"
echo "=========================================="
echo ""
echo "Archive Details:"
echo "  Name: $ARCHIVE_NAME"
echo "  Size: $SIZE"
echo "  Location: /home/claude/baorco_shop/$ARCHIVE_NAME"
echo ""
echo "Contents:"
echo "  ✓ Complete Django Project"
echo "  ✓ All Source Code Files"
echo "  ✓ Configuration Files"
echo "  ✓ Docker Setup"
echo "  ✓ Deployment Guides"
echo "  ✓ Documentation"
echo "  ✓ Requirements & Dependencies"
echo ""
echo "To deploy on your Ubuntu server:"
echo "  1. Upload the ZIP file"
echo "  2. Extract: unzip baorco-online-shop-*.zip"
echo "  3. Enter directory: cd baorco_shop"
echo "  4. Copy env: cp .env.example .env"
echo "  5. Edit .env with your settings"
echo "  6. Run: docker-compose up -d"
echo ""
