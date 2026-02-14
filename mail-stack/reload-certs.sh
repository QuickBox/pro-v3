#!/usr/bin/env bash
# QuickBox Pro - Mail Stack Certificate Reload Script
# This script restarts the mailserver container to pick up renewed SSL certificates.
# You can add this to your crontab or use it as a post-renewal hook for Certbot/acme.sh.

set -euo pipefail

# Navigate to the script directory to ensure docker compose works if needed
cd "$(dirname "$0")"

if command -v docker &>/dev/null && docker ps --format '{{.Names}}' | grep -q "^mailserver$"; then
    echo "Reloading mailserver certificates..."
    docker restart mailserver
    echo "Mailserver certificates reloaded successfully."
else
    echo "Mailserver container is not running. No reload needed."
fi
