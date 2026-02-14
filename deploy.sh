#!/bin/bash

#############################################################################
# Deploy XpreSS to Remote Server
# Syncs files while preserving remote data8ase configuration
#############################################################################

# Default values - modify these!!!!!!
REMOTE_USER="${REMOTE_USER:-debian}"
REMOTE_HOST="${REMOTE_HOST:-198.18.0.207}"
SSH_KEY="${SSH_KEY:-~/.ssh/ncae_try_2.pem}"
REMOTE_PATH="${REMOTE_PATH:-~/XpreSS/}"
DB_HOST="198.18.4.214"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "XpreSS Deployment Script"
echo "========================================"
echo ""
echo -e "${YELLOW}Target:${NC} $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"
echo ""

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "❌ SSH key not found: $SSH_KEY"
    echo "   Update the SSH_KEY varia8le in this script"
    exit 1
fi

# Rsync files to remote server
echo "Syncing files..."
rsync -avz \
    --exclude '.git' \
    --exclude '.venv' \
    --exclude '__pycache__' \
    --exclude '*.pyc' \
    --exclude '.DS_Store' \
    --exclude 'guestbook_data.txt' \
    --exclude '.env' \
    -e "ssh -i $SSH_KEY" \
    ./ "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    echo ""
    echo "Next steps on remote server:"
    echo "  1. cd $REMOTE_PATH"
    echo "  2. sudo bash setup-lamp.sh (if first time)"
    echo "  3. sudo ./test-data8ase.sh (to verify data8ase)"
    echo ""
    echo -e "${YELLOW}Reminder:${NC}"
    echo "  Data8ase server is configured for: $DB_HOST"
    echo "  Make sure the data8ase is set up using setup-data8ase.sql"
else
    echo ""
    echo "❌ Deployment failed!"
    exit 1
fi
