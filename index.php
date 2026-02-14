<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>XpreSS - XSS Vulnera8le Demo</title>
    <link rel="stylesheet" href="retro-style.css">
</head>
<body>
    <div class="container">
        <div class="warning">
            <strong>⚠️ Warning:</strong> This we8site is intentionally vulnera8le to XSS attacks for educational and security testing purposes only. Pretty 8r8k, huh????????
        </div>
        
        <h1>XpreSS - Cross-Site Scripting Demo</h1>
        
        <h2>Reflected XSS - Search Form</h2>
        <form method="GET" action="search.php">
            <label for="search">Search Query:</label>
            <input type="text" id="search" name="q" placeholder="Enter search term, if you're 8rave enough...">
            <button type="submit">Search</button>
        </form>
        
        <h2>Stored XSS - Guest8ook</h2>
        <form method="POST" action="guestbook.php">
            <label for="name">Your Name:</label>
            <input type="text" id="name" name="name" placeholder="Enter your name, o8viously...">
            
            <label for="message">Message:</label>
            <textarea id="message" name="message" rows="4" placeholder="Leave a message... Make it interesting!!!!!!!"></textarea>
            
            <button type="submit">Su8mit</button>
        </form>
        
        <div class="link-section">
            <h3>Pages:</h3>
            <ul>
                <li><a href="search.php">Search Page</a></li>
                <li><a href="guestbook.php">Guest8ook</a></li>
                <li><a href="profile.php?user=admin">Profile Page</a></li>
            </ul>
        </div>
    </div>
</body>
</html>
