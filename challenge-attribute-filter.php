<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Level 4: Attribute Filter - XpreSS</title>
    <link rel="stylesheet" href="retro-style.css">
</head>
<body>
    <div class="container">
        <div class="warning">
            <strong>Level 4:</strong> Input is reflected inside an attribute. Double and single quotes are stripped.
        </div>

        <h1>Attribute Context + Quote Strip</h1>

        <form method="GET" action="challenge-attribute-filter.php">
            <label for="nickname">Nickname:</label>
            <input type="text" id="nickname" name="nickname" placeholder="Try a payload..." value="<?php echo isset($_GET['nickname']) ? htmlspecialchars($_GET['nickname'], ENT_QUOTES, 'UTF-8') : ''; ?>">
            <button type="submit">Submit</button>
        </form>

        <?php
        require_once 'filters.php';

        if (isset($_GET['nickname'])) {
            $raw = $_GET['nickname'];
            $filtered = filter_quotes($raw);

            echo '<div class="result">';
            echo '<h2>Filtered output</h2>';
            echo '<p>Preview card for user: <input type="text" readonly value="' . $filtered . '"></p>';
            echo '</div>';
        }
        ?>

        <div class="back-link">
            <a href="challenges.php">← All Challenges</a>
        </div>
    </div>
</body>
</html>
