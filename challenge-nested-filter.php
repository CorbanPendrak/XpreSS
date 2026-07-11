<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Level 3: Nested Filter - XpreSS</title>
    <link rel="stylesheet" href="retro-style.css">
</head>
<body>
    <div class="container">
        <div class="warning">
            <strong>Level 3:</strong> Only one pass of <code>&lt;script&gt;</code> / <code>&lt;/script&gt;</code> removal runs. Nested markers can survive.
        </div>

        <h1>Single-Pass Script Removal</h1>

        <form method="GET" action="challenge-nested-filter.php">
            <label for="msg">Message:</label>
            <input type="text" id="msg" name="msg" placeholder="Try a payload..." value="<?php echo isset($_GET['msg']) ? htmlspecialchars($_GET['msg'], ENT_QUOTES, 'UTF-8') : ''; ?>">
            <button type="submit">Submit</button>
        </form>

        <?php
        require_once 'filters.php';

        if (isset($_GET['msg'])) {
            $raw = $_GET['msg'];
            $filtered = filter_script_once($raw);

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
