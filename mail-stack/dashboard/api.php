<?php
/**
 * QuickBox Mail Stack Dashboard API Bridge
 */

header('Content-Type: application/json');

// Security Check: Ensure only authorized requests are processed.
// In the QuickBox ecosystem, this bridge is called by the main dashboard.
// We implement a token-based check for management parity and security.

$env_file = dirname(__DIR__) . '/.env';
$config = [];
if (file_exists($env_file)) {
    $lines = file($env_file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(ltrim($line), '#') === 0) continue;
        $parts = explode('=', $line, 2);
        if (count($parts) === 2) {
            $config[trim($parts[0])] = trim($parts[1]);
        }
    }
}

$api_token = $config['API_TOKEN'] ?? null;
$provided_token = $_SERVER['HTTP_X_API_TOKEN'] ?? $_REQUEST['token'] ?? null;

if (empty($api_token) || $provided_token !== $api_token) {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized: Invalid or missing API token.']);
    exit;
}

$command = $_REQUEST['command'] ?? '';
$args = $_REQUEST['args'] ?? [];

if (!is_array($args)) {
    $args = $args ? explode(' ', $args) : [];
}

$allowed_commands = ['add', 'del', 'list', 'passwd', 'quota', 'dkim'];

if (!in_array($command, $allowed_commands)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid command']);
    exit;
}

$cli_path = '/opt/quickbox/mail-stack/manage-mail.sh';
if (!file_exists($cli_path)) {
    $cli_path = dirname(__DIR__) . '/manage-mail.sh';
}

$escaped_args = array_map('escapeshellarg', $args);
$full_command = 'sudo ' . escapeshellarg($cli_path) . ' ' . $command . ' ' . implode(' ', $escaped_args) . ' 2>&1';

exec($full_command, $output, $return_var);

echo json_encode([
    'success' => ($return_var === 0),
    'command' => $command,
    'output' => $output,
    'return_code' => $return_var
]);
