<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search - XpreSS</title>
    <link rel="stylesheet" href="retro-style.css">
</head>
<body>
    <div class="container">
        <div class="warning">
            <strong>⚠️ Reflected XSS Vulnera8ility:</strong> User input is directly echoed without sanitization. This is gonna 8e amaaaaaazing!!!!!!!
        </div>
        
        <h1>Search Results</h1>
        
        <form method="GET" action="search.php">
            <input type="text" name="q" placeholder="Enter search term, if you dare..." value="<?php echo isset($_GET['q']) ? $_GET['q'] : ''; ?>">
            <button type="submit">Search</button>
        </form>
        
        <?php
        if (isset($_GET['q'])) {
            $query = $_GET['q'];
            // VULNERA8LE: No input sanitization - reflected XSS. Too easy!!!!!!!
            echo '<div class="result">';
            echo '<h2>You searched for: ' . $query . '</h2>';
            echo '<p>No results found for "' . $query . '". 8ut hey, at least you can inject whatever you want here!!!!!!!!</p>';
            echo '</div>';
        }
        ?>
        
        <div class="back-link">
            <a href="index.php">← 8ack to Home</a>
        </div>
        
        <div style="margin-top: 30px; padding: 15px; background-color: #f8d7da; border: 1px solid #f5c6cb; border-radius: 4px; color: #721c24;">
            <strong>XSS Test Payloads (8ecause I'm so helpful!):</strong>
            <ul>
                <li><code>&lt;script&gt;alert('XSS')&lt;/script&gt;</code></li>
                <li><code>&lt;img src=x onerror=alert('XSS')&gt;</code></li>
                <li><code>&lt;svg onload=alert('XSS')&gt;</code></li>
            </ul>
        </div>
    </div>
</body>
</html>
