#!/bin/bash

#############################################################################
# LAMP Stack Setup Script for Debian
# Sets up Apache, MySQL/MariaDB, and PHP for the XpreSS vulnerable web app
# 
# NOTE: This script is configured to use a REMOTE database server at:
#       198.18.4.214 (hardcoded, no prompts)
#
# PREREQUISITES (on database server 198.18.4.214):
#   1. CREATE DATABASE IF NOT EXISTS xpress_db;
#   2. CREATE USER 'xpress_user'@'%' IDENTIFIED BY 'xpress_pass';
#   3. GRANT ALL PRIVILEGES ON xpress_db.* TO 'xpress_user'@'%';
#   4. FLUSH PRIVILEGES;
#
# This script will automatically create the guestbook table remotely.
#############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_error "Please run as root (use sudo)"
    exit 1
fi

print_info "Starting LAMP stack installation for XpreSS..."
echo ""

#############################################################################
# 1. Update System
#############################################################################
print_info "Updating package lists..."
apt-get update -y

print_info "Upgrading existing packages..."
apt-get upgrade -y
print_success "System updated"
echo ""

#############################################################################
# 2. Install Apache
#############################################################################
print_info "Installing Apache web server..."
apt-get install -y apache2

print_info "Enabling Apache to start on boot..."
systemctl enable apache2

print_info "Starting Apache service..."
systemctl start apache2

# Check Apache status
if systemctl is-active --quiet apache2; then
    print_success "Apache installed and running"
else
    print_error "Apache failed to start"
    exit 1
fi
echo ""

#############################################################################
# 3. Install MySQL/MariaDB
#############################################################################
print_info "Installing MariaDB server..."
apt-get install -y mariadb-server mariadb-client

print_info "Enabling MariaDB to start on boot..."
systemctl enable mariadb

print_info "Starting MariaDB service..."
systemctl start mariadb

# Check MariaDB status
if systemctl is-active --quiet mariadb; then
    print_success "MariaDB installed and running"
else
    print_error "MariaDB failed to start"
    exit 1
fi

print_warning "Remember to run 'mysql_secure_installation' to secure your database"
echo ""

#############################################################################
# 3.5. Configure Database Connection Variables
#############################################################################
print_info "Configuring database connection variables..."

# Use remote database with default values
DB_HOST="198.18.4.214"
DB_NAME="xpress_db"
DB_USER="xpress_user"
DB_PASS="xpress_pass"
DB_PORT="3306"

print_info "Using remote database configuration:"
echo "  Host: $DB_HOST"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo "  Port: $DB_PORT"

print_success "Database configuration set"
echo ""

#############################################################################
# 3.6. Create Table on Remote Database
#############################################################################
print_info "Creating guestbook table on remote database..."

