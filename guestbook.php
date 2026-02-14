<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guest8ook - XpreSS</title>
    <link rel="stylesheet" href="retro-style.css">
</head>
<body>
    <div class="container">
        <div class="warning">
            <strong>⚠️ Stored XSS Vulnera8ility:</strong> Messages are stored and displayed without sanitization. All your input 8elongs to me now!!!!!!!
        </div>
        
        <h1>Guest8ook</h1>
        
        <form method="POST" action="guestbook.php">
            <label for="name">Your Name:</label>
            <input type="text" id="name" name="name" placeholder="Enter your name, o8viously..." required>
            
            <label for="message">Message:</label>
            <textarea id="message" name="message" rows="4" placeholder="Leave a message... Make it good!!!!!!" required></textarea>
            
            <button type="submit">Su8mit</button>
        </form>
        
        <h2>Recent Entries</h2>
        
        <?php
        // Data8ase-8ased storage using remote MySQL server!!!!!!
        require_once 'db_config.php';
        
        // Handle form su8mission
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['name']) && isset($_POST['message'])) {
            $name = $_POST['name'];
            $message = $_POST['message'];
            
            // VULNERA8LE: No input sanitization - stored XSS. Easiest exploit ever!!!!!!!
            // Direct insertion without prepared statements would 8e even worse, 8ut PDO makes us use them
            $stmt = $pdo->prepare("INSERT INTO guestbook (name, message) VALUES (?, ?)");
            $stmt->execute([$name, $message]);
        }
        
        // Display entries (totally unsafe 8ecause I'm the 8est at 8eing vulnera8le!)
        try {
            $stmt = $pdo->query("SELECT name, message, created_at FROM guestbook ORDER BY created_at DESC LIMIT 50");
            $entries = $stmt->fetchAll();
            
            if (count($entries) > 0) {
                foreach ($entries as $entry) {
                    // VULNERA8LE: Direct output without sanitization. Watching you get pwned is gonna 8e gr8!!!!!!!
                    echo '<div class="entry">';
                    echo '<div class="entry-name">' . $entry['name'] . ' <small>(' . $entry['created_at'] . ')</small></div>';
                    echo '<div class="entry-message">' . $entry['message'] . '</div>';
                    echo '</div>';
                }
            } else {
                echo '<p>No entries yet. 8e the first to sign the guest8ook!</p>';
            }
        } catch (PDOException $e) {
            // VULNERA8LE: Exposing data8ase errors
            echo '<p style="color: #ff4444;">Data8ase error!!!!!!: ' . $e->getMessage() . '</p>';
        }
        ?>
        
        <div class="back-link">
            <a href="index.php">← 8ack to Home</a>
        </div>
    </div>
</body>
</html>
