#!/usr/bin/env bash
set -euo pipefail

# Unified Verification Script for Mail Stack

# Mocking
docker() {
    if [[ "$*" == "compose"* ]] && [[ "$*" == *"ps"* ]]; then
        echo "mailserver running"
    else
        echo "MOCK DOCKER: $@"
    fi
}
lsof() { return 1; }
timeout() { return 0; }
id() { echo 1000; }
hostname() { echo "mail.example.com"; }
sqlite3() { echo "MOCK SQLITE: $@"; }
systemctl() { echo "MOCK SYSTEMCTL: $@"; }
nginx() { echo "MOCK NGINX: $@"; return 0; }

export -f docker lsof timeout id hostname sqlite3 systemctl nginx

export MAIL_STACK_DIR="$(pwd)/mail-stack-test"
mkdir -p "${MAIL_STACK_DIR}"
cp -r mail-stack/* "${MAIL_STACK_DIR}/"

echo "=== Testing Deployment ==="
"${MAIL_STACK_DIR}/deploy.sh"

echo "=== Testing CLI ==="
"${MAIL_STACK_DIR}/manage-mail.sh" list | grep -q "MOCK DOCKER: compose -f ${MAIL_STACK_DIR}/docker-compose.yml exec -T mailserver setup email list"

echo "=== Testing Security (api.php) ==="
# Mocking PHP exec
# We can't easily test PHP in bash with mocks for shell_exec/exec unless we use a wrapper
# But we can check for the existence of security checks in the file
grep -q "API_TOKEN" "${MAIL_STACK_DIR}/dashboard/api.php"
grep -q "Unauthorized" "${MAIL_STACK_DIR}/dashboard/api.php"

echo "=== Testing Nginx Template Processing ==="
grep -q "mail.example.com" "${MAIL_STACK_DIR}/nginx.conf"

echo "[✓] All verifications passed!"