# Create the table using the xpress_user credentials (disable SSL to avoid certificate issues)
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" --ssl=0 "$DB_NAME" <<'EOF'
CREATE TABLE IF NOT EXISTS guestbook (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
EOF

if [ $? -eq 0 ]; then
    print_success "Guest8ook table created successfully"
else
    print_error "Failed to create table on remote database"
    print_warning "Make sure the database and user exist on $DB_HOST"
    print_warning "Run these commands on the database server first:"
    echo "  CREATE DATABASE IF NOT EXISTS xpress_db;"
    echo "  CREATE USER 'xpress_user'@'%' IDENTIFIED BY 'xpress_pass';"
    echo "  GRANT ALL PRIVILEGES ON xpress_db.* TO 'xpress_user'@'%';"
    echo "  FLUSH PRIVILEGES;"
    exit 1
fi
echo ""

#############################################################################
# 4. Install PHP
#############################################################################
print_info "Installing PHP and required modules..."
apt-get install -y php libapache2-mod-php php-mysql php-cli php-curl php-gd php-mbstring php-xml php-xmlrpc

print_info "Configuring Apache to prefer PHP files..."
# Backup original dir.conf
cp /etc/apache2/mods-enabled/dir.conf /etc/apache2/mods-enabled/dir.conf.backup

# Modify DirectoryIndex to prefer index.php
sed -i 's/DirectoryIndex.*/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/' /etc/apache2/mods-enabled/dir.conf

print_success "PHP installed and configured"
echo ""

#############################################################################
# 5. Configure Apache for XpreSS
#############################################################################
print_info "Configuring Apache for XpreSS application..."

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WEB_ROOT="/var/www/html/xpress"

# Create web directory
mkdir -p "$WEB_ROOT"

# Copy files
print_info "Copying XpreSS files to web root..."
cp -r "$SCRIPT_DIR"/*.php "$WEB_ROOT/" 2>/dev/null || print_warning "No PHP files found to copy"
cp -r "$SCRIPT_DIR"/*.css "$WEB_ROOT/" 2>/dev/null || print_warning "No CSS files found to copy"
cp -r "$SCRIPT_DIR"/*.js "$WEB_ROOT/" 2>/dev/null || true
cp -r "$SCRIPT_DIR"/*.txt "$WEB_ROOT/" 2>/dev/null || true

# Create environment variables file for Apache
print_info "Creating environment configuration..."
cat > /etc/apache2/conf-available/xpress-env.conf <<EOF
# XpreSS Database Environment Variables
SetEnv XPRESS_DB_HOST "$DB_HOST"
SetEnv XPRESS_DB_NAME "$DB_NAME"  
SetEnv XPRESS_DB_USER "$DB_USER"
SetEnv XPRESS_DB_PASS "$DB_PASS"
SetEnv XPRESS_DB_PORT "$DB_PORT"
EOF

# Enable the environment configuration
a2enconf xpress-env
print_success "Environment variables configured"

# Set proper permissions
chown -R www-data:www-data "$WEB_ROOT"
chmod -R 755 "$WEB_ROOT"

# Create writable directory for guestbook data
mkdir -p "$WEB_ROOT"
chmod 777 "$WEB_ROOT"  # INTENTIONALLY INSECURE for demo purposes

# Create Apache virtual host configuration
print_info "Creating Apache virtual host configuration..."
cat > /etc/apache2/sites-available/xpress.conf <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot $WEB_ROOT
    
    <Directory $WEB_ROOT>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/xpress_error.log
    CustomLog \${APACHE_LOG_DIR}/xpress_access.log combined
</VirtualHost>
EOF

# Disable default site and enable xpress site
a2dissite 000-default.conf
a2ensite xpress.conf

print_success "Apache configured for XpreSS"
echo ""

#############################################################################
# 6. Enable Apache modules
#############################################################################
print_info "Enabling required Apache modules..."
a2enmod rewrite
a2enmod php8.2 2>/dev/null || a2enmod php8.1 2>/dev/null || a2enmod php7.4 2>/dev/null || print_warning "PHP module already enabled or version detection failed"
print_success "Apache modules enabled"
echo ""

#############################################################################
# 7. Restart Apache
#############################################################################
print_info "Restarting Apache to apply changes..."
systemctl restart apache2

if systemctl is-active --quiet apache2; then
    print_success "Apache restarted successfully"
else
    print_error "Apache failed to restart"
    exit 1
fi
echo ""

#############################################################################
# 8. Configure Firewall (optional)
#############################################################################
print_info "Checking firewall status..."
if command -v ufw &> /dev/null; then
    print_info "UFW detected. Allowing HTTP and HTTPS traffic..."
    ufw allow 'Apache Full'
    print_success "Firewall configured"
else
    print_warning "UFW not installed. Skipping firewall configuration."
fi
echo ""

#############################################################################
# 9. Create PHP info page (for testing)
#############################################################################
print_info "Creating PHP info page..."
cat > "$WEB_ROOT/info.php" <<EOF
<?php
phpinfo();
?>
EOF
chown www-data:www-data "$WEB_ROOT/info.php"
print_success "PHP info page created at /info.php"
echo ""

#############################################################################
# 10. Display system information
#############################################################################
print_success "========================================"
print_success "LAMP Stack Installation Complete!"
print_success "========================================"
echo ""
echo -e "${GREEN}Services Status:${NC}"
echo "  Apache: $(systemctl is-active apache2)"
echo "  MariaDB: $(systemctl is-active mariadb)"
echo ""
echo -e "${GREEN}Versions:${NC}"
apache2 -v | head -n 1
mysql --version
php -v | head -n 1
echo ""
echo -e "${GREEN}Database Configuration:${NC}"
echo "  Host: $DB_HOST"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo "  Port: $DB_PORT"
echo ""
echo -e "${YELLOW}Access your application:${NC}"
echo "  Local: http://localhost/"
echo "  Network: http://$(hostname -I | awk '{print $1}')/"
echo "  PHP Info: http://localhost/info.php"
echo ""
echo -e "${RED}SECURITY WARNING:${NC}"
echo "  This application is INTENTIONALLY VULNERABLE for educational purposes."
echo "  Do NOT expose this to the public internet!"
echo "  Use only in isolated test environments."
echo ""
echo -e "${YELLOW}Environment Variables Set:${NC}"
echo "  XPRESS_DB_HOST=$DB_HOST"
echo "  XPRESS_DB_NAME=$DB_NAME"
echo "  XPRESS_DB_USER=$DB_USER"
echo "  XPRESS_DB_PORT=$DB_PORT"
echo "  (Variables are configured in /etc/apache2/conf-available/xpress-env.conf)"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Test database connectivity: sudo ./test-database.sh"
echo "  2. Test the application at http://localhost/"
echo "  3. Remove /info.php when done testing: rm $WEB_ROOT/info.php"
echo ""
echo -e "${YELLOW}Prerequisites (must be done on database server $DB_HOST):${NC}"
echo "  - Database 'xpress_db' must exist"
echo "  - User 'xpress_user'@'%' must exist with privileges"
echo "  - Server must accept remote connections (bind-address = 0.0.0.0)"
echo ""
print_success "Setup script completed successfully!"
