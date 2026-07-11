<?php
// Intentionally weak blacklist filters for XSS bypass challenges.

function filter_script_tags($input) {
    return preg_replace('/<script\b[^>]*>.*?<\/script>/is', '', $input);
}

function filter_script_and_events($input) {
    $input = filter_script_tags($input);
    $input = preg_replace('/\bon(error|load|click|mouse\w+|focus|blur|change|submit)\s*=/i', 'blocked=', $input);
    return $input;
}

function filter_script_once($input) {
    // Only the first occurrence of each marker is removed — nested payloads can survive.
    $pos = stripos($input, '<script>');
    if ($pos !== false) {
        $input = substr_replace($input, '', $pos, strlen('<script>'));
    }
    $pos = stripos($input, '</script>');
    if ($pos !== false) {
        $input = substr_replace($input, '', $pos, strlen('</script>'));
    }
    return $input;
}

function filter_quotes($input) {
    return str_replace(['"', "'"], '', $input);
}
