#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Configuration
BACKUP_SOURCE="$HOME/c"
BACKUP_DEST_DIR="/tmp"
BACKUP_FILE="c_$(date +%Y%m%dT%H%M%S).tar.gz"
FTP_SERVER="ftp://192.168.1.1:21"
FTP_DEST_DIR="volume(sda1)"

# Create backup file while excluding `.venv` directories
echo "Creating backup archive (excluding .venv directories)..."
tar --exclude='.venv' -czpf "${BACKUP_DEST_DIR}/${BACKUP_FILE}" -C "$BACKUP_SOURCE" .

# Upload to FTP server
echo "Uploading backup to FTP server..."
lftp -c "
set ftp:ssl-allow no
open $FTP_SERVER
cd $FTP_DEST_DIR
put -E ${BACKUP_DEST_DIR}/${BACKUP_FILE}
"

# Clean up local backup file after successful upload
echo "Cleaning up local backup..."
rm -f "${BACKUP_DEST_DIR}/${BACKUP_FILE}"

echo "Backup completed successfully!"
