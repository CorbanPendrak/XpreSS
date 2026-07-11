<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Filter Bypass Challenges - XpreSS</title>
    <link rel="stylesheet" href="retro-style.css">
</head>
<body>
    <div class="container">
        <div class="warning">
            <strong>⚠️ Filter Bypass Lab:</strong> Each challenge applies a weak blacklist filter. Find a payload that still executes.
        </div>

        <h1>Filter Bypass Challenges</h1>
        <p>Blacklists are not sanitization. These labs show how partial filters leave room for alternate tags, events, nesting, and context breakouts.</p>

        <div class="link-section">
            <h3>Challenges</h3>
            <ul>
                <li><a href="challenge-script-filter.php">Level 1 — Script tag blacklist</a></li>
                <li><a href="challenge-event-filter.php">Level 2 — Script + common event handlers</a></li>
                <li><a href="challenge-nested-filter.php">Level 3 — Single-pass script removal</a></li>
                <li><a href="challenge-attribute-filter.php">Level 4 — Attribute context + quote strip</a></li>
            </ul>
        </div>

        <div class="back-link">
            <a href="index.php">← Back to Home</a>
        </div>
    </div>
</body>
</html>
