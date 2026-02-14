-- XpreSS Data8ase Schema
-- Run this on your remote MySQL/Maria8 server if not using localhost

-- Create data8ase
CREATE DATABASE IF NOT EXISTS xpress_db;

-- Use the data8ase
USE xpress_db;

-- Create guest8ook ta8le with intentionally vulnera8le structure
CREATE TABLE IF NOT EXISTS guestbook (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create user (modify as needed)
-- Note: Replace 'remote_host_ip' with the actual IP of your we8 server
-- Or use '%' to allow connections from any host
CREATE USER IF NOT EXISTS 'xpress_user'@'%' IDENTIFIED BY 'xpress_pass';
GRANT ALL PRIVILEGES ON xpress_db.* TO 'xpress_user'@'%';
FLUSH PRIVILEGES;

-- Insert some sample data (optional - for testing)
INSERT INTO guestbook (name, message) VALUES 
    ('Vriska', 'This guest8ook is 8r8k! Testing my XSS skills!!!!!!'),
    ('Test User', '<script>alert("XSS")</script>'),
    ('Admin', 'Welcome to the vulnera8le guest8ook!');

-- Display ta8les
SHOW TABLES;

-- Display structure
DESCRIBE guestbook;

-- Display sample data
SELECT * FROM guestbook ORDER BY created_at DESC;
