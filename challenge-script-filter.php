<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Level 1: Script Filter - XpreSS</title>
    <link rel="stylesheet" href="retro-style.css">
</head>
<body>
    <div class="container">
        <div class="warning">
            <strong>Level 1:</strong> <code>&lt;script&gt;...&lt;/script&gt;</code> blocks are removed. Reflected in HTML body.
        </div>

        <h1>Script Tag Blacklist</h1>

        <form method="GET" action="challenge-script-filter.php">
            <label for="msg">Message:</label>
            <input type="text" id="msg" name="msg" placeholder="Try a payload..." value="<?php echo isset($_GET['msg']) ? htmlspecialchars($_GET['msg'], ENT_QUOTES, 'UTF-8') : ''; ?>">
            <button type="submit">Submit</button>
        </form>

        <?php
        require_once 'filters.php';

        if (isset($_GET['msg'])) {
            $raw = $_GET['msg'];
            $filtered = filter_script_tags($raw);

            echo '<div class="result">';
            echo '<h2>Filtered output</h2>';
            echo '<p>Your message: ' . $filtered . '</p>';
            echo '</div>';
        }
        ?>

        <div class="back-link">
            <a href="challenges.php">← All Challenges</a>
        </div>
    </div>
</body>
</html>
