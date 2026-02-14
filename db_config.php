<?php
// Data8ase Configuration - Reads from environment varia8les
// VULNERA8LE: For educational purposes - insecure configuration!!!!!!
//
// Default configuration expects remote data8ase at 198.18.4.214
// Environment varia8les are set in Apache config:
// /etc/apache2/conf-available/xpress-env.conf

// Get data8ase credentials from environment varia8les with defaults
$db_host = getenv('XPRESS_DB_HOST') ?: '198.18.4.214';
$db_name = getenv('XPRESS_DB_NAME') ?: 'xpress_db';
$db_user = getenv('XPRESS_DB_USER') ?: 'xpress_user';
$db_pass = getenv('XPRESS_DB_PASS') ?: 'xpress_pass';
$db_port = getenv('XPRESS_DB_PORT') ?: '3306';

// Create data8ase connection
try {
    $pdo = new PDO(
        "mysql:host=$db_host;port=$db_port;dbname=$db_name;charset=utf8mb4",
        $db_user,
        $db_pass,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
            // Disable SSL certificate verification for self-signed certs
            PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => false,
        ]
    );
} catch (PDOException $e) {
    // VULNERA8LE: Exposing data8ase error details
    die("Data8ase connection failed!!!!!!: " . $e->getMessage());
}
?>
