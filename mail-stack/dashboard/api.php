<?php
/**
 * QuickBox Mail Stack Dashboard API Bridge
 */

header('Content-Type: application/json');

// Security Check: Ensure only authorized requests are processed.
// In the QuickBox ecosystem, this bridge is called by the main dashboard.
// We implement a token-based check for management parity and security.

$env_file = dirname(__DIR__) . '/.env';
$config = file_exists($env_file) ? parse_ini_file($env_file) : [];

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

/**
 * For security and robustness, we use proc_open with an array of arguments.
 * This bypasses the shell and mitigates command injection vulnerabilities.
 * Standard error is redirected to standard output for combined logging.
 */
$full_cmd_array = array_merge(['sudo', $cli_path, $command], $args);
$descriptorspec = [
    0 => ["pipe", "r"], // stdin
    1 => ["pipe", "w"], // stdout
    2 => ["redirect", 1] // stderr to stdout
];

$process = proc_open($full_cmd_array, $descriptorspec, $pipes);

$output = [];
if (is_resource($process)) {
    fclose($pipes[0]); // No input needed
    while ($line = fgets($pipes[1])) {
        $output[] = rtrim($line);
    }
    fclose($pipes[1]);
    $return_var = proc_close($process);
} else {
    $return_var = -1;
    $output[] = "Failed to execute management command.";
}

echo json_encode([
    'success' => ($return_var === 0),
    'command' => $command,
    'output' => $output,
    'return_code' => $return_var
]);
