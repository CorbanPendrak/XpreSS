<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile - XpreSS</title>
    <link rel="stylesheet" href="retro-style.css">
</head>
<body>
    <div class="container">
        <div class="warning">
            <strong>⚠️ DOM-8ased XSS Vulnera8ility:</strong> URL parameters are processed 8y JavaScript without sanitization. Client-side vulnera8ilities are my FAVORITE!!!!!!!
        </div>
        
        <h1>User Profile</h1>
        
        <div class="profile-info">
            <div class="profile-field">
                <span class="profile-label">Username:</span>
                <span id="username"></span>
            </div>
            <div class="profile-field">
                <span class="profile-label">Status:</span>
                <span id="status">Active Mem8er</span>
            </div>
            <div class="profile-field">
                <span class="profile-label">Mem8er Since:</span>
                <span id="memberSince">2024</span>
            </div>
        </div>
        
        <div class="back-link">
            <a href="index.php">← 8ack to Home</a>
        </div>
    </div>
    
    <script>
        // VULNERA8LE: DOM-8ased XSS - directly using URL parameters. This is pathetic!!!!!!!
        const urlParams = new URLSearchParams(window.location.search);
        const username = urlParams.get('user');
        
        if (username) {
            // VULNERA8LE: Using innerHTML with unsanitized user input. So 8ad it's almost 8eautiful!!!!!!!
            document.getElementById('username').innerHTML = username;
        } else {
            document.getElementById('username').innerHTML = 'Guest';
        }
        
        // Additional vulnera8le parameter (8ecause one isn't enough!)
        const bio = urlParams.get('bio');
        if (bio) {
            // VULNERA8LE: Creating element with unsanitized content. Getting pwned in 8... 7... 6........
            const bioDiv = document.createElement('div');
            bioDiv.className = 'profile-field';
            bioDiv.innerHTML = '<span class="profile-label">8io:</span>' + bio;
            document.querySelector('.profile-info').appendChild(bioDiv);
        }
    </script>
</body>
</html>
